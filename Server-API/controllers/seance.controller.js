const Seance = require('../models/seance.model');

// Create a new Seance
const createSeance = async (req, res) => {
    try {
        const seance = await Seance.create(req.body);
        res.status(200).json(seance);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get all Seances
const getSeances = async (req, res) => {
    try {
        const seances = await Seance.find({});
        res.status(200).json(seances);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get a single Seance by ID
const getSeance = async (req, res) => {
    try {
        const { id } = req.params;
        const seance = await Seance.findById(id);

        if (!seance) {
            return res.status(404).json({ message: 'Séance not found' });
        }

        res.status(200).json(seance);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getSeancesByIdUser = async (req, res) => {
    try {
        const { id } = req.params;
        const seances = await Seance.find({ id_user: id });
        res.status(200).json(seances);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Update a Seance by ID
const updateSeance = async (req, res) => {
    try {
        const { id } = req.params;
        const seance = await Seance.findByIdAndUpdate(id, req.body, { new: true });

        if (!seance) {
            return res.status(404).json({ message: 'Séance not found' });
        }

        const updatedSeance = await Seance.findById(id);
        res.status(200).json(updatedSeance);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Delete a Seance by ID
const deleteSeance = async (req, res) => {
    try {
        const { id } = req.params;
        const seance = await Seance.findByIdAndDelete(id);

        if (!seance) {
            return res.status(404).json({ message: 'Séance not found' });
        }

        res.status(200).json({ message: 'Séance deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    createSeance,
    getSeances,
    getSeance,
    updateSeance,
    deleteSeance,
    getSeancesByIdUser
};
