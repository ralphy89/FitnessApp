const express = require("express");
const Badge = require('../models/badge.model.js');
const router = express.Router();
const { createBadge, getBadges, getBadge, updateBadge, deleteBadge, getBadgesByIdUser } = require('../controllers/badge.controller.js');

router.post("/", createBadge);
router.put("/:id", updateBadge);
router.get("/", getBadges);
router.get("/:id", getBadge);
router.get("/for/:id", getBadgesByIdUser);
router.delete("/:id", deleteBadge);

module.exports = router;
