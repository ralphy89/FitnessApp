import 'package:flutter/material.dart';
import 'seance_model.dart';
import 'seance_service.dart';

class EnregistrementManuelScreen extends StatefulWidget {
  final String uid;

  const EnregistrementManuelScreen({super.key, required this.uid});

  @override
  _EnregistrementManuelScreenState createState() => _EnregistrementManuelScreenState(uid);
}

class _EnregistrementManuelScreenState extends State<EnregistrementManuelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _typeExerciceController = TextEditingController();
  final _dureeController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _valeurRealiseController = TextEditingController();
  final _uniteController = TextEditingController();
  final _notesController = TextEditingController();
  final SeanceService _seanceService = SeanceService();
  final uid;
  String? _selectedTypeExercice;
  String? _selectedUnite;

  _EnregistrementManuelScreenState(this.uid);

  void _enregistrerSeance() async {
    if (_formKey.currentState?.validate() ?? false) {
      final seance = Seance(
        id: 'unique-id', // Generate a unique ID here
        userId: this.uid, // Retrieve this from the logged-in user context
        typeExercice: _selectedTypeExercice ?? 'Other',
        duree: Duration(minutes: int.parse(_dureeController.text)),
        caloriesBrulees: double.parse(_caloriesController.text),
        valeurRealisee: double.parse(_valeurRealiseController.text),
        unite: _selectedUnite ?? 'other',
        notes: _notesController.text,
      );

      try {
        await _seanceService.enregistrerSeance(seance);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session saved successfully'), backgroundColor: Colors.green,));
        // Optionally, navigate back or reset the form
        Navigator.pop(context);
      } catch (e) {
        const SnackBar(content: Text('Session save'), backgroundColor: Colors.orange,);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enregistrement Manuel')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Type d'exercice Dropdown
              DropdownButtonFormField<String>(
                value: _selectedTypeExercice,
                hint: const Text('Choisissez un type d\'exercice'),
                items: <String>['Running', 'Cycling', 'Swimming', 'Weightlifting', 'Yoga', 'Other']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTypeExercice = newValue;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Type d\'exercice',
                  prefixIcon: Icon(Icons.fitness_center),
                ),
              ),
              const SizedBox(height: 16),
              // Durée TextField
              TextFormField(
                controller: _dureeController,
                decoration: const InputDecoration(
                  labelText: 'Durée (en minutes)',
                  prefixIcon: Icon(Icons.timer),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null) {
                    return 'Veuillez entrer une durée valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Calories brûlées TextField
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(
                  labelText: 'Calories brûlées',
                  prefixIcon: Icon(Icons.local_fire_department),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide de calories';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Valeur Réalisée TextField
              TextFormField(
                controller: _valeurRealiseController,
                decoration: const InputDecoration(
                  labelText: 'Valeur Réalisée',
                  prefixIcon: Icon(Icons.assessment),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Veuillez entrer une valeur réalisée valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Unité Dropdown
              DropdownButtonFormField<String>(
                value: _selectedUnite,
                hint: const Text('Choisissez une unité'),
                items: <String>['km', 'minutes', 'calories', 'kg', 'repetitions', 'autre']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedUnite = newValue;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Unité',
                  prefixIcon: Icon(Icons.score),
                ),
              ),
              const SizedBox(height: 16),
              // Notes TextField
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                  _enregistrerSeance,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.green,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, color: Colors.white, size: 30),
                    SizedBox(width: 10),
                    Text('Terminer', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
