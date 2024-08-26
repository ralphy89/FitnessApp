import 'package:location/location.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

class SuiviAutomatic {
  final Location _location = Location();
  LocationData? _previousLocationData;
  LocationData? _currentLocationData;
  AccelerometerEvent? _accelerometerEvent;
  double _totalDistance = 0.0;

  SuiviAutomatic() {
    // Initialize location and listen for changes
    _initLocation();

    // Listen for accelerometer events
    accelerometerEvents.listen((AccelerometerEvent event) {
      _accelerometerEvent = event;
      // Handle accelerometer data if needed
    });
  }

  void _initLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location service is enabled
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Check location permissions
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Initialize previousLocationData
    _previousLocationData = await _location.getLocation();

    // Listen for location changes
    _location.onLocationChanged.listen((LocationData locationData) {
      // Ensure previousLocationData is not null before calculating distance
      if (_previousLocationData != null) {
        _totalDistance += _calculateDistance(
          _previousLocationData!,
          locationData,
        );
      }
      // Update location data
      _previousLocationData = _currentLocationData;
      _currentLocationData = locationData;
    });
  }


  // Get current GPS data
  Map<String, dynamic> getSuiviGps() {
    if (_currentLocationData != null) {
      return {
        'latitude': _currentLocationData!.latitude,
        'longitude': _currentLocationData!.longitude,
      };
    }
    return {};
  }

  // Get current accelerometer data
  Map<String, dynamic> getAccelData() {
    if (_accelerometerEvent != null) {
      return {
        'x': _accelerometerEvent!.x,
        'y': _accelerometerEvent!.y,
        'z': _accelerometerEvent!.z,
      };
    }
    return {};
  }

  // Get total distance covered
  double getDistance() {
    return _totalDistance;
  }


// Calculate distance between two location points
  double _calculateDistance(LocationData start, LocationData end) {
    if (start.latitude == null || start.longitude == null ||
        end.latitude == null || end.longitude == null) {
      return 0.0;
    }

    const double earthRadiusKm = 6371.0; // Radius of the Earth in kilometers

    double lat1 = start.latitude!;
    double lon1 = start.longitude!;
    double lat2 = end.latitude!;
    double lon2 = end.longitude!;

    double lat1Rad = lat1 * (pi / 180.0);
    double lon1Rad = lon1 * (pi / 180.0);
    double lat2Rad = lat2 * (pi / 180.0);
    double lon2Rad = lon2 * (pi / 180.0);

    double dLat = lat2Rad - lat1Rad;
    double dLon = lon2Rad - lon1Rad;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c; // Distance in kilometers
  }
}
