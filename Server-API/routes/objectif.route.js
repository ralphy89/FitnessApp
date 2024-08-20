const express = require("express");
const Objectif = require('../models/objectif.model.js');
const router = express.Router();
const { createObjectif, getObjectifs, getObjectif, updateObjectif, deleteObjectif, getObjectifsByIdUser } = require('../controllers/objectif.controller.js');

router.post("/", createObjectif);
router.put("/:id", updateObjectif);
router.get("/", getObjectifs);
router.get("/:id", getObjectif);
router.get("/for/:id", getObjectifsByIdUser);
router.delete("/:id", deleteObjectif);

module.exports = router;
