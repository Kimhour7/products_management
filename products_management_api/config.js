require("dotenv").config();

module.exports = {
    dbConfig: {
        server: process.env.DB_SERVER,
        database: process.env.DB_DATABASE,
        driver: process.env.DB_DRIVER,
        options: {
            trustedConnection: true
        }
    }
};