CREATE TABLE point (
    id_point SERIAL PRIMARY KEY,
    name VARCHAR(255),
    address VARCHAR(255)
);

CREATE TABLE country_catalogue (
    id_country SERIAL PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE promotion_catalogue (
    id_promotion SERIAL PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE markup_category (
    id_category_markup SERIAL PRIMARY KEY,
    percent_markup NUMERIC(5, 2),
    percent_delta NUMERIC(5, 2),
    date_change DATE
);

CREATE TABLE product_category (
    id_category SERIAL PRIMARY KEY,
    name VARCHAR(255),
    id_category_markup INT
);

CREATE TABLE unit (
    id_unit SERIAL PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE manufacturer_catalogue (
    id_manufacturer SERIAL PRIMARY KEY,
    name_ru VARCHAR(255),
    name_eng VARCHAR(255),
    INN VARCHAR(12),
    id_country INT
);

CREATE TABLE product_card (
    id_product SERIAL PRIMARY KEY,
    name VARCHAR(255),
    height NUMERIC(10, 2),
    width NUMERIC(10, 2),
    length NUMERIC(10, 2),
    expiration_date DATE,
    SKU VARCHAR(32),
    barcode_number VARCHAR(13),
    is_stop BOOLEAN,
    id_price INT,
    id_manufacturer INT,
    id_category INT,
    id_unit INT
);

CREATE TABLE price_list (
    id_price_list SERIAL PRIMARY KEY,
    entrance_price NUMERIC(10, 2),
    final_price NUMERIC(10, 2),
    price_type SMALLINT CHECK (price_type IN (0, 1, 2)),
    date_create DATE,
    date_end DATE,
    id_product INT,
    id_store INT,
    id_promotion INT
);

CREATE TABLE prices (
    id_price SERIAL PRIMARY KEY,
    main_price NUMERIC(10, 2) NOT NULL,
    add_price NUMERIC(10, 2),
    date_create DATE DEFAULT CURRENT_DATE NOT NULL,
    id_price_list INT NOT NULL
);

CREATE TABLE prices_jr (
    id_price_jr SERIAL PRIMARY KEY,
    old_price NUMERIC(10, 2) NOT NULL,
    new_price NUMERIC(10, 2) NOT NULL,
    date_create DATE DEFAULT CURRENT_DATE NOT NULL,
    id_price_list INT
);

ALTER TABLE product_card ADD CONSTRAINT fk_product_category FOREIGN KEY (id_category) REFERENCES product_category (id_category);
ALTER TABLE product_card ADD CONSTRAINT fk_product_unit FOREIGN KEY (id_unit) REFERENCES unit (id_unit);
ALTER TABLE product_card ADD CONSTRAINT fk_product_manufacturer FOREIGN KEY (id_manufacturer) REFERENCES manufacturer_catalogue (id_manufacturer);
ALTER TABLE manufacturer_catalogue ADD CONSTRAINT fk_manufacturer_country FOREIGN KEY (id_country) REFERENCES country_catalogue (id_country);
ALTER TABLE prices ADD CONSTRAINT fk_price_card FOREIGN KEY (id_price_list) REFERENCES price_list (id_price_list);
ALTER TABLE price_list ADD CONSTRAINT fk_price_promotion FOREIGN KEY (id_promotion) REFERENCES promotion_catalogue (id_promotion);
ALTER TABLE product_category ADD CONSTRAINT fk_category_markup FOREIGN KEY (id_category_markup) REFERENCES markup_category (id_category_markup);

--проверка на уникальность ИНН
ALTER TABLE manufacturer_catalogue
ADD CONSTRAINT unique_INN UNIQUE (INN);
--проверка высоты и ширины > 0
ALTER TABLE product_card
ADD CONSTRAINT positive_height CHECK (height > 0),
ADD CONSTRAINT positive_width CHECK (width > 0);
--проверка на цены
ALTER TABLE price_list
ADD CONSTRAINT positive_prices CHECK (entrance_price > 0 AND final_price > 0);
ALTER TABLE prices
ADD CONSTRAINT positive_main_price CHECK (main_price > 0);
ALTER TABLE prices
ADD CONSTRAINT positive_add_price CHECK (add_price >= 0);
ALTER TABLE prices_jr
ADD CONSTRAINT positive_old_price CHECK (old_price > 0);
ALTER TABLE prices_jr
ADD CONSTRAINT positive_new_price CHECK (new_price > 0);
--проверка дат
ALTER TABLE price_list
ADD CONSTRAINT date_range CHECK (date_create < date_end);
--проверка процентов
ALTER TABLE markup_category
ADD CONSTRAINT percent_range CHECK (percent_markup >= 0 AND percent_markup <= 100);


ALTER TABLE product_card 
ALTER COLUMN id_price DROP NOT NULL;

ALTER TABLE price_list 
ALTER COLUMN id_promotion DROP NOT NULL;
