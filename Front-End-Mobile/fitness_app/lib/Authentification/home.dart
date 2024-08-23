import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String? name;
  final String? email;
  final String? uid;
  final String? photoURL;
  final String? id;
  const HomeScreen({super.key, this.name, this.email, this.uid, this.photoURL, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (photoURL != null)
              CircleAvatar(
                backgroundImage: NetworkImage(photoURL!),
                radius: 50,
              ),
            const SizedBox(height: 16),
            Text('Nom : $name'),
            Text('Email : $email'),
            Text('UID : $uid'),
            Text('_id : $id')
          ],
        ),
      ),
    );
  }
}
