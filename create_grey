CREATE TABLE price_list (
    price_list_id SERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    store_id INT NOT NULL,
    purchase_price NUMERIC(10, 2) NOT NULL,
    final_price NUMERIC(10, 2) NOT NULL,
    price_type SMALLINT CHECK (price_type IN (0, 1, 2)), -- 0: Regular price, 1: Discount, 2: Promotion
    promotion_id INT,
    created_date DATE NOT NULL,
    end_date DATE,
    FOREIGN KEY (promotion_id) REFERENCES promotions(promotion_id)
);

CREATE TABLE category_markup (
    category_markup_id SERIAL PRIMARY KEY,
    markup_percentage NUMERIC(5, 2) NOT NULL,
    delta_percentage NUMERIC(5, 2) NOT NULL,
    modification_date DATE NOT NULL
);

CREATE TABLE product_category (
    category_id SERIAL PRIMARY KEY,
    category_markup_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    FOREIGN KEY (category_markup_id) REFERENCES category_markup(category_markup_id)
);

CREATE TABLE promotions (
    promotion_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE units (
    unit_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);
