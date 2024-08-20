const mongoose = require('mongoose');
const { Schema, ObjectId } = mongoose;

const SeanceSchema = new Schema({
    id_seance: {
        type: ObjectId,   // Utilisation de ObjectId pour identifier de manière unique chaque séance
        auto: true        // Auto-génération de l'ObjectId
    },
    id_user: {
        type: ObjectId,   // Référence à l'utilisateur qui a effectué la séance
        ref: 'User',      // Relie la séance à la collection 'User'
        required: true    // Oblige la présence de l'utilisateur
    },
    type_exercice: {
        type: String,
        required: [true, "Please specify the type of exercise"], // Message d'erreur si le type d'exercice n'est pas fourni
        enum: ['Running', 'Cycling', 'Swimming', 'Weightlifting', 'Yoga', 'Other'], // Liste des types d'exercices possibles
        default: 'Other' // Valeur par défaut si aucun type d'exercice n'est spécifié
    },
    duree: {
        type: Number,
        required: [true, "Please enter the duration of the session"], // Message d'erreur si la durée n'est pas fournie
        min: [1, "Duration must be at least 1 minute"], // Durée minimale de 1 minute
        max: [1440, "Duration cannot exceed 24 hours"]  // Durée maximale de 1440 minutes (24 heures)
    },
    calories_brulees: {
        type: Number,
        default: 0,       // Calories brûlées par défaut est de 0
        min: [0, "Calories burned cannot be negative"] // Validation pour s'assurer que les calories ne sont pas négatives
    },
    valeur_realisee: {
        type: Number,       // La valeur réalisée par l'utilisateur pendant la séance (par exemple, nombre de répétitions)
        required: [true, "Please enter the realized value for the session"], // Message d'erreur si la valeur réalisée n'est pas fournie
        min: [0, "Realized value cannot be negative"]  // Validation pour s'assurer que la valeur réalisée n'est pas négative
    },
    unite: {
        type: String,       // Unité associée à la valeur réalisée (par exemple, 'km', 'minutes', 'repetitions')
        required: [true, "Please specify the unit for the realized value"], // Message d'erreur si l'unité n'est pas fournie
        enum: ['km', 'minutes', 'calories', 'kg', 'repetitions', 'autre'], // Liste des unités possibles
        default: 'autre' // Valeur par défaut si aucune unité n'est spécifiée
    },
    notes: {
        type: String,      // Notes supplémentaires concernant la séance
        trim: true,        // Suppression des espaces en début et en fin de chaîne
        maxlength: [500, "Notes cannot exceed 500 characters"] // Longueur maximale des notes
    },
    suivi_gps: {
        type: [String], // Tableau de chaînes pour stocker les coordonnées GPS sous forme de latitude,longitude
        validate: {
            validator: function (arr) {
                // Validation personnalisée pour vérifier que chaque élément du tableau est au format "latitude,longitude"
                return arr.every(coordinate => /^-?\d+(\.\d+)?,-?\d+(\.\d+)?$/.test(coordinate));
            },
            message: "Invalid GPS coordinate format. Each coordinate should be in the format 'latitude,longitude'."
        }
    },
    accel_data: {
        type: [Number],  // Tableau de nombres pour stocker les données de l'accéléromètre
        default: [],     // Valeur par défaut : un tableau vide
        validate: {
            validator: function (arr) {
                return arr.every(num => Number.isInteger(num) && num >= 0); // S'assurer que chaque valeur est un entier positif
            },
            message: "Accelerometer data must be an array of positive integers representing step counts."
        }
    }
},
    {
        timestamps: true // Active les champs `createdAt` et `updatedAt` automatiquement
    });

const Seance = mongoose.model('Seance', SeanceSchema);

module.exports = Seance;
