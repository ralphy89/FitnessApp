const mongoose = require('mongoose');
const { Schema, ObjectId } = mongoose;

const StatistiqueSchema = new Schema({
    id_statistique: {
        type: ObjectId,   // Utilisation de ObjectId pour identifier de manière unique chaque statistique
        auto: true        // Auto-génération de l'ObjectId
    },
    id_user: {
        type: ObjectId,   // Référence à l'utilisateur pour lequel les statistiques sont générées
        ref: 'User',      // Relie la statistique à la collection 'User'
        required: true    // Oblige la présence de l'utilisateur
    },
    id_seance: {
        type: ObjectId,   // Référence à la séance qui a généré ces statistiques
        ref: 'Seance',    // Relie la statistique à la collection 'Seance'
        required: true    // Oblige la présence de la séance
    },

    type_exercice: {
        type: String,     // Type d'exercice effectué lors de la séance
        required: true    // Le type d'exercice est obligatoire
    },
    valeur_realisee: {
        type: Number,     // Valeur réalisée lors de la séance (par exemple, nombre de répétitions, distance parcourue)
        required: true    // La valeur réalisée est obligatoire
    },
    unite: {
        type: String,     // Unité de la valeur réalisée (par exemple, 'km', 'minutes', 'repetitions')
        required: true    // L'unité est obligatoire
    },
    calories_brulees: {
        type: Number,     // Nombre de calories brûlées pendant la séance
        default: 0,       // Par défaut, 0 si aucune information n'est disponible
        min: [0, "Calories burned cannot be negative"] // Validation pour s'assurer que les calories ne sont pas négatives
    },
    duree: {
        type: Number,     // Durée de la séance en minutes
        required: true    // La durée est obligatoire
    },

    meilleure_performance: {
        type: Boolean,    // Indique si la séance représente une meilleure performance
        default: false    // Par défaut, faux si ce n'est pas une meilleure performance
    }
},
    {
        timestamps: true // Active les champs `createdAt` et `updatedAt` automatiquement
    });

const Statistique = mongoose.model('Statistique', StatistiqueSchema);

module.exports = Statistique;
