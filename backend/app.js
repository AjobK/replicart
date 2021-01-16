const express = require('express');
const bodyParser = require('body-parser');

// Routes utilizing resource files
const replicaRoutes = require('./resources/ReplicaResource');
const authRoutes = require('./resources/AuthResource');

const app = express();

app.use(bodyParser.json());

// External access (CORS)
app.use((req, res, next) => {
    res.setHeader('Access-Control-Allow-Origin', '*');                              // Allow client to send requests from given origin, * serving as a wildcard
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE'); // Allow client to use given request methods
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, userID');   // Allow client to send request headers
    next();
});

// Utilize routes
app.use('/api/replica', replicaRoutes);
app.use('/api/auth', authRoutes);

app.listen(8080);