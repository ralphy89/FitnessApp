const Statistique = require('../models/statistique.model.js');

// Créer une nouvelle statistique
exports.createStatistique = async (req, res) => {
    try {
        const statistique = new Statistique(req.body);
        await statistique.save();
        res.status(201).json(statistique);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

// Obtenir toutes les statistiques
exports.getStatistiques = async (req, res) => {
    try {
        const statistiques = await Statistique.find().populate('id_user').populate('id_seance');
        res.status(200).json(statistiques);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Obtenir une statistique par ID
exports.getStatistique = async (req, res) => {
    try {
        const statistique = await Statistique.findById(req.params.id).populate('id_user').populate('id_seance');
        if (!statistique) {
            return res.status(404).json({ error: 'Statistique not found' });
        }
        res.status(200).json(statistique);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Mettre à jour une statistique
exports.updateStatistique = async (req, res) => {
    try {
        const statistique = await Statistique.findByIdAndUpdate(req.params.id, req.body, { new: true }).populate('id_user').populate('id_seance');
        if (!statistique) {
            return res.status(404).json({ error: 'Statistique not found' });
        }
        res.status(200).json(statistique);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

// Supprimer une statistique
exports.deleteStatistique = async (req, res) => {
    try {
        const statistique = await Statistique.findByIdAndDelete(req.params.id);
        if (!statistique) {
            return res.status(404).json({ error: 'Statistique not found' });
        }
        res.status(204).json({ message: 'Statistique deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Obtenir les statistiques d'un utilisateur pour une période donnée
exports.getStatistiquesByUserAndPeriod = async (req, res) => {
    const { id_user, start_date, end_date } = req.params;
    try {
        const statistiques = await Statistique.find({
            id_user,
            date_seance: { $gte: new Date(start_date), $lte: new Date(end_date) }
        }).sort({ date_seance: -1 });
        res.status(200).json(statistiques);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Analyse des tendances et des performances
exports.analyseTendances = async (req, res) => {
    const { id_user, period } = req.params; // period peut être 'day', 'week', 'month'
    try {
        const now = new Date();
        let start_date;

        switch (period) {
            case 'day':
                start_date = new Date(now.setDate(now.getDate() - 1));
                break;
            case 'week':
                start_date = new Date(now.setDate(now.getDate() - 7));
                break;
            case 'month':
                start_date = new Date(now.setMonth(now.getMonth() - 1));
                break;
            default:
                return res.status(400).json({ error: 'Invalid period' });
        }

        const statistiques = await Statistique.find({
            id_user,
            date_seance: { $gte: start_date }
        });

        // Calculer les meilleures performances, moyennes, etc.
        const bestPerformance = statistiques.reduce((best, stat) => stat.valeur_realisee > best.valeur_realisee ? stat : best, { valeur_realisee: 0 });
        const averageCalories = statistiques.reduce((sum, stat) => sum + stat.calories_brulees, 0) / statistiques.length || 0;

        res.status(200).json({
            bestPerformance,
            averageCalories,
            count: statistiques.length
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
