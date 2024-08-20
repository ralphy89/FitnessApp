const Badge = require('../models/badge.model');

// Créer un nouveau badge
const createBadge = async (req, res) => {
    try {
        const badge = await Badge.create(req.body);
        res.status(201).json(badge);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Récupérer tous les badges
const getBadges = async (req, res) => {
    try {
        const badges = await Badge.find({});
        res.status(200).json(badges);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Récupérer tous les badges pour un utilisateur spécifique
const getBadgesByIdUser = async (req, res) => {
    try {
        const { id } = req.params;
        const badges = await Badge.find({ id_user: id });
        res.status(200).json(badges);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};


// Récupérer un badge par son ID
const getBadge = async (req, res) => {
    try {
        const { id } = req.params;
        const badge = await Badge.findById(id);

        if (!badge) {
            return res.status(404).json({ message: 'Badge non trouvé' });
        }

        res.status(200).json(badge);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Mettre à jour un badge par son ID
const updateBadge = async (req, res) => {
    try {
        const { id } = req.params;
        const badge = await Badge.findByIdAndUpdate(id, req.body, { new: true });

        if (!badge) {
            return res.status(404).json({ message: 'Badge non trouvé' });
        }

        res.status(200).json(badge);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Supprimer un badge par son ID
const deleteBadge = async (req, res) => {
    try {
        const { id } = req.params;
        const badge = await Badge.findByIdAndDelete(id);

        if (!badge) {
            return res.status(404).json({ message: 'Badge non trouvé' });
        }

        res.status(200).json({ message: 'Badge supprimé avec succès' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    createBadge,
    getBadges,
    getBadge,
    updateBadge,
    deleteBadge,
    getBadgesByIdUser
};

