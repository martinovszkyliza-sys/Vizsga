const express = require('express');
const path = require('path');
const routes = require('./route/routes');

const app = express();
const port = Number(process.env.PORT) || 3000;

app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));
app.use('/api', routes);

app.get('/', (_req, res) => {
    res.sendFile(path.join(__dirname, 'library_management_system.html'));
});

app.use((req, res) => {
    res.status(404).json({ error: 'A kért végpont nem található.' });
});

app.listen(port, () => {
    console.log(`Könyvtár API fut: http://localhost:${port}`);
});