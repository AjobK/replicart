const express = require('express');
const bodyParser = require('body-parser');

// Routes utilizing resource files
const cookieParser = require('cookie-parser');
const cors = require('cors');

const app = express();

app.use(bodyParser.json());
app.use(cookieParser())
app.use(cors({
    origin: 'http://localhost:4200',
    credentials: true
}))

// External access (CORS)
// app.use((req, res, next) => {
//     res.setHeader('Access-Control-Allow-Origin', '*');                              // Allow client to send requests from given origin, * serving as a wildcard
//     res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE'); // Allow client to use given request methods
//     res.setHeader('Access-Control-Allow-Headers', '*');   // Allow client to send request headers
//     res.setHeader('Access-Control-Allow-Credentials', true);   // Allow client to send request headers
//     next();
// });

// Initialize routes with /api prefix
app.use('/api', require('./generalRouter'));

app.listen(8080);