import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'seance_service.dart';
import 'suivi_automatic.dart';
import 'seance_model.dart';

class AutomaticTrackingScreen extends StatefulWidget {
  final String uid;

  const AutomaticTrackingScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _AutomaticTrackingScreenState createState() => _AutomaticTrackingScreenState(uid);
}

class _AutomaticTrackingScreenState extends State<AutomaticTrackingScreen> {
  String? _selectedExerciseType;
  final SuiviAutomatic _suiviAutomatic = SuiviAutomatic();
  final SeanceService _seanceService = SeanceService();
  final String uid;
  bool _isTracking = false;
  Duration _elapsedTime = Duration.zero;
  double _distanceCovered = 0.0;
  double _caloriesBurned = 0;
  Timer? _timer;
  final _notesController = TextEditingController();

  _AutomaticTrackingScreenState(this.uid);

  void _startTracking() {
    if (_selectedExerciseType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an exercise type')),
      );
      return;
    }

    setState(() {
      _isTracking = true;
      _elapsedTime = Duration.zero;
      _distanceCovered = 0.0;
      _caloriesBurned = 0;

      // Start a timer to update the elapsed time every second
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _elapsedTime = Duration(seconds: _elapsedTime.inSeconds + 1);
          _distanceCovered = _suiviAutomatic.getDistance(); // Hypothetical method
          _caloriesBurned = SeanceService().roundToDecimalPlaces(_calculateCalories(_distanceCovered, _selectedExerciseType!), 3);
        });
      });
    });
  }

  void _stopTracking() async {
    _timer?.cancel(); // Stop the timer
    Map<String, dynamic> gpsData = _suiviAutomatic.getSuiviGps();
    Map<String, dynamic> accelData = _suiviAutomatic.getAccelData();

    final seance = Seance(
      id: 'unique-id',
      unite: 'km',
      userId: uid,
      typeExercice: _selectedExerciseType!,
      duree: _elapsedTime,
      caloriesBrulees: _caloriesBurned,
      notes: _notesController.text,
      suiviGps: gpsData,
      accelData: accelData,
      valeurRealisee: _distanceCovered,
    );

    try {
      // Save session
      await _seanceService.enregistrerSeance(seance);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session saved successfully'),
          backgroundColor: Colors.green,),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session save'), backgroundColor: Colors.orange,),      );
    }

    setState(() {
      _isTracking = false;
    });
  }

  double _calculateCalories(double distance, String exerciseType) {
    switch (exerciseType) {
      case 'Running':
        return distance * 60; // Calories per km for running
      case 'Walking':
        return distance * 50; // Calories per km for walking
      case 'Cycling':
        return distance * 40; // Calories per km for cycling
      case 'Swimming':
        return distance * 70; // Calories per km for swimming
      default:
        return 0;
    }
  }

  void _selectExercise(String exerciseType) {
    setState(() {
      _selectedExerciseType = exerciseType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Automatic Tracking'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: SingleChildScrollView( // Added SingleChildScrollView to prevent overflow
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              _buildExerciseSelection(),
              const SizedBox(height: 40),
              TextFormField(
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 20, // Adjusted fontSize for consistency
                ),
                controller: _notesController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder( // Use OutlineInputBorder for consistent border styling
                      borderSide: BorderSide(color: Color(0xFF2F3C44)), // Unified border color
                    ),
                    hintText: 'Course à pied le matin, temps nuageux',
                    hintStyle: TextStyle(color: Colors.green),
                    labelText: 'Notes',
                    labelStyle: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                    prefixIcon: Icon(Icons.note),
                    fillColor: Colors.white24,
                    filled: true
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 60),
              _isTracking ? _buildTrackingMetrics() : _buildStartButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildExerciseOption(
          icon: Icons.directions_run,
          color: Colors.green,
          label: 'Running',
          isSelected: _selectedExerciseType == 'Running',
          onTap: () => _selectExercise('Running'),
        ),
        _buildExerciseOption(
          icon: Icons.directions_walk,
          color: Colors.blue,
          label: 'Walking',
          isSelected: _selectedExerciseType == 'Walking',
          onTap: () => _selectExercise('Walking'),
        ),
        _buildExerciseOption(
          icon: Icons.directions_bike,
          color: Colors.orange,
          label: 'Cycling',
          isSelected: _selectedExerciseType == 'Cycling',
          onTap: () => _selectExercise('Cycling'),
        ),
        _buildExerciseOption(
          icon: Icons.pool,
          color: Colors.cyan,
          label: 'Swimming',
          isSelected: _selectedExerciseType == 'Swimming',
          onTap: () => _selectExercise('Swimming'),
        ),
      ],
    );
  }

  Widget _buildExerciseOption({
    required IconData icon,
    required Color color,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: isSelected ? 35 : 30,
            backgroundColor: isSelected ? color.withOpacity(0.8) : color,
            child: Icon(icon, color: Colors.white, size: isSelected ? 30 : 25),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? Colors.orangeAccent : Colors.black54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingMetrics() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildMetricTile(
          icon: Icons.timer,
          label: 'Elapsed Time',
          value: _formatDuration(_elapsedTime),
        ),
        const SizedBox(height: 20),
        _buildMetricTile(
          icon: Icons.social_distance,
          label: 'Distance Covered',
          value: '${_distanceCovered.toStringAsFixed(2)} km',
        ),
        const SizedBox(height: 20),
        _buildMetricTile(
          icon: Icons.local_fire_department,
          label: 'Calories Burned',
          value: '$_caloriesBurned cal',
        ),
        const SizedBox(height: 40),
        ElevatedButton.icon(
          onPressed: _stopTracking,
          icon: const Icon(Icons.stop),
          label: const Text('Stop Tracking'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return _selectedExerciseType == null
        ? Container()
        : ElevatedButton.icon(
      onPressed: _startTracking,
      icon: const Icon(Icons.play_arrow),
      label: const Text('Start Tracking'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 22),
        textStyle: const TextStyle(fontSize: 25, color: Colors.white),
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 40, color: Colors.black54),
        const SizedBox(width: 20),
        Text(
          '$label: $value',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${duration.inHours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
