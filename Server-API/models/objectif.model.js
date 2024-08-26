const mongoose = require('mongoose');
const { Schema, ObjectId } = mongoose;

const ObjectifSchema = new Schema({
    id_objectif: {
        type: ObjectId,   // Utilisation de ObjectId pour identifier de manière unique chaque objectif
        auto: true        // Auto-génération de l'ObjectId
    },
    id_user: {
        type: ObjectId,   // Référence à l'utilisateur qui a défini l'objectif
        ref: 'User',      // Relie l'objectif à la collection 'User'
        required: true    // Oblige la présence de l'utilisateur
    },
    type_objectif: {
        type: String,
        required: [true, "Please specify the type of objective"], // Message d'erreur si le type d'objectif n'est pas fourni
        enum: ['Running', 'Cycling', 'Swimming', 'Weightlifting', 'Yoga', 'Other'], // Liste des types d'objectifs possibles
        default: 'Autre' // Valeur par défaut si aucun type d'objectif n'est spécifié
    },
    titre:{
        type: String,
        required: [true, "Please specify the title of the objective"],
        trim: true // Supprime les espaces en début et fin de chaîne
    },
    valeur_cible: {
        type: Number,
        required: [true, "Please enter the target value for the objective"], // Message d'erreur si la valeur cible n'est pas fournie
        min: [1, "Target value must be at least 1"], // Valeur minimale
    },
    unite: {
        type: String,
        required: [true, "Please specify the unit for the target value"], // Message d'erreur si l'unité n'est pas fournie
        enum: ['km', 'minutes', 'calories', 'kg', 'repetitions', 'autre'], // Liste des unités possibles
        default: 'autre' // Valeur par défaut si aucune unité n'est spécifiée
    },
    date_debut: {
        type: Date,
        required: [true, "Please specify the start date for the objective"], // Message d'erreur si la date de début n'est pas fournie
    },
    date_fin: {
        type: Date,
        required: [true, "Please specify the end date for the objective"], // Message d'erreur si la date de fin n'est pas fournie
        validate: {
            validator: function (value) {
                // Validation pour s'assurer que la date de fin est postérieure à la date de début
                return value > this.date_debut;
            },
            message: "End date must be after the start date."
        }
    },
    progres: {
        type: Number,
        default: 0, // Progression initiale est de 0
        min: [0, "Progress cannot be negative"], // Validation pour s'assurer que la progression n'est pas négative
        max: [100, "Progress cannot exceed 100%"] // Validation pour s'assurer que la progression ne dépasse pas 100%
    },
    statut: {
        type: String,
        enum: ['En cours', 'Atteint', 'Echoué'], // Liste des statuts possibles pour l'objectif
        default: 'En cours' // Valeur par défaut : l'objectif est en cours
    }
},

    {
        timestamps: true // Active les champs `createdAt` et `updatedAt` automatiquement
    }
);

const Objectif = mongoose.model('Objectif', ObjectifSchema);

module.exports = Objectif;
