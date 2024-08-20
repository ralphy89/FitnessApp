const express = require("express");
const router = express.Router();
const {createSeance, getSeances, getSeance, updateSeance, deleteSeance, getSeancesByIdUser } = require('../controllers/seance.controller.js');


router.post("/", createSeance);
router.put("/:id", updateSeance);
router.get("/", getSeances);
router.get("/:id", getSeance);
router.get("/for/:id", getSeancesByIdUser)
router.delete("/:id", deleteSeance);
module.exports = router;