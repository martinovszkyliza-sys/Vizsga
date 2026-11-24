const mysql = require('mysql2/promise');

const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    port: Number(process.env.DB_PORT) || 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'konyvtar_db',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    charset: 'utf8mb4'
});

function createError(message, statusCode) {
    const error = new Error(message);
    error.statusCode = statusCode;
    return error;
}

async function inTransaction(callback) {
    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();
        const result = await callback(connection);
        await connection.commit();
        return result;
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}

async function getBooks() {
    const [rows] = await pool.query('SELECT * FROM konyvek ORDER BY konyvid');
    return rows;
}

async function getBookById(id) {
    const [rows] = await pool.execute('SELECT * FROM konyvek WHERE konyvid = ?', [id]);
    return rows[0] || null;
}

async function createBook(book) {
    const [result] = await pool.execute(
        `INSERT INTO konyvek
            (cim, iro, mufaj, kategoria, korhatar, oldalszam, kiadasi_ev, nyelv, kiado, borito_kep)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
            book.cim,
            book.iro,
            book.mufaj ?? null,
            book.kategoria,
            book.korhatar ?? 0,
            book.oldalszam ?? null,
            book.kiadasi_ev ?? null,
            book.nyelv ?? 'Magyar',
            book.kiado ?? null,
            book.borito_kep ?? null
        ]
    );
    return getBookById(result.insertId);
}

async function deleteBook(id) {
    const [result] = await pool.execute('DELETE FROM konyvek WHERE konyvid = ?', [id]);
    return result.affectedRows > 0;
}

async function getReaders() {
    const [rows] = await pool.query('SELECT * FROM olvasok ORDER BY torzsszam');
    return rows;
}

async function createReader(reader) {
    const [result] = await pool.execute(
        `INSERT INTO olvasok (nev, szuletesi_datum, elerhetoseg, is_admin)
         VALUES (?, ?, ?, ?)`,
        [reader.nev, reader.szuletesi_datum, reader.elerhetoseg, reader.is_admin ?? 0]
    );
    const [rows] = await pool.execute('SELECT * FROM olvasok WHERE torzsszam = ?', [result.insertId]);
    return rows[0];
}

async function deleteReader(id) {
    return inTransaction(async (connection) => {
        const [loans] = await connection.execute(
            'SELECT konyvid FROM kolcsonzesek WHERE torzsszam = ?',
            [id]
        );
        const [result] = await connection.execute('DELETE FROM olvasok WHERE torzsszam = ?', [id]);

        if (result.affectedRows === 0) return false;

        for (const { konyvid } of loans) {
            await connection.execute(
                `UPDATE konyvek SET statusz = 'kölcsönözhető'
                 WHERE konyvid = ?
                   AND NOT EXISTS (
                       SELECT 1 FROM kolcsonzesek WHERE konyvid = ?
                   )`,
                [konyvid, konyvid]
            );
        }
        return true;
    });
}

async function getLoans() {
    const [rows] = await pool.query(
        `SELECT l.kolcsonid, l.torzsszam, l.konyvid,
                l.kolcson_datum, l.kolcson_hatarido,
                o.nev AS olvaso_nev, k.cim AS konyv_cim
         FROM kolcsonzesek AS l
         INNER JOIN olvasok AS o ON o.torzsszam = l.torzsszam
         INNER JOIN konyvek AS k ON k.konyvid = l.konyvid
         ORDER BY l.kolcsonid`
    );
    return rows;
}

async function createLoan(loan) {
    return inTransaction(async (connection) => {
        const [readers] = await connection.execute(
            'SELECT torzsszam FROM olvasok WHERE torzsszam = ?',
            [loan.torzsszam]
        );
        if (readers.length === 0) throw createError('A megadott olvasó nem található.', 404);

        const [bookUpdate] = await connection.execute(
            `UPDATE konyvek SET statusz = 'kölcsönzött'
             WHERE konyvid = ? AND statusz = 'kölcsönözhető'`,
            [loan.konyvid]
        );
        if (bookUpdate.affectedRows === 0) {
            const [books] = await connection.execute(
                'SELECT konyvid FROM konyvek WHERE konyvid = ?',
                [loan.konyvid]
            );
            if (books.length === 0) throw createError('A megadott könyv nem található.', 404);
            throw createError('A könyv jelenleg nem kölcsönözhető.', 409);
        }

        const [result] = await connection.execute(
            `INSERT INTO kolcsonzesek (torzsszam, konyvid, kolcson_datum, kolcson_hatarido)
             VALUES (?, ?, ?, ?)`,
            [loan.torzsszam, loan.konyvid, loan.kolcson_datum, loan.kolcson_hatarido]
        );
        const [rows] = await connection.execute(
            'SELECT * FROM kolcsonzesek WHERE kolcsonid = ?',
            [result.insertId]
        );
        return rows[0];
    });
}

async function returnLoan(id) {
    return inTransaction(async (connection) => {
        const [loans] = await connection.execute(
            'SELECT konyvid FROM kolcsonzesek WHERE kolcsonid = ? FOR UPDATE',
            [id]
        );
        if (loans.length === 0) return false;

        const { konyvid } = loans[0];
        await connection.execute('DELETE FROM kolcsonzesek WHERE kolcsonid = ?', [id]);
        await connection.execute(
            `UPDATE konyvek SET statusz = 'kölcsönözhető'
             WHERE konyvid = ?
               AND NOT EXISTS (
                   SELECT 1 FROM kolcsonzesek WHERE konyvid = ?
               )`,
            [konyvid, konyvid]
        );
        return true;
    });
}

async function getStats() {
    const [rows] = await pool.query(
        `SELECT
            (SELECT COUNT(*) FROM olvasok) AS readers,
            (SELECT COUNT(*) FROM konyvek) AS books,
            (SELECT COUNT(*) FROM kolcsonzesek) AS loans`
    );
    return rows[0];
}

module.exports = {
    getBooks,
    createBook,
    deleteBook,
    getReaders,
    createReader,
    deleteReader,
    getLoans,
    createLoan,
    returnLoan,
    getStats
};