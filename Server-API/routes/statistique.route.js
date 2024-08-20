const express = require('express');
const router = express.Router();
const {
    createStatistique,
    getStatistiques,
    getStatistique,
    updateStatistique,
    deleteStatistique,
    getStatistiquesByUserAndPeriod,
    analyseTendances
} = require('../controllers/statistique.controller.js');

router.post('/', createStatistique);
router.get('/', getStatistiques);
router.get('/:id', getStatistique);
router.put('/:id', updateStatistique);
router.delete('/:id', deleteStatistique);
router.get('/user/:id_user/period/:start_date/:end_date', getStatistiquesByUserAndPeriod);
router.get('/analyse/:id_user/period/:period', analyseTendances);

module.exports = router;
