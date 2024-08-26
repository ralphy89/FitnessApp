import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Authentification/welcome.dart';
import 'seance_model.dart';
class SeanceService {

  bool new_ = false;
  // URL de l'API REST
  late final String baseUrl;

  // Instance de Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> enregistrerSeance(Seance seance) async {
    final prefs = await SharedPreferences.getInstance();
    baseUrl = '${prefs.getString('baseUrl')}';
    // Enregistrer la séance dans Firestore
    await _enregistrerDansFirestore(seance);

    // Ensuite, envoyer les données à l'API REST
    await _enregistrerDansAPI(seance);
    new_ = true;
  }

  Future<void> _enregistrerDansFirestore(Seance seance) async {
    // Étape 1 : Enregistrer la séance dans Firestore
    final seanceData = <String, dynamic>{
      'id': seance.id,
      'id_user': await SharedPreferencesHelper.getUserId(),
      'type_exercice': seance.typeExercice,
      'duree': seance.duree.inMinutes,
      'caloriesbrulees': roundToDecimalPlaces(seance.caloriesBrulees, 2),
      'valeur_realisee': roundToDecimalPlaces(seance.valeurRealisee, 4),
      'unite': seance.unite,
      'notes': seance.notes,
      'timestamp': FieldValue.serverTimestamp(),
      'suivi_gps': seance.suiviGps,
      'accel_data': seance.accelData
    };

    await _firestore.collection('sessions').add(seanceData).then(
          (DocumentReference doc) => print('DocumentSnapshot ajouté avec l\'ID: ${doc.id}'),
    ).catchError((error) {
      throw Exception('Erreur lors de l\'ajout de la séance dans Firestore: $error');
    });

    // Étape 2 : Mettre à jour les objectifs en cours
    final objectifsQuery = await _firestore.collection('Objectifs')
        .where('id_user', isEqualTo: seance.userId)
        .where('type_objectif', isEqualTo: seance.typeExercice)
        .where('statut', isEqualTo: 'En cours')
        .get();
    for (var objectifDoc in objectifsQuery.docs) {


      final objectifData = objectifDoc.data();

      final valeurCible = objectifData['valeur_cible'] as double;

      final progres = objectifData['progres'];
      print("Mise a jours objectif ..... ");
      final nouvelleValeurRealisee = ((valeurCible * progres) / 100) + seance.valeurRealisee;
      final nouveauProgres = (nouvelleValeurRealisee / valeurCible) * 100;


      // Mettre à jour l'objectif avec le nouveau progrès dans Firestore
      await _firestore.collection('Objectifs').doc(objectifDoc.id).update({
        'progres': nouveauProgres > 100 ? 100 : roundToDecimalPlaces(nouveauProgres, 2),
        'statut': nouveauProgres >= 100 ? 'Atteint' : 'En cours',
      });
      print('Objectif avec ID ${objectifData['_id']} mis à jour avec succès dans Firestore');
      // Mettre à jour l'objectif dans l'API
      final objectifId = objectifData['_id']; // Assurez-vous que l'_id est présent dans Firestore
      var updateUrl = Uri.parse('$baseUrl/api/goals/$objectifId');

      var updateData = {
        'progres': nouveauProgres > 100 ? 100 : roundToDecimalPlaces(nouveauProgres, 2),
        'statut': nouveauProgres >= 100 ? 'Atteint' : 'En cours',
      };

      try {
        var response = await http.put(
          updateUrl,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(updateData),
        );

        if (response.statusCode == 200) {
          print('Objectif avec ID $objectifId mis à jour avec succès dans l\'API');
        } else {
          print('Erreur lors de la mise à jour de l\'objectif avec ID $objectifId via l\'API');
        }
      } catch (e) {
        print('Erreur lors de la connexion à l\'API: $e');
      }
    }

  }

  Future<void> _enregistrerDansAPI(Seance seance) async {
    // Étape 1 : Configurer l'URL de l'API REST pour l'enregistrement de la séance
    var url = Uri.parse('$baseUrl/api/sessions/');

    // Convertir les données de la séance en JSON
    var seanceData = {
      'id': seance.id,
      'id_user': await SharedPreferencesHelper.getUserId(),
      'type_exercice': seance.typeExercice,
      'duree': seance.duree.inMinutes,
      'caloriesbrulees': roundToDecimalPlaces(seance.caloriesBrulees, 2).toString(),
      'valeur_realisee': roundToDecimalPlaces(seance.valeurRealisee, 4).toString(),
      'unite': seance.unite,
      'notes': seance.notes,
      'suivi_gps': seance.suiviGps != null
          ? '${seance.suiviGps!['latitude'] ?? '0.0'},${seance.suiviGps!['longitude'] ?? '0.0'}'
          : '0.0,0.0',
      'accel_data': seance.accelData != null
          ? [
        (seance.accelData!['x'] ?? 0).toInt().clamp(0, double.maxFinite).toString(),
        (seance.accelData!['y'] ?? 0).toInt().clamp(0, double.maxFinite).toString(),
        (seance.accelData!['z'] ?? 0).toInt().clamp(0, double.maxFinite).toString(),
      ]
          : ['0', '0', '0'],
    };

    try {
      // Envoyer les informations de la séance à l'API REST
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(seanceData),
      );

      if (response.statusCode == 200) {
        print('Séance enregistrée dans l\'API avec succès');

        }  else {
        throw Exception('Erreur lors de l\'enregistrement de la séance via l\'API');
      }
    } catch (e) {
      throw Exception('Erreur lors de la connexion à l\'API: $e');
    }
  }


  double roundToDecimalPlaces(double value, int decimalPlaces) {
    int factor = pow(10, decimalPlaces) as int;
    return (value * factor).round() / factor;
  }

  void main() {
    double value = 3.14159;
    double roundedValue = roundToDecimalPlaces(value, 2); // 3.14
    print(roundedValue);
  }

}
