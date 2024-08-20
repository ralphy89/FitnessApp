const mongoose = require('mongoose');
const { Schema, ObjectId } = mongoose;

const BadgeSchema = new Schema({
    id_badge: {
        type: ObjectId,   // Utilisation de ObjectId pour identifier de manière unique chaque badge
        auto: true        // Auto-génération de l'ObjectId
    },
    nom: {
        type: String,
        required: [true, "Veuillez entrer le nom du badge"],  // Nom du badge obligatoire
        unique: true,                                        // Chaque nom de badge doit être unique
        trim: true                                           // Suppression des espaces en début et fin de chaîne
    },
    description: {
        type: String,      // Description du badge
        maxlength: [500, "La description ne peut pas dépasser 500 caractères"] // Limite de longueur
    },
    icon: {
        type: String,      // URL ou chemin vers l'icône du badge
        required: [true, "Veuillez fournir une icône pour le badge"]
    },
    conditions: {
        type: String,      // Description des conditions nécessaires pour obtenir le badge
        required: [true, "Veuillez spécifier les conditions pour obtenir ce badge"]
    },
    
    id_user: {
        type: ObjectId,   // Référence à l'utilisateur qui a obtenu le badge
        ref: 'User',      // Relie le badge à la collection 'User'
    },
    date_obtention: {
        type: Date,       // Date à laquelle l'utilisateur a obtenu le badge
        default: Date.now // Date par défaut est la date actuelle
    }
},
    {
        timestamps: true // Active les champs `createdAt` et `updatedAt` automatiquement
    }
);

const Badge = mongoose.model('Badge', BadgeSchema);
module.exports = Badge; 
