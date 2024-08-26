const express = require("express");
const User = require('../models/user.model.js');
const router = express.Router();
const {createUser, getUsers, getUser, updateUser, deleteUser, getUserByEmail } = require('../controllers/user.controller.js');


router.post("/", createUser);
router.put("/:id", updateUser);
router.get("/", getUsers);
router.get("/:id", getUser);
router.delete("/:id", deleteUser);
router.get("/data/:email", getUserByEmail);
module.exports = router;