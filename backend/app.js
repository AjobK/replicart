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

console.log('im fine here 1')

// app.use(bodyParser.json());
console.log('im fine here 2')
// app.use(cookieParser())
console.log('im fine here 3')
// app.use(cors({
//     origin: [FRONTEND_URL, 'http://kustra.nl', 'https://kustra.nl', 'http://localhost:4200'],
//     credentials: true
// }))
console.log('im fine here 4')

// External access (CORS)
// app.use((req, res, next) => {
    //     res.setHeader('Access-Control-Allow-Origin', '*');                              // Allow client to send requests from given origin, * serving as a wildcard
    //     res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE'); // Allow client to use given request methods
    //     res.setHeader('Access-Control-Allow-Headers', '*');   // Allow client to send request headers
    //     res.setHeader('Access-Control-Allow-Credentials', true);   // Allow client to send request headers
    //     next();
    // });
    
    // Initialize routes with /api prefix
    // app.use('/api', require('./generalRouter'));
    
    const httpsServer = https.createServer({
        key: fs.readFileSync('/etc/letsencrypt/live/kustra.nl/privkey.pem'),
        cert: fs.readFileSync('/etc/letsencrypt/live/kustra.nl/fullchain.pem')
    }, app);
    console.log('im fine here 5')
    
    httpsServer.listen(8080, () => {
        console.log('HTTPS Server runnign on port 8080 :-)');
    }, app)
    console.log('im fine here 6')
    


// app.listen(8080);