const Notification = require('../models/notification.model.js');

// Créer une nouvelle notification
const createNotification = async (req, res) => {
    try {
        const notification = await Notification.create(req.body);
        res.status(201).json(notification);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Obtenir toutes les notifications pour un utilisateur spécifique
const getNotificationsByUserId = async (req, res) => {
    try {
        const { id } = req.params;
        const notifications = await Notification.find({ id_user: id });
        res.status(200).json(notifications);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Obtenir une notification spécifique par ID
const getNotification = async (req, res) => {
    try {
        const { id } = req.params;
        const notification = await Notification.findById(id);

        if (!notification) {
            return res.status(404).json({ message: 'Notification non trouvée' });
        }

        res.status(200).json(notification);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getNotifications = async (req, res) => {
    try {
        const notification = await Notification.find({});

        res.status(200).json(notification);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Mettre à jour une notification par ID (marquer comme lue, par exemple)
const updateNotification = async (req, res) => {
    try {
        const { id } = req.params;
        const notification = await Notification.findByIdAndUpdate(id, req.body, { new: true });

        if (!notification) {
            return res.status(404).json({ message: 'Notification non trouvée' });
        }

        res.status(200).json(notification);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Supprimer une notification par ID
const deleteNotification = async (req, res) => {
    try {
        const { id } = req.params;
        const notification = await Notification.findByIdAndDelete(id);

        if (!notification) {
            return res.status(404).json({ message: 'Notification non trouvée' });
        }

        res.status(200).json({ message: 'Notification supprimée avec succès' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    createNotification,
    getNotificationsByUserId,
    getNotification,
    getNotifications,
    updateNotification,
    deleteNotification
};
