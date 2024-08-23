import 'dart:convert';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/Authentification/signUp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../components/button.dart';
import '../components/square_tile.dart';
import '../firebase_options.dart';
import 'home.dart'; // Assurez-vous que le chemin est correct
import 'package:http/http.dart' as http;
class WelcomePage extends StatelessWidget {

  WelcomePage({super.key});
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);

    // Once signed in, return the UserCredential
    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }

  void handleSignIn(BuildContext context, String fournisseur) async {
    try {
      User? user;
      bool isNewUser = false;
      String? userId;
      if (fournisseur == 'google') {
        UserCredential user_info = await signInWithGoogle();
        isNewUser = user_info.additionalUserInfo?.isNewUser ?? false;
        user = user_info.user;
      } else {
        UserCredential user_info = await signInWithFacebook();
        isNewUser = user_info.additionalUserInfo?.isNewUser ?? false;
        user = user_info.user;
      }

      if (user != null) {

        String? name = user.displayName;
        String? email = user.email;
        String? uid = user.uid;
        String? photoURL = user.photoURL;



        // Print user info (for debugging)
        print("Nom de l'utilisateur : $name");
        print("Email de l'utilisateur : $email");
        print("UID de l'utilisateur : $uid");
        print("Photo de profil : $photoURL");

        if (isNewUser) {
          print("Nouvelle inscription de l'utilisateur : $name");
          // Actions spécifiques pour les nouveaux utilisateurs
          // Créer un objet JSON avec les informations utilisateur
          Map<String, dynamic> userData = {
            "nom": name,
            "email": email,
            "uid": uid,
            "photoURL": photoURL,
            "auth_via":fournisseur,
            "password":"yuiyruhbiueug"
          };

          // Configurer l'URL de l'API REST
          var url = Uri.http('192.168.43.190:3000', '/api/users/');

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
            userId = jsonResponse["_id"];
            print('User ID: $userId');

            // Vous pouvez maintenant utiliser cet identifiant comme vous le souhaitez
          }

        } else {
          print("Connexion d'un utilisateur existant : $name");
          // Actions spécifiques pour les utilisateurs existants
        }

        // Navigate to home.dart and pass the user information
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              name: name,
              email: email,
              uid: uid,
              photoURL: photoURL,
              id: userId
            ),
          ),
        );
      } else {
        print('La connexion a été annulée.');
      }
    } catch (e) {
      print('La connexion Google a échoué : $e');
      // Gérer l'erreur de connexion
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Stack(
        children: [
          // Image d'arrière-plan
          Positioned.fill(
            child: Image.network(
              'https://mfiles.alphacoders.com/698/thumb-1920-698238.jpg', // Remplacez l'URL par le chemin de votre image locale ou une autre URL
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
                    SizedBox(height: MediaQuery.of(context).size.height * 0.10),

                    const Text("Hi, welcome !",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold)
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                    ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              // Champ de texte pour l'email
                              TextField(
                                controller: _emailController,
                                decoration: InputDecoration(

                                  labelText: 'Email',
                                  labelStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                
                              // Champ de texte pour le mot de passe
                              TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                
                              // Bouton "Continue" personnalisé
                              MyButton(
                                onTap: () async {
                                  // Retrieve the email and password from the text fields
                                  String email = _emailController.text.trim();
                                  String password = _passwordController.text.trim();

                                  // Basic validation
                                  if (email.isEmpty || password.isEmpty) {
                                    // Show a message to the user if fields are empty
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please enter both email and password'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
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
                                        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                                          email: email,
                                          password: password,
                                        );

                                        // If sign-in is successful, you can navigate to another page or show a success message
                                        // For example:
                                        // Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                                      } on FirebaseAuthException catch (e) {
                                        String errorMessage = '';

                                        if (e.code == 'user-not-found') {
                                          errorMessage = 'No user found for that email.';
                                        } else if (e.code == 'wrong-password') {
                                          errorMessage = 'Wrong password provided .';
                                        } else {
                                          errorMessage = 'An error occurred. Please try again.';
                                        }

                                        // Show the error message using a Snackbar
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(errorMessage),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }

                                    print('Validation passed, proceed further');
                                    // Navigate to the next page or perform the sign-in action
                                  }
                                },
                                child: const Text(
                                  "Continue",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                
                              const SizedBox(height: 10),
                
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      thickness: 0.5,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Text(
                                      'Or',
                                      style: TextStyle(color: Colors.white, fontSize: 16),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      thickness: 0.5,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Bouton Facebook
                                    SquareTile(
                                      imagePath: 'assets/images/facebook.png',
                                      title: "Continue with Facebook",
                                      onTap: () async {
                                          handleSignIn(context, 'facebook');
                                        },
                                    ),
                                    const SizedBox(height: 10),
                
                                    // Bouton Google
                                    SquareTile(
                                      imagePath: 'assets/images/google.png',
                                      title: "Continue with Google", onTap: () async {
                                          handleSignIn(context, 'google');
                                        },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Don\'t have an account?',
                                          style: TextStyle(color: Colors.white, fontSize: 16),
                                          textAlign: TextAlign.start,
                                        ),
                                        const SizedBox(width: 4),
                                        InkWell(
                                          onTap: (){
                                            print('Sign up clicked');
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => SignUpPage(),
                                            ));
                                          },
                                          child: const Text(
                                            'Sign Up',
                                            style: TextStyle(
                                              color: Color.fromARGB(255, 71, 233, 133),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                            ),
                                          ),
                                        )
                
                                      ],
                                    ),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.01,
                                    ),
                                    const Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 71, 233, 133),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ],
                                ),
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

