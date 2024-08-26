
# Fitness App

## Quelques captures d'écran

<table>
  <tr>
    <td align="center">
      <img src="https://github.com/ralphy89/FitnessApp/blob/main/Screens/auth_screen.gif?raw=true" width="200">
      <p><b>Écran d'Authentification et Écran de Profil Utilisateur</b></p>
    </td>
    <td align="center">
      <img src="https://github.com/ralphy89/FitnessApp/blob/main/Screens/add_goal.gif?raw=true" width="200">
      <p><b>Définition, Suppression et Modification d'un Objectif</b></p>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://github.com/ralphy89/FitnessApp/blob/main/Screens/add_seance_manuel.gif?raw=true" width="200">
      <p><b>Enregistrement d'une Séance Manuelle et Modification de l'Objectif Lié</b></p>
    </td>
    <td align="center">
      <img src="https://github.com/ralphy89/FitnessApp/blob/main/Screens/add_seance_automatic.gif?raw=true" width="200">
      <p><b>Enregistrement d'une Séance Automatique et Affichage de l'Historique des Séances</b></p>
    </td>
  </tr>
</table>

## Instructions de Déploiement

### Prérequis

Avant de commencer, assurez-vous d'avoir les outils suivants installés :

- Une connexion internet stable
- [Flutter](https://flutter.dev/docs/get-started/install)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- Node.js et Expressjs

### Étapes d'installation

1. **Clonez le dépôt :**

   ```bash
   git clone https://github.com/ralphy89/FitnessApp.git
   cd FitnessApp
   ```

2. **Démarrez le serveur API :**

   - Accédez au répertoire `./Server-API` :
   
     ```bash
     cd Server-API
     npm run dev
     ```

3. **Lancez l'application mobile :**
   N.B dans le fichier `./lib/main.dart` il faut adapter l'ip et le port en fonction de votre serveur API (NodeJs)
  `  await prefs.setString('baseUrl', 'http://192.168.43.190:3000');
     await prefs.setString('ip', '192.168.43.190:3000'); `
   - Accédez au répertoire `./Front-End-Mobile/fitness_app` :
   
     ```bash
     cd ../Front-End-Mobile/fitness_app
     flutter pub get
     flutter run
     ```

### Notes supplémentaires

Vous pouvez créer votre propre projet Firebase/MongoDB ou utiliser mes ressources existantes. Pour plus d'informations, n'hésitez pas à me contacter à l'adresse suivante : 

- **Email** : [mytechzone89@gmail.com](mailto:mytechzone89@gmail.com)
- **Objet de l'email** : HELP FitnessApp
