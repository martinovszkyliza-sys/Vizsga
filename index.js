const express = require('express');
const path = require('path');
const routes = require('./route/routes');
const model = require('./model/model');

const app = express();
const port = Number(process.env.PORT) || 3000;

app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));
app.use('/api', routes);

app.get('/', (_req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.use((req, res) => {
    res.status(404).json({ error: 'A kért végpont nem található.' });
});

model.ensureAuthSchema()
    .then(() => {
        app.listen(port, () => {
            //console.log(`Könyvtár API fut: http://localhost:${port}`);
            console.log(`Könyvtár API fut: http://localhost:3000`);
        });
    })
    .catch((error) => {
        console.error('Az adatbázis inicializálása nem sikerült:', error);
        process.exitCode = 1;
    });