const mongoose = require('mongoose');
const { Schema, ObjectId } = mongoose;

const NotificationSchema = new Schema({
    id_user: {
        type: ObjectId,   // Référence à l'utilisateur qui reçoit la notification
        ref: 'User',      // Relie la notification à la collection 'User'
        required: true    // Oblige la présence de l'utilisateur
    },
    titre: {
        type: String,
        required: [true, "Le titre de la notification est requis"],
        maxlength: [100, "Le titre ne peut pas dépasser 100 caractères"]
    },
    message: {
        type: String,
        required: [true, "Le message de la notification est requis"],
        maxlength: [500, "Le message ne peut pas dépasser 500 caractères"]
    },
    date_notif: {
        type: Date,
        default: Date.now // La date de création est la date actuelle par défaut
    },
    lu: {
        type: Boolean,
        default: false // Les notifications sont marquées comme non lues par défaut
    }
});

const Notification = mongoose.model('Notification', NotificationSchema);

module.exports = Notification;
