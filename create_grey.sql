-- Желтые таблицы

CREATE TABLE product_card (
    id_product SERIAL PRIMARY KEY, -- Уникальный идентификатор продукта
    name VARCHAR(255), -- Наименование продукта
    id_manufacturer INT NOT NULL, -- Код производителя, ссылка на manufacturer_catalogue
    id_category INT NOT NULL, -- Код категории, ссылка на product_category
    id_unit INT NOT NULL, -- Код единицы измерения, ссылка на unit
    id_price INT NOT NULL, -- Код ценника, ссылка на prices
    height NUMERIC(10, 2), -- Высота продукта
    width NUMERIC(10, 2), -- Ширина продукта
    length NUMERIC(10, 2), -- Длина продукта
    expiration_date INT, -- Срок годности
    SKU VARCHAR(32), -- Артикул
    barcode_number VARCHAR(13), -- Штрих-код
    is_stop BOOLEAN DEFAULT FALSE NOT NULL,
    CONSTRAINT product_manufacturer_fk FOREIGN KEY (id_manufacturer) REFERENCES manufacturer_catalogue (id_manufacturer),
    CONSTRAINT product_category_fk FOREIGN KEY (id_category) REFERENCES product_category (id_category),
    CONSTRAINT product_unit_fk FOREIGN KEY (id_unit) REFERENCES unit (id_unit),
    CONSTRAINT product_price_fk FOREIGN KEY (id_price) REFERENCES prices (id_price)
);

CREATE TABLE manufacturer_catalogue (
    id_manufacturer SERIAL PRIMARY KEY, -- Уникальный идентификатор производителя
    id_country INT NOT NULL, -- Код страны, ссылка на таблицу стран
    name_ru VARCHAR(255), -- Название производителя на русском языке
    name_eng VARCHAR(255), -- Название производителя на английском языке
    INN VARCHAR(12), -- Идентификационный номер налогоплательщика
    CONSTRAINT manufacturer_country_fk FOREIGN KEY (id_country) REFERENCES country (id_country)
);

CREATE TABLE country_catalogue (
    id_country SERIAL PRIMARY KEY, -- Уникальный идентификатор страны
    name VARCHAR(255) NOT NULL -- Наименование страны
);

-- серые таблицы

CREATE TABLE unit (
    id_unit SERIAL PRIMARY KEY, -- Уникальный идентификатор единицы измерения
    name VARCHAR(255) NOT NULL -- Наименование единицы измерения
);

CREATE TABLE markup_category (
    id_category_markup SERIAL PRIMARY KEY, -- Уникальный идентификатор категории наценки
    percent_markup NUMERIC(5, 2), -- Процент наценки на товары данной категории
    percent_delta NUMERIC(5, 2), -- Процент изменения наценки
    date_change DATE NOT NULL, -- Дата последнего изменения наценки 
    CONSTRAINT markup_pk PRIMARY KEY (id_category_markup) 
);

CREATE TABLE price_list (
    id_price_list SERIAL PRIMARY KEY, -- Уникальный идентификатор записи о цене
    id_product INT NOT NULL, -- Ссылка на карточку продукта
    id_store INT, -- Ссылка на магазин
    entrance_price NUMERIC(10, 2), -- Входная цена
    final_price NUMERIC(10, 2), -- Итоговая цена
    price_type SMALLINT, -- Тип цены (0 — регулярная, 1 — уценка, 2 — акция)
    id_promotion INT NOT NULL, -- Ссылка на промоакцию
    date_create DATE NOT NULL DEFAULT CURRENT_DATE, -- Дата создания цены
    date_end DATE, -- Дата окончания действия цены
    CONSTRAINT price_product_fk FOREIGN KEY (id_product) REFERENCES product_card (id_product),
    CONSTRAINT price_promotion_fk FOREIGN KEY (id_promotion) REFERENCES promotion_catalogue (id_promotion)
);

CREATE TABLE promotion_catalogue (
    id_promotion SERIAL PRIMARY KEY, -- Уникальный идентификатор промоакции
    name VARCHAR(255) -- Наименование промоакции
);

CREATE TABLE product_category (
    id_category SERIAL PRIMARY KEY, -- Уникальный идентификатор категории продукта
    id_category_markup INT NOT NULL, -- Ссылка на категорию наценки
    name VARCHAR(255) NOT NULL, -- Наименование категории товара
    CONSTRAINT category_markup_fk FOREIGN KEY (id_category_markup) REFERENCES category_markup (id_category_markup)
);

CREATE TABLE prices (
    id_price SERIAL PRIMARY KEY, -- Уникальный идентификатор цены
    id_price_list INT NOT NULL, -- Ссылка на идентификатор прайс-листа
    main_price NUMERIC(10, 2) NOT NULL, -- Основная цена
    add_price NUMERIC(10, 2), -- Дополнительная цена (опционально)
    date_create DATE NOT NULL DEFAULT CURRENT_DATE, -- Дата создания записи
    CONSTRAINT pr_price_list_fk FOREIGN KEY (id_price_list) REFERENCES price_list(id_price_list)
);

CREATE TABLE price_jr (
    id_price_jr SERIAL PRIMARY KEY, -- Уникальный идентификатор записи о цене
    id_price_list INT NOT NULL, -- Ссылка на идентификатор прайс-листа
    old_price NUMERIC(10, 2) NOT NULL, -- Старая цена
    new_price NUMERIC(10, 2) NOT NULL, -- Новая цена
    date_create DATE NOT NULL DEFAULT CURRENT_DATE, -- Дата создания записи
    CONSTRAINT prjr_price_list_fk FOREIGN KEY (id_price_list) REFERENCES price_list(id_price_list)
);

-- почему то на картинке нет point но в ТЗ он есть

CREATE TABLE point (
    id_point SERIAL PRIMARY KEY, -- Уникальный идентификатор торговой точки
    name VARCHAR(255), -- Название торговой точки
    address VARCHAR(255) -- Адрес торговой точки
);


