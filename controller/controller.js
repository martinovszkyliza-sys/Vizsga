const model = require('../model/model');

function asyncHandler(handler) {
    return (req, res, next) => Promise.resolve(handler(req, res, next)).catch(next);
}

function requireText(body, field) {
    if (typeof body[field] !== 'string' || body[field].trim() === '') {
        const error = new Error(`A(z) ${field} mező kitöltése kötelező.`);
        error.statusCode = 400;
        throw error;
    }
}

function requireInteger(body, field, { required = false, min = 0, max = Number.MAX_SAFE_INTEGER } = {}) {
    if (body[field] === undefined || body[field] === null || body[field] === '') {
        if (!required) return;
        const error = new Error(`A(z) ${field} mező kitöltése kötelező.`);
        error.statusCode = 400;
        throw error;
    }
    const value = Number(body[field]);
    if (!Number.isInteger(value) || value < min || value > max) {
        const error = new Error(`A(z) ${field} mező érvénytelen.`);
        error.statusCode = 400;
        throw error;
    }
    body[field] = value;
}

exports.getBooks = asyncHandler(async (_req, res) => {
    res.json(await model.getBooks());
});

exports.createBook = asyncHandler(async (req, res) => {
    const book = { ...req.body };
    requireText(book, 'cim');
    requireText(book, 'iro');
    requireText(book, 'kategoria');
    if (!['szépirodalom', 'szakirodalom'].includes(book.kategoria)) {
        const error = new Error('Érvénytelen könyvkategória.');
        error.statusCode = 400;
        throw error;
    }
    requireInteger(book, 'korhatar', { min: 0, max: 120 });
    requireInteger(book, 'oldalszam', { min: 1 });
    requireInteger(book, 'kiadasi_ev', { min: 1000, max: 2155 });
    res.status(201).json(await model.createBook(book));
});

exports.deleteBook = asyncHandler(async (req, res) => {
    const deleted = await model.deleteBook(req.params.id);
    if (!deleted) return res.status(404).json({ error: 'A könyv nem található.' });
    res.json({ message: 'A könyv és a kapcsolódó kölcsönzések törölve.' });
});

exports.getReaders = asyncHandler(async (_req, res) => {
    res.json(await model.getReaders());
});

exports.createReader = asyncHandler(async (req, res) => {
    const reader = { ...req.body };
    requireText(reader, 'nev');
    requireText(reader, 'szuletesi_datum');
    requireText(reader, 'elerhetoseg');
    requireInteger(reader, 'is_admin', { min: 0, max: 1 });
    res.status(201).json(await model.createReader(reader));
});

exports.deleteReader = asyncHandler(async (req, res) => {
    const deleted = await model.deleteReader(req.params.id);
    if (!deleted) return res.status(404).json({ error: 'Az olvasó nem található.' });
    res.json({ message: 'Az olvasó és a kapcsolódó kölcsönzések törölve.' });
});

exports.getLoans = asyncHandler(async (_req, res) => {
    res.json(await model.getLoans());
});

exports.createLoan = asyncHandler(async (req, res) => {
    const loan = { ...req.body };
    requireInteger(loan, 'torzsszam', { required: true, min: 1 });
    requireInteger(loan, 'konyvid', { required: true, min: 1 });
    requireText(loan, 'kolcson_datum');
    requireText(loan, 'kolcson_hatarido');
    res.status(201).json(await model.createLoan(loan));
});

exports.returnLoan = asyncHandler(async (req, res) => {
    const returned = await model.returnLoan(req.params.id);
    if (!returned) return res.status(404).json({ error: 'A kölcsönzés nem található.' });
    res.json({ message: 'A könyv visszavétele rögzítve.' });
});

exports.getStats = asyncHandler(async (_req, res) => {
    res.json(await model.getStats());
});

exports.handleError = (error, _req, res, _next) => {
    const status = error.statusCode || (error.code === 'ER_DUP_ENTRY' ? 409 : 500);
    if (status >= 500) console.error(error);
    res.status(status).json({
        error: status === 500 ? 'Szerverhiba történt.' : error.message
    });
};