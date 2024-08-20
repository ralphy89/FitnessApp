
const mongoose = require('mongoose');
const { Schema, ObjectId } = mongoose;

const UserSchema = new Schema({
    id_user: {
        type: ObjectId,  // Utilisation de ObjectId pour identifier de manière unique chaque utilisateur
        auto: true       // Auto-génération de l'ObjectId
    },
    nom: {
        type: String,
        required: [true, "Please enter your name"], // Message d'erreur personnalisé si le nom n'est pas fourni
        trim: true      // Suppression des espaces en début et en fin de chaîne
    },
    email: {
        type: String,
        required: [true, "Please enter your email"], // Message d'erreur personnalisé si l'email n'est pas fourni
        unique: true,    // Assure que l'email est unique dans la collection
        lowercase: true, // Convertit l'email en minuscule avant de le stocker
        trim: true,      // Suppression des espaces en début et en fin de chaîne
        match: [/.+\@.+\..+/, "Please enter a valid email address"] // Validation basique du format de l'email
    },
    password: {
        type: String,
        required: [true, "Please enter your password"], // Message d'erreur personnalisé si le mot de passe n'est pas fourni
        minlength: [6, "Password must be at least 6 characters long"] // Longueur minimale pour le mot de passe
    },
    auth_via: {
        type: String,
        enum: ['Email', 'google', 'facebook'], // Liste des valeurs possibles pour le mode d'authentification
        default: 'Email'                       // Valeur par défaut pour le mode d'authentification
    },
    weight: {
        type: Number,
        default: 0,         // Poids par défaut est de 0
        min: [0, "Weight cannot be negative"] // Validation pour s'assurer que le poids n'est pas négatif
    },
    age: {
        type: Number,
        default: 0,         // Âge par défaut est de 0
        min: [0, "Age cannot be negative"]    // Validation pour s'assurer que l'âge n'est pas négatif
    }
},
{
    timestamps: true // Active les champs `createdAt` et `updatedAt` automatiquement
});

const User = mongoose.model('User', UserSchema);

module.exports = User;
