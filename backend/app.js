const express = require('express');
const bodyParser = require('body-parser');
const https = require('https');
const fs = require('fs');

// Routes utilizing resource files
const cookieParser = require('cookie-parser');
const cors = require('cors');

require('dotenv').config()

const { FRONTEND_URL } = process.env;
const app = express();

app.use(bodyParser.json());
app.use(cookieParser())
app.use(cors({
    origin: [FRONTEND_URL, 'http://kustra.nl', 'https://kustra.nl', 'http://localhost:4200'],
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

const httpsServer = https.createServer({
    key: fs.readFileSync('/etc/letsencrypt/live/kustra.nl/privkey.pem'),
    cert: fs.readFileSync('/etc/letsencrypt/live/kustra.nl/fullchain.pem')
}, app);

httpsServer.listen(8080, () => {
    console.log('HTTPS Server runnign on port 8080 :-)');
}, app)



// app.listen(8080);