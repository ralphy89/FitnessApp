const express = require('express');
const router = express.Router();
const {
    createNotification,
    getNotificationsByUserId,
    getNotification,
    updateNotification,
    deleteNotification,
    getNotifications
} = require('../controllers/notification.controller.js');

router.post("/", createNotification);
router.get("/", getNotifications);
router.get("/for/:id", getNotificationsByUserId);
router.get("/:id", getNotification);
router.put("/:id", updateNotification);
router.delete("/:id", deleteNotification);

module.exports = router;
