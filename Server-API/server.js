const express = require('express');
const mongoose = require('mongoose');
const userRoute = require('./routes/user.route.js');
const sessionRoute = require('./routes/seance.route.js');
const goalRoute = require('./routes/objectif.route.js');
const badgeRoute = require('./routes/badge.route.js');
const notifRoute = require('./routes/notification.route.js');
const statRoute = require('./routes/statistique.route.js');

const app = express();

// middleware
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
// routes
app.use("/api/users", userRoute);
app.use("/api/sessions", sessionRoute);
app.use("/api/goals", goalRoute);
app.use("/api/badges", badgeRoute);
app.use("/api/messages", notifRoute);
app.use("/api/stats", statRoute);

app.get('/', (req, res) => {
    res.send('Hello from Fitness App API!');
})

mongoose.connect('mongodb+srv://ralphdumera00:fvIxtY6V9yLv22bA@fitnessappdb.kuhdl.mongodb.net/fitnessApp?retryWrites=true&w=majority&appName=FitnessAppDB')
    .then(
        () => {
            console.log('> Connected to mongodb atlas!');
            app.listen(3000, () => {
                console.log('> Server is running on port 3000');
            })
        }).catch(
            err => console.log("> Connection failed\n\n" + err)
        );

