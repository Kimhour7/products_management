const sql = require('mssql/msnodesqlv8');

const pool = new sql.ConnectionPool({
    server: 'DESKTOP-11LAS6L\\SQLEXPRESS',
    database: 'products_management',
    driver: 'msnodesqlv8',
    options: {
        trustedConnection: true
    }
});

const poolConnect = pool.connect()
    .then(() => console.log('Database connected!'))
    .catch(err => console.error('DB Connection Failed:', err));

module.exports = { pool, poolConnect, sql }; 