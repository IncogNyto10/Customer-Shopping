-- Crear esquema de bodega de datos en PostgreSQL
CREATE SCHEMA shopping_dw;

-- Tabla Dimensión: Clientes
CREATE TABLE shopping_dw.dim_customer (
    customer_id VARCHAR PRIMARY KEY,
    gender VARCHAR(10),
    age INT
);

-- Tabla Dimensión: Categorías de Productos
CREATE TABLE shopping_dw.dim_category (
    category_id SERIAL PRIMARY KEY,
    category VARCHAR(50)
);

-- Tabla Dimensión: Métodos de Pago
CREATE TABLE shopping_dw.dim_payment (
    payment_method_id SERIAL PRIMARY KEY,
    payment_method VARCHAR(50)
);

-- Tabla Dimensión: Centros Comerciales
CREATE TABLE shopping_dw.dim_mall (
    shopping_mall_id SERIAL PRIMARY KEY,
    shopping_mall VARCHAR(100)
);

-- Tabla Dimensión: Fechas
CREATE TABLE shopping_dw.dim_date (
    invoice_date DATE PRIMARY KEY,
    year INT,
    month INT,
    day INT,
    week_of_year INT,
    weekday VARCHAR(15)
);


-- Tabla de Hechos: Ventas

CREATE TABLE shopping_dw.fact_sales (
    invoice_no VARCHAR PRIMARY KEY,
    customer_id VARCHAR,
    category_id SERIAL,
    payment_method_id SERIAL,
    shopping_mall_id SERIAL,
    invoice_date DATE,
    quantity INT,
    price FLOAT,
    FOREIGN KEY (customer_id) REFERENCES shopping_dw.dim_customer(customer_id),
    FOREIGN KEY (category_id) REFERENCES shopping_dw.dim_category(category_id),
    FOREIGN KEY (payment_method_id) REFERENCES shopping_dw.dim_payment(payment_method_id),
    FOREIGN KEY (shopping_mall_id) REFERENCES shopping_dw.dim_mall(shopping_mall_id),
    FOREIGN KEY (invoice_date) REFERENCES shopping_dw.dim_date(invoice_date)
);

----   Insertar datos en las tablas de dimensiones

-- Cargar datos en dim_payment
COPY shopping_dw.dim_payment(payment_method_id, payment_method)
FROM '/tmp/dim_payment.csv' -- Cambiar por la ruta del archivo
DELIMITER ',' 
CSV HEADER;

-- Cargar datos en dim_category
COPY shopping_dw.dim_category(category_id, category)
FROM '/tmp/dim_category.csv' -- Cambiar por la ruta del archivo
DELIMITER ',' 
CSV HEADER;

-- Cargar datos en dim_mall
COPY shopping_dw.dim_mall(shopping_mall_id, shopping_mall)
FROM '/tmp/dim_mall.csv' -- Cambiar por la ruta del archivo
DELIMITER ',' 
CSV HEADER;

-- Cargar datos en dim_customer
COPY shopping_dw.dim_customer(customer_id, gender, age)
FROM '/tmp/dim_customer.csv' -- Cambiar por la ruta del archivo
DELIMITER ',' 
CSV HEADER;

-- Cargar datos en dim_date
COPY shopping_dw.dim_date(invoice_date, year, month, day, week_of_year, weekday)
FROM '/tmp/dim_date.csv' -- Cambiar por la ruta del archivo
DELIMITER ',' 
CSV HEADER;

-- Cargar datos en fact_sales
COPY shopping_dw.fact_sales(invoice_no, customer_id, category_id, payment_method_id, shopping_mall_id, invoice_date, quantity, price)
FROM '/tmp/fact_sales.csv' -- Cambiar por la ruta del archivo
DELIMITER ',' 
CSV HEADER;


---- Consultas
SELECT 
    fs.invoice_no,
    fs.customer_id,
    fs.quantity,
    fs.price,
    fs.invoice_date,

    -- Relación con dim_customer
    dc.gender AS customer_gender,
    dc.age AS customer_age,

    -- Relación con dim_category
    cat.category AS product_category,

    -- Relación con dim_payment
    pm.payment_method AS payment_method,

    -- Relación con dim_mall
    mall.shopping_mall AS shopping_mall,
    
    -- Relación con dim_date
    dt.year AS year,
    dt.month AS month,
    dt.day AS day,
    dt.week_of_year AS week_of_year,
    dt.weekday AS weekday
FROM 
    shopping_dw.fact_sales fs
-- Unir con dim_customer
JOIN shopping_dw.dim_customer dc ON fs.customer_id = dc.customer_id
-- Unir con dim_category
JOIN shopping_dw.dim_category cat ON fs.category_id = cat.category_id
-- Unir con dim_payment
JOIN shopping_dw.dim_payment pm ON fs.payment_method_id = pm.payment_method_id
-- Unir con dim_mall
JOIN shopping_dw.dim_mall mall ON fs.shopping_mall_id = mall.shopping_mall_id
-- Unir con dim_date
JOIN shopping_dw.dim_date dt ON fs.invoice_date = dt.invoice_date;


