import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/Authentification/welcome.dart';
import 'Authentification/home.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();
  // Ip:port de votre serveur REST API
  await prefs.setString('baseUrl', 'http://192.168.43.190:3000');
  await prefs.setString('ip', '192.168.43.190:3000');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App',
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        // Decides which screen to show initially
        // Replace with actual parameters if needed
        '/authentication': (context) => WelcomePage(),
        // Authentication screen
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  static String? userId;
  Future<String?> _getUserId() async {
    userId = await SharedPreferencesHelper.getUserId();
    return null;
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            print("WELCOMW PAGE ${SharedPreferencesHelper.getUserId()}");

            return WelcomePage();
          } else {
            // Extract user details
            final String? name = user.displayName;
            final String? email = user.email;
            final String uid = user.uid;
            final String? photoURL = user.photoURL;

            // Retrieve the `id` from your backend or Firestore, assuming it matches `uid`
            // For now, let's assume it's the same as `uid`
            _getUserId();
            // Pass these parameters to HomeScreen
            print("HOME SCREEN $userId");
            return HomeScreen(
              name: name,
              email: email,
              uid: uid,
              photoURL: photoURL,
              id: userId,
            );
          }
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}


