import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/button.dart';
import '../components/square_tile.dart'; // Ensure the path is correct
import 'home.dart';
import 'welcome.dart';
import 'package:http/http.dart' as http;


class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  //



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              'https://mfiles.alphacoders.com/698/thumb-1920-698238.jpg', // Replace with your image URL
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.15),

                    const Text(
                      "Create an Account",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              // Text Field for Name
                              TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                  labelStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.3),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 20),
                
                              // Text Field for Email
                              TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.3),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 20),
                
                              // Text Field for Password
                              TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.3),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 20),
                
                              // Sign Up Button
                              MyButton(
                                onTap: () async {
                                  // Logic to sign up the user
                                  String email = _emailController.text.trim();
                                  String password = _passwordController.text.trim();
                                  String name = _nameController.text.trim();
                                  // Basic validation
                                  if (name.isEmpty || email.isEmpty || password.isEmpty) {
                                    // Show a message to the user if fields are empty
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please enter your name, email, and password'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } else if (name.length < 2) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Name must be at least 2 characters long'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                  else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
                                    // Email format validation
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please enter a valid email address'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } else if (password.length < 6) {
                                    // Password length validation
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Password must be at least 6 characters long'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } else {
                                    try {
                                      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                        email: email,
                                        password: password,
                                      );

                                      print("Firebase : Nouvelle inscription de l'utilisateur : $name");
                                      // Actions spécifiques pour les nouveaux utilisateurs
                                      // Créer un objet JSON avec les informations utilisateur
                                      Map<String, dynamic> userData = {
                                        "nom": name,
                                        "email": email,
                                        "auth_via":"Email",
                                        "password":password
                                      };
                                      final prefs = await SharedPreferences.getInstance();
                                      // Configurer l'URL de l'API REST
                                      var url = Uri.http('${await prefs.getString('ip')}', '/api/users/');

                                      // Envoyer les informations à l'API REST
                                      var response = await http.post(
                                        url,
                                        headers: {"Content-Type": "application/json"},
                                        body: jsonEncode(userData),
                                      );

                                      // Afficher le statut de la réponse
                                      print('Response status: ${response.statusCode}');
                                      print('Response body: ${response.body}');
                                      if (response.statusCode == 200) {
                                        // Analyse de la réponse JSON pour récupérer le champ "_id"
                                        var jsonResponse = jsonDecode(response.body);
                                        var userId = jsonResponse["_id"];
                                        print('User ID: $userId');

                                        // Vous pouvez maintenant utiliser cet identifiant comme vous le souhaitez

                                        // Navigate to home.dart and pass the user information
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => HomeScreen(
                                                name: name,
                                                email: email,
                                                uid: '',
                                                photoURL: '',
                                                id: userId
                                            ),
                                          ),
                                        );
                                      }

                                    } on FirebaseAuthException catch (e) {
                                      if (e.code == 'weak-password') {
                                        print('The password provided is too weak.');
                                      } else if (e.code == 'email-already-in-use') {
                                        print('The account already exists for that email.');
                                      }
                                    } catch (e) {
                                      print(e);
                                    }

                                  }
                                },
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                
                              // Sign up with Facebook and Google
                              Column(
                                children: [
                                  SquareTile(
                                    imagePath: 'assets/images/facebook.png',
                                    title: 'Sign up with Facebook',
                                    onTap: () async {
                                      // Add your Facebook sign-up logic here
                                      WelcomePage().handleSignIn(context, 'facebook');
                                      print("User connected!");
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  SquareTile(
                                    imagePath: 'assets/images/google.png',
                                    title: 'Sign up with Google',
                                    onTap: () async {
                                      WelcomePage().handleSignIn(context, 'google');
                                        print("User connected!");
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Already have an account?",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Navigate to the login page
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      "Log In",
                                      style: TextStyle(
                                        color: Colors.greenAccent,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension on AccessToken {
  String get token => '';
}

// extension on AccessToken {
//   String get token => '';
// }
