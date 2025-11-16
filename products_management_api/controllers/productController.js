const { pool, poolConnect, sql } = require('../db/database'); // import sql here
const validateProduct = require('../validation/productValidation');

exports.getAllProducts = async (req, res) => {
    try {
        await poolConnect;
        const result = await pool.request().query("SELECT * FROM products");
        return res.json({ products: result.recordset });
    } catch (error) {
        console.error(error);
        return res.status(500).json({ message: "Server error" });
    }
};

exports.getProductById = async (req, res) => {
    const id = parseInt(req.params.id);

    try {
        await poolConnect;
        const result = await pool
            .request()
            .input("id", sql.Int, id)
            .query("SELECT * FROM products WHERE PRODUCTID = @id");

        if (result.recordset.length === 0)
            return res.status(404).json({ message: "Product not found" });

        return res.json(result.recordset[0]);
    } catch (error) {
        console.error(error);
        return res.status(500).json({ message: "Server error" });
    }
};

exports.createProduct = async (req, res) => {
    const validation = validateProduct(req.body);
    if (validation.error)
        return res.status(400).json(validation.error.details[0]);

    const { productname, price, stock } = req.body;

    try {
        await poolConnect;
        const insertQuery = `
            INSERT INTO products (PRODUCTNAME, PRICE, STOCK)
            OUTPUT INSERTED.*
            VALUES (@name, @price, @stock)
        `;

        const dbResult = await pool
            .request()
            .input("name", sql.VarChar, productname)
            .input("price", sql.Decimal(10, 2), price)
            .input("stock", sql.Int, stock)
            .query(insertQuery);

        return res.json({
            message: "Product created successfully.",
            product: dbResult.recordset[0]
        });
    } catch (error) {
        console.error(error);
        return res.status(500).json({ message: "Server error" });
    }
};

exports.updateProduct = async (req, res) => {
    const id = parseInt(req.params.id);
    const validation = validateProduct(req.body);
    if (validation.error)
        return res.status(400).json(validation.error.details[0]);

    const { productname, price, stock } = req.body;

    try {
        await poolConnect;
        const check = await pool
            .request()
            .input("id", sql.Int, id)
            .query("SELECT * FROM products WHERE PRODUCTID = @id");

        if (check.recordset.length === 0)
            return res.status(404).json({ message: "Product not found" });

        const updateQuery = `
            UPDATE products
            SET PRODUCTNAME = @name,
                PRICE = @price,
                STOCK = @stock
            WHERE PRODUCTID = @id;

            SELECT * FROM products WHERE PRODUCTID = @id
        `;

        const dbResult = await pool
            .request()
            .input("id", sql.Int, id)
            .input("name", sql.VarChar, productname)
            .input("price", sql.Decimal(10, 2), price)
            .input("stock", sql.Int, stock)
            .query(updateQuery);

        return res.json({
            message: "Product updated successfully.",
            product: dbResult.recordset[0]
        });
    } catch (error) {
        console.error(error);
        return res.status(500).json({ message: "Server error" });
    }
};

exports.deleteProduct = async (req, res) => {
    const id = parseInt(req.params.id);

    try {
        await poolConnect;
        const check = await pool
            .request()
            .input("id", sql.Int, id)
            .query("SELECT * FROM products WHERE PRODUCTID = @id");

        if (check.recordset.length === 0)
            return res.status(404).json({ message: "Product not found" });

        await pool
            .request()
            .input("id", sql.Int, id)
            .query("DELETE FROM products WHERE PRODUCTID = @id");

        return res.json({
            message: "Product deleted successfully.",
            product: check.recordset[0]
        });
    } catch (error) {
        console.error(error);
        return res.status(500).json({ message: "Server error" });
    }
};