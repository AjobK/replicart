const express = require('express');
const bodyParser = require('body-parser');
const https = require('https');
const fs = require('fs');

// Routes utilizing resource files
const cookieParser = require('cookie-parser');
const cors = require('cors');

require('dotenv').config()

const { FRONTEND_URL, SECURE } = process.env;
const app = express();

app.use(bodyParser.json());
app.use(cookieParser());
app.use(cors({
    origin: [FRONTEND_URL, 'http://kustra.nl', 'https://kustra.nl', 'http://localhost:4200'],
    credentials: true
}));

// // Initialize routes with /api prefix
app.use('/api', require('./generalRouter'));

if (SECURE == 'true') {
    const httpsServer = https.createServer({
        key: fs.readFileSync('/etc/letsencrypt/live/kustra.nl/privkey.pem'),
        cert: fs.readFileSync('/etc/letsencrypt/live/kustra.nl/fullchain.pem')
    }, app);

    httpsServer.listen(8080, () => {
        console.log('(Secure) HTTPS Server running on port 8080 :-)');
    })
} else {
    app.listen(8080, () => { console.log('(Insecure) HTTP Server running on port 8080 :-)')})
}
