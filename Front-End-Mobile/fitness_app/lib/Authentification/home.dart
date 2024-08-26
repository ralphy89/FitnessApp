import 'dart:convert';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/Authentification/welcome.dart';
import 'package:fitness_app/seance/suivi_automatic_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../seance/seance_historique.dart';
import '../seance/seance_model.dart';
import '../seance/seance_service.dart';
import '../seance/suivi_automatic.dart';
import '../seance/suivi_manuel.dart';
import 'package:fl_chart/fl_chart.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {


  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Tracking App',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        visualDensity: VisualDensity.adaptivePlatformDensity,

      ),
      home: const HomeScreen(
        name: 'John Doe',
        email: 'john.doe@example.com',
        uid: '123456789',
        photoURL: 'https://example.com/photo.jpg',
        id: 'user_id',
      ),
    );
  }
}



class HomeScreen extends StatefulWidget {
  final String? name;
  final String? email;
  final String? uid;
  final String? photoURL;
  final String? id;
  const HomeScreen({
    super.key,
    this.uid,
    required this.id,
    required this.name,
    required this.email,
    required this.photoURL,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

    final PageController _pageController = PageController();
    int _selectedIndex = 0;
    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
      _pageController.jumpToPage(index);
    }

    late Future<List<dynamic>> _goalsFuture = _fetchGoals();
    late TextEditingController startDateController;
    late TextEditingController endDateController;
    late String startDateText;
    late String endDateText;
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now();

    @override
    void initState() {
      super.initState();
      startDateController = TextEditingController(
        text: startDate.toLocal().toString().split(' ')[0],
      );
      endDateController = TextEditingController(
        text: endDate.toLocal().toString().split(' ')[0],
      );
      _goalsFuture = _fetchGoals();
      startDateText = startDate.toLocal().toString().split(' ')[0];
      endDateText = endDate.toLocal().toString().split(' ')[0];
    }

    @override
    void dispose() {
      startDateController.dispose();
      endDateController.dispose();
      super.dispose();
    }


    Future<void> _refreshGoals() async {
      setState(() {
        _goalsFuture = _fetchGoals();
      });
    }
    Future<List<dynamic>> _fetchGoals() async {
      try {

        // Attempt to fetch goals from Firestore, ordered by start date in descending order
        final goalsSnapshot = await FirebaseFirestore.instance
            .collection('Objectifs')
            .where('id_user', isEqualTo: await SharedPreferencesHelper.getUserId()
        )
            .orderBy('date_debut', descending: false) // Order by start date descending
            .get();

        if (goalsSnapshot.docs.isNotEmpty) {
          print('Fetch goals from Firestore');
          print(goalsSnapshot.docs.map((doc) => doc.data()).toList());
          // Convert Firestore documents to a list of goals
          return goalsSnapshot.docs.map((doc) => doc.data()).toList();
        }
      } catch (e) {
        print('Error fetching goals from Firestore: $e');
      }

      try {
        final prefs = await SharedPreferences.getInstance();
        // If Firestore fails or returns no data, fallback to the API
        final response = await http.get(Uri.parse('${await prefs.getString('baseUrl')}/api/goals/for/${widget.id}'));
        print("Goals Api Response : ${response.body}");
        if (response.statusCode == 200) {
          print('Fetching goals from API');
          final data = json.decode(response.body);
          data.sort((b, a) => DateTime.parse(b['date_debut']).compareTo(DateTime.parse(a['date_debut'])));
          return data;
        } else {
          throw Exception('Failed to load goals from API');
        }
      } catch (e) {
        print('Error fetching goals from API: $e');
        throw Exception('Failed to load goals from both Firestore and API');
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.photoURL ?? 'https://via.placeholder.com/150'),
                radius: 20,
              ),
              const SizedBox(width: 10),
              Text(widget.name ?? 'Nom utilisateur'),
              Spacer(),
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () {
                  // Afficher les notifications
                },
              ),
              // Ajouter un affichage du dernier badge ici si nécessaire
            ],
          ),
          backgroundColor: Colors.green,
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: [
            _buildHomeContent(),
            TrackingScreen(uid: widget.id ?? 'Unknown UID'),
            const StatisticsScreen(),
            ProfileScreen(userId: widget.id ?? '', photoURL: widget.photoURL ?? '', ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          unselectedItemColor: Colors.grey,
          unselectedLabelStyle: const TextStyle(color: Colors.grey),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_run),
              label: 'Suivi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Statistiques',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.green,
          onTap: _onItemTapped,
        ),
        floatingActionButton: _selectedIndex == 0
            ? FloatingActionButton(
          onPressed: () {
            _showAddGoalDialog(context);
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.add),
        )
            : null, // No floating button on other pages
      );
    }

    void _showAddGoalDialog(BuildContext context) {

      String? title;
      String? type;
      double? targetValue;
      String? unit;


      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text('Définir un Objectif'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      icon: Icon(Icons.title),
                      labelText: 'Titre',
                    ),
                    onChanged: (value) {
                      title = value;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      icon: Icon(Icons.category),
                      labelText: 'Type d\'Objectif',
                    ),
                    items: <String>['Running', 'Cycling', 'Swimming', 'Weightlifting', 'Yoga', 'Other'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      type = value;
                    },
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      icon: Icon(Icons.flag),
                      labelText: 'Valeur Cible',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      targetValue = double.parse(value);
                    },
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      icon: Icon(Icons.category),
                      labelText: 'Unité',
                    ),
                    items: <String>['km', 'minutes', 'calories', 'kg', 'repetitions', 'other'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      unit = value;
                    },
                  ),
                  TextField(
                    controller: startDateController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.date_range),
                      labelText: 'Date de Début',
                    ),
                    readOnly: true, // Prevent user from typing in the field
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != startDate) {
                        setState(() {
                          startDate = pickedDate;
                          startDateController.text = startDate.toLocal().toString().split(' ')[0];
                        });
                      }
                    },
                  ),
                  TextField(
                    controller: endDateController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.date_range),
                      labelText: 'Date de Fin',
                    ),
                    readOnly: true, // Prevent user from typing in the field
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: endDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != endDate) {
                        setState(() {
                          endDate = pickedDate;
                          endDateController.text = endDate.toLocal().toString().split(' ')[0];
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Annuler'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(

                onPressed: () {
                  // Call function to save to Firestore and your API
                  _saveGoalToFirestoreAndAPI(

                    title: title!,
                    type: type!,
                    targetValue: targetValue!,
                    unit: unit!,
                    startDate: startDate!,
                    endDate: endDate!,
                  );
                  _refreshGoals();
                  Navigator.of(context).pop();
                  _refreshGoals();
                },
                autofocus: true,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent
                ),
                child: const Text('Sauvegarder'),
              ),
            ],
          );
        },
      );
    }

    void _saveGoalToFirestoreAndAPI({
      required String title,
      required String type,
      required double targetValue,
      required String unit,
      required DateTime startDate,
      required DateTime endDate,
    }) async {
      try {
        // Save to API
        final prefs = await SharedPreferences.getInstance();
        final response = await http.post(
          Uri.parse('${prefs.getString('baseUrl')}/api/goals'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'id_user': '${widget.id}',
            'titre': title,
            'type_objectif': type,
            'valeur_cible': targetValue,
            'unite': unit,
            'date_debut': startDate.toIso8601String(),
            'date_fin': endDate.toIso8601String(),
            'progres': 0
          }),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final apiId = responseData['_id']; // Assuming the API returns the ID as '_id'

          // Save to Firestore
          await FirebaseFirestore.instance.collection('Objectifs').add({
            'id_user': '${widget.id}',
            'titre': title,
            'type_objectif': type,
            'valeur_cible': targetValue,
            'unite': unit,
            'date_debut': startDate.toIso8601String(),
            'date_fin': endDate.toIso8601String(),
            'progres': 0,
            '_id': apiId, // Save the API ID in Firestore
            'statut': "En cours"
          });

          print("Goal saved successfully to Firestore and API");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Goal saved successfully'), backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur! Veuillez réessayer plus tard'), backgroundColor: Colors.red),
          );
          print('Failed to save goal to API');
          print(response.body);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la sauvegarde de l\'objectif'), backgroundColor: Colors.red),
        );
        print('Error: $e');
      }

    }

    void _showEditGoalPopup(Map<String, dynamic> goalData) {
      TextEditingController titleController = TextEditingController(text: goalData['titre']);
      TextEditingController typeController = TextEditingController(text: goalData['type_objectif']);
      TextEditingController targetValueController = TextEditingController(text: goalData['valeur_cible'].toString());
      TextEditingController unitController = TextEditingController(text: goalData['unite']);
      DateTime startDate = DateTime.parse(goalData['date_debut']);
      DateTime endDate = DateTime.parse(goalData['date_fin']);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Modifier l'objectif"),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Champs du formulaire
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: "Titre"),
                  ),
                  TextField(
                    controller: typeController,
                    decoration: const InputDecoration(labelText: "Type d'objectif"),
                  ),
                  TextField(
                    controller: targetValueController,
                    decoration: const InputDecoration(labelText: "Valeur cible"),
                  ),
                  TextField(
                    controller: unitController,
                    decoration: const InputDecoration(labelText: "Unité"),
                  ),
                  // Sélecteurs de date
                  TextField(
                    controller: startDateController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.date_range),
                      labelText: 'Date de Début',
                    ),
                    readOnly: true, // Empêche la modification manuelle du champ
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          startDate = pickedDate;
                          startDateController.text = startDate.toLocal().toString().split(' ')[0];
                        });
                      }
                    },
                  ),
                  TextField(
                    controller: endDateController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.date_range),
                      labelText: 'Date de Fin',
                    ),
                    readOnly: true, // Empêche la modification manuelle du champ
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: endDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          endDate = pickedDate;
                          endDateController.text = endDate.toLocal().toString().split(' ')[0];
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () {
                  double x = (goalData['valeur_cible'] * goalData['progres'])/100;
                  _updateGoalToFirestoreAndAPI(
                    id: goalData['_id'], // Passer l'_id ici
                    title: titleController.text,
                    type: typeController.text,
                    targetValue: double.parse(targetValueController.text),
                    unit: unitController.text,
                    startDate: startDate,
                    endDate: endDate,
                    progres: x / double.parse(targetValueController.text),
                  );
                  Navigator.of(context).pop();
                },
                child: const Text("Modifier"),
              ),
            ],
          );
        },
      );
    }

    Future<void> _updateGoalToFirestoreAndAPI({
      required String id,
      required String title,
      required String type,
      required double targetValue,
      required String unit,
      required DateTime startDate,
      required DateTime endDate,
      required progres
    }) async {
      // Query Firestore to find the document with the _id
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Objectifs')
          .where('_id', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Handle the case where no document was found
        print("No document found with _id: $id");
        return;
      }

      // Get the document ID from the query result
      final documentId = querySnapshot.docs.first.id;

      // Update the document
      await FirebaseFirestore.instance.collection('Objectifs').doc(documentId).update({
        'titre': title,
        'type_objectif': type,
        'valeur_cible': targetValue,
        'unite': unit,
        'date_debut': startDate.toIso8601String(),
        'date_fin': endDate.toIso8601String(),
        'progres': progres,
      });

      print("Goal updated successfully in Firestore");

      // Mettre à jour dans l'API
      final prefs = await SharedPreferences.getInstance();
      final response = await http.put(
        Uri.parse('${await prefs.getString('baseUrl')}/api/goals/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'titre': title,
          'type_objectif': type,
          'valeur_cible': targetValue,
          'unite': unit,
          'date_debut': startDate.toIso8601String(),
          'date_fin': endDate.toIso8601String(),
          'progres':progres
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goal updated successfully'), backgroundColor: Colors.green),
        );
        print('Goal updated successfully in API');
      } else {
        print('Failed to update goal in API');
        print(response.body);
      }
    }

    void _showDeleteGoalDialog(String id) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Supprimer l'objectif"),
            content: const Text("Êtes-vous sûr de vouloir supprimer cet objectif ? Cette action est irréversible."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Ferme le dialog sans faire d'action
                },
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // Supprimer de Firestore
                    await _deleteGoalFromFirestore(id);

                    // Supprimer de l'API
                    await _deleteGoalFromAPI(id);
                    _refreshGoals();
                    // Afficher un message de succès
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Objectif supprimé avec succès'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // Fermer le dialog
                    Navigator.of(context).pop();
                  } catch (e) {
                    // Afficher un message d'erreur
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erreur lors de la suppression de l\'objectif'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text("Supprimer"),
              ),
            ],
          );
        },
      );
    }

    Future<void> _deleteGoalFromFirestore(String id) async {
      // Rechercher le document avec le _id donné
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Objectifs')
          .where('_id', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Aucun document trouvé avec _id: $id');
      }

      final documentId = querySnapshot.docs.first.id;

      // Supprimer le document
      await FirebaseFirestore.instance.collection('Objectifs').doc(documentId).delete();
      print("Document supprimé avec succès de Firestore");
    }

    Future<void> _deleteGoalFromAPI(String id) async {
      final prefs = await SharedPreferences.getInstance();
      final response = await http.delete(
        Uri.parse('${await prefs.getString('baseUrl')}/api/goals/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print("Objectif supprimé avec succès de l'API");
      } else {
        throw Exception('Échec de la suppression de l\'objectif de l\'API');
      }
    }


    Widget _buildHomeContent() {

     return FutureBuilder<List<dynamic>>(
      future: _goalsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Erreur de chargement des objectifs'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Aucun objectif trouvé.'));
        }

        final goals = snapshot.data!;

        return ListView.builder(
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goal = goals[index];

            return _buildGoalCard(
                title: '${goal['titre']}',
                targetValue: goal['valeur_cible']/1,
                currentValue: 0.0,
                unit: '${goal['unite']}',
                startDate: DateTime.parse(goal['date_debut']),
                endDate: DateTime.parse(goal['date_fin']),
                objectiveType: '${goal['type_objectif']}',
                progres: goal['progres']/1,
                id_objectif: goal['_id']
            );
          },
        );
      },
    );
  }

    double calculateProgress(double currentValue, double targetValue) {
      return (currentValue / targetValue) * 100;
    }

  Widget _buildGoalCard({
    required String title,
    required double targetValue,
    required double currentValue,
    required String unit,
    required DateTime startDate,
    required DateTime endDate,
    required String objectiveType,
    required double progres,
    required id_objectif,
  }) {
    double progress = 0.0;
    if(progres == 0) {
      progress = calculateProgress(currentValue, targetValue);
    } else {
      progress = progres;
    }
    final progressPercentage = progress.clamp(0.0, 100.0); // Ensure progress is within 0-100%

    return Card(
      borderOnForeground: true,
      margin: const EdgeInsets.all(10.0),
      elevation: 5, // Add shadow for depth
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
        // Rounded corners
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(

              children: [
                const Icon(
                  Icons.double_arrow_outlined, // Example icon for the goal
                  color: Colors.blueAccent,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,

                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

           Row(
              children: [
                const Icon(Icons.task_alt, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Type: $objectiveType',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.flag_circle_rounded, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Cible: $targetValue $unit',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timeline, color: Colors.purple, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Progression: ${progressPercentage.toStringAsFixed(2)}%',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: Colors.blueGrey, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Date de début: ${startDate.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.blueGrey, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Date de fin: ${endDate.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[300],
              ),
              child: Stack(
                children: [
                  Container(
                    width: progressPercentage * 2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Map<String, dynamic> goalData = {
                      'titre': title,                          // The title of the goal
                      'valeur_cible': targetValue,              // The target value for the goal
                      'currentValue': currentValue,            // The current value achieved towards the goal
                      'unite': unit,                            // The unit of measurement for the goal (e.g., 'km', 'minutes')
                      'date_debut': startDate.toIso8601String(),                  // The start date of the goal
                      'date_fin': endDate.toIso8601String(),                      // The end date of the goal
                      'type_objectif': objectiveType,          // The type of the objective (e.g., 'Distance', 'Calories')
                      'progres': progres,                      // The progress made towards the goal as a percentage
                      '_id': id_objectif,              // The unique identifier for the goal (from Firestore/API)
                    };
                    print(goalData);
                    _showEditGoalPopup(goalData);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Modifier'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Action pour supprimer l'objectif
                    _showDeleteGoalDialog(id_objectif);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.delete, size: 18),
                      SizedBox(width: 8),
                      Text('Supprimer'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class TrackingScreen extends StatelessWidget {
  final String uid;

  const TrackingScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white54,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/images/train_img_1.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Commencer une séance:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EnregistrementManuelScreen(uid: uid),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.orangeAccent,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit, size: 30),
                  SizedBox(width: 10),
                  Text('Manuel', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AutomaticTrackingScreen(uid: uid),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_run, size: 30),
                  SizedBox(width: 10),
                  Text('Automatique', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SessionHistoryScreen(uid: uid),
            ),
          );
        },
        backgroundColor: Colors.orangeAccent,
        child: const Icon(Icons.history),
        tooltip: 'Voir l\'historique des séances',
      ),
    );
  }
}


class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Écran de Statistiques: Progrès avec graphiques'),
    );
  }
}



class ProfileScreen extends StatefulWidget {
  final String userId;
  final String photoURL;

  const ProfileScreen({super.key, required this.userId, required this.photoURL});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _weightController;
  late TextEditingController _ageController;
  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _weightController = TextEditingController();
    _ageController = TextEditingController();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final url = Uri.parse('${await prefs.getString('baseUrl')}/api/users/${await SharedPreferencesHelper.getUserId()}');
   print(url);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _nameController.text = data['nom'];
          _emailController.text = data['email'];
          _weightController.text = data['weight'].toString();
          _ageController.text = data['age'].toString();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final url = Uri.parse('${prefs.getString('baseUrl')}/api/users/${await SharedPreferencesHelper.getUserId()}');
    final updatedData = {
      'nom': _nameController.text,
      'weight': int.tryParse(_weightController.text) ?? 0,
      'age': int.tryParse(_ageController.text) ?? 0,
      // Note: 'email' is not included here to prevent modification
    };

    setState(() {
      _isUpdating = true;
    });

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(updatedData),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès'), backgroundColor: Colors.green,),
        );
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour du profil: $e')),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }


  Future<void> _logOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Clear the _id from SharedPreferences
      await SharedPreferencesHelper.removeUserId();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Déconnexion réussie')),
      );
      // Navigate to login screen or home screen after logout
      Navigator.pushReplacementNamed(context, '/authentication'); // replace with your route
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la déconnexion: $e')),
      );
    }
  }


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.photoURL),
              radius: 60,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _nameController,
              label: 'Nom',
              icon: Icons.person,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
              enabled: false, // Prevent email modification
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _weightController,
              label: 'Poids (kg)',
              icon: Icons.monitor_weight,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _ageController,
              label: 'Âge',
              icon: Icons.calendar_today,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _isUpdating
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateUserProfile,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                child: const Text('Mettre à jour le profil'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _logOut,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                child: const Text('Se déconnecter'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
        enabled: enabled,
      ),
      keyboardType: keyboardType,
    );
  }
}





