import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SessionHistoryScreen extends StatefulWidget {
  final String uid;

  const SessionHistoryScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _SessionHistoryScreenState createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends State<SessionHistoryScreen> {
  String? selectedType;
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des Séances'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Ouvrir un menu pour les filtres
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _buildSessionList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action pour ajouter une nouvelle session ou autre
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Type d\'exercice',
                border: OutlineInputBorder(),
              ),
              value: selectedType,
              items: const [
                DropdownMenuItem(value: 'Running', child: Text('Running')),
                DropdownMenuItem(value: 'Cycling', child: Text('Cycling')),
                DropdownMenuItem(value: 'Swimming', child: Text('Swimming')),
                DropdownMenuItem(value: 'Weightlifting', child: Text('Weightlifting')),
                DropdownMenuItem(value: 'Yoga', child: Text('Yoga')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedType = value;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: TextEditingController(
                text: selectedDate != null
                    ? DateFormat('dd MMM yyyy').format(selectedDate!)
                    : 'Choisir une date',
              ),
              decoration: const InputDecoration(
                labelText: 'Filtrer par date',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null && pickedDate != selectedDate) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sessions')
          .where('id_user', isEqualTo: widget.uid)
          .where('type_exercice', isEqualTo: selectedType) // Filtrer par type d'exercice
          .where('timestamp', isGreaterThanOrEqualTo: selectedDate != null
          ? DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day)
          : null) // Filtrer par date
          .where('timestamp', isLessThanOrEqualTo: selectedDate != null
          ? DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day, 23, 59, 59)
          : null) // Filtrer par date
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Erreur de chargement des données'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Aucune séance trouvée.'));
        }

        final sessions = snapshot.data!.docs;

        return ListView.builder(
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            final typeExercice = session['type_exercice'] ?? 'N/A';
            final timestamp = session['timestamp']?.toDate();
            final formattedDate = timestamp != null
                ? DateFormat('dd MMM yyyy, HH:mm').format(timestamp)
                : 'Date inconnue';
            final duree = session['duree']?.toString() ?? 'N/A';
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: const Icon(
                  Icons.fitness_center,
                  color: Colors.orangeAccent,
                ),
                title: Text('$typeExercice - $formattedDate'),
                subtitle: Text('Durée: $duree minutes'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        // Confirmation avant suppression
                        bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmer la suppression'),
                            content: const Text('Êtes-vous sûr de vouloir supprimer cette séance ?'),
                            actions: [
                              TextButton(
                                child: const Text('Annuler'),
                                onPressed: () => Navigator.of(context).pop(false),
                              ),
                              TextButton(
                                child: const Text('Supprimer'),
                                onPressed: () => Navigator.of(context).pop(true),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          // Supprimer la séance
                          await FirebaseFirestore.instance
                              .collection('sessions')
                              .doc(session.id)
                              .delete();
                        }
                      },
                    ),
                  ],
                ),
                onTap: () {
                  // Afficher les détails de la séance
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Détails de la séance'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Type d\'exercice: $typeExercice'),
                            Text('Valeur Réalisée : ${session['valeur_realisee']} ${session['unite']}.'),
                            Text('Calories brûlées: ${session['caloriesbrulees']}'),
                            Text('Notes: ${session['notes']}'),
                            Text('Durée: $duree minutes'),
                            Text('Date: $formattedDate'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Fermer'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            );

          },
        );
      },
    );
  }
}
