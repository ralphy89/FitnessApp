const Objectif = require('../models/objectif.model');

// Create a new Objectif
const createObjectif = async (req, res) => {
    try {
        const objectif = await Objectif.create(req.body);
        res.status(200).json(objectif);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get all Objectifs
const getObjectifs = async (req, res) => {
    try {
        const objectifs = await Objectif.find({});
        res.status(200).json(objectifs);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get a single Objectif by ID
const getObjectif = async (req, res) => {
    try {
        const { id } = req.params;
        const objectif = await Objectif.findById(id);

        if (!objectif) {
            return res.status(404).json({ message: 'Objectif not found' });
        }

        res.status(200).json(objectif);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get all Objectifs by User ID
const getObjectifsByIdUser = async (req, res) => {
    try {
        const { id } = req.params;
        const objectifs = await Objectif.find({ id_user: id });
        res.status(200).json(objectifs);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Update an Objectif by ID
const updateObjectif = async (req, res) => {
    try {
        const { id } = req.params;
        const objectif = await Objectif.findByIdAndUpdate(id, req.body, { new: true });

        if (!objectif) {
            return res.status(404).json({ message: 'Objectif not found' });
        }

        const updatedObjectif = await Objectif.findById(id);
        res.status(200).json(updatedObjectif);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Delete an Objectif by ID
const deleteObjectif = async (req, res) => {
    try {
        const { id } = req.params;
        const objectif = await Objectif.findByIdAndDelete(id);

        if (!objectif) {
            return res.status(404).json({ message: 'Objectif not found' });
        }

        res.status(200).json({ message: 'Objectif deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    createObjectif,
    getObjectifs,
    getObjectif,
    updateObjectif,
    deleteObjectif,
    getObjectifsByIdUser
};
