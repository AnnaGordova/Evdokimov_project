INSERT INTO country_catalogue (name)
VALUES 
('Россия'),
('США'),
('Германия');

INSERT INTO promotion_catalogue (name)
VALUES 
('Скидка 10%'),
('Акция 1+1'),
('Черная пятница');


INSERT INTO markup_category (percent_markup, percent_delta, date_change)
VALUES
(15.00, 5.00, '2025-01-01'),
(10.00, 3.00, '2025-01-02'),
(20.00, 7.00, '2025-01-03');

INSERT INTO product_category (name, id_category_markup)
VALUES 
('Электроника', 1),
('Одежда', 2),
('Игрушки', 3);

INSERT INTO unit (name)
VALUES 
('Штука'),
('Килограмм'),
('Метр');

INSERT INTO manufacturer_catalogue (name_ru, name_eng, INN, id_country)
VALUES
('Производитель 1', 'Manufacturer 1', '123456789012', 1),
('Производитель 2', 'Manufacturer 2', '987654321098', 2),
('Производитель 3', 'Manufacturer 3', '123498765432', 3);

INSERT INTO product_card (name, height, width, length, expiration_date, SKU, barcode_number, is_stop, id_price, id_manufacturer, id_category, id_unit)
VALUES
('Телефон', 15.0, 7.5, 0.8, '2025-12-31', 'SKU123456', '1234567890123', FALSE, 1, 1, 1, 1),
('Куртка', 100.0, 60.0, 2.0, '2025-11-30', 'SKU234567', '2345678901234', FALSE, 2, 2, 2, 2),
('Плюшевый медведь', 50.0, 40.0, 15.0, '2026-01-01', 'SKU345678', '3456789012345', FALSE, 3, 3, 3, 3);

INSERT INTO price_list (entrance_price, final_price, price_type, date_create, date_end, id_product, id_store, id_promotion)
VALUES
(1000.00, 1200.00, 0, '2025-01-01', '2025-12-31', 1, 1, 1),
(500.00, 550.00, 1, '2025-01-01', '2025-12-31', 2, 2, 2),
(300.00, 350.00, 2, '2025-01-01', '2025-12-31', 3, 3, 3);

INSERT INTO prices (main_price, add_price, date_create, id_price_list)
VALUES
(1200.00, 0.00, '2025-01-01', 1),
(550.00, 0.00, '2025-01-01', 2),
(350.00, 0.00, '2025-01-01', 3);

INSERT INTO prices_jr (old_price, new_price, date_create, id_price_list)
VALUES
(1000.00, 1100.00, '2025-01-01', 1),
(500.00, 550.00, '2025-01-01', 2),
(300.00, 350.00, '2025-01-01', 3);
