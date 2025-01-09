
-- Таблица Sale

CREATE TABLE Sale (
    id_sale SERIAL,
    id_employee INT NOT NULL CONSTRAINT sale_emp_fk REFERENCES Employee_catalogue(id_employee),
    id_product INT NOT NULL CONSTRAINT sale_product_fk REFERENCES Product_card(id_product),
    date_sale TIMESTAMP NOT NULL CONSTRAINT sale_date_nn CHECK (date_sale IS NOT NULL),
    quantity INT NOT NULL CONSTRAINT sale_quantity_ck CHECK (quantity > 0),
    CONSTRAINT sale_pk PRIMARY KEY (id_sale)
);


-- Таблица Driver_catalogue 


CREATE TABLE Driver_catalogue (
        id_driver SERIAL,
        first_name VARCHAR(50) NOT NULL,
        last_name VARCHAR(50) NOT NULL,
        date_of_birth DATE NOT NULL,
        license_number VARCHAR(20) NOT NULL UNIQUE,
        CONSTRAINT driver_cat_pk PRIMARY KEY (id_driver),
        CONSTRAINT date_of_birth_driver_ck CHECK (
            date_of_birth <= CURRENT_DATE - INTERVAL '18 years' AND 
            date_of_birth >= CURRENT_DATE - INTERVAL '60 years'
        )
    );

-- Таблица Type_point_catalogue (ЖЕЛТАЯ)

CREATE TABLE Type_point_catalogue (
    id_type_point SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- Таблица Place_catalogue (ЖЕЛТАЯ)


CREATE TABLE Place_catalogue (
    id_place SERIAL, -- Код места хранения
    id_point INT NOT NULL CONSTRAINT place_cat_point_fk REFERENCES Point(id_point), -- Код точки (ссылка на Point)
    id_type_point INT NOT NULL CONSTRAINT place_cat_type_point_fk REFERENCES Type_Point_catalogue(id_type_point), -- Код типа точки (ссылка на Type Point catalogue)
    activity VARCHAR(255) NOT NULL,
  CONSTRAINT place_cat_pk PRIMARY KEY (id_place), -- Первичный ключ
  CONSTRAINT place_cat_unique UNIQUE (id_point, id_type_point) --Ограничение уникальности комбинации
);


-- Таблица Contract


CREATE TABLE Contract (
    id_contract SERIAL,  -- Код договора
    id_point INT NOT NULL CONSTRAINT contract_point_fk REFERENCES Place_catalogue(id_place),  -- Код места (ссылка на Place_catalogue)
    id_driver INT NOT NULL CONSTRAINT contract_driver_fk REFERENCES Driver_catalogue(id_driver),  -- Код водителя (ссылка на Driver_catalogue)
    id_contractor INT NOT NULL CONSTRAINT contract_contractor_fk REFERENCES Contractor_catalogue(id_contractor),  -- Код контрагента (ссылка на Contractor_catalogue)
    date_create TIMESTAMP NOT NULL,  -- Дата поставки (NOT NULL)
    
    CONSTRAINT contract_date_nn CHECK (date_create IS NOT NULL),  -- Обязательное значение для поля
    CONSTRAINT contract_pk PRIMARY KEY (id_contract),  -- Первичный ключ
     CONSTRAINT contract_date_check CHECK (date_create <= CURRENT_TIMESTAMP AND date_create >= '2010-01-01 00:00:00'),
CONSTRAINT contract_unique UNIQUE (id_point, id_driver, id_contractor)
);




-- Таблица Car_catalogue (нет в ЕР Ангелины)


CREATE TABLE Car_catalogue (
    id_car SERIAL,  -- Код автомобиля
    brand VARCHAR(50) NOT NULL,  -- Марка автомобиля
    model VARCHAR(50) NOT NULL,  -- Модель автомобиля
    year INT,  -- Год выпуска автомобиля
    
    CONSTRAINT car_pk PRIMARY KEY (id_car),  -- Первичный ключ для поля id_car,
    CONSTRAINT year_car_cat_ck CHECK (year >= 1990 AND year <= date_part('year', CURRENT_DATE))
);


-- Таблица Truck_catalogue (ЖЕЛТАЯ)

CREATE TABLE Truck_catalogue (
    id_truck SERIAL,  -- Код грузовика
    id_car INT NOT NULL,  -- Код машины (ссылка на Car catalogue)
    id_driver INT NOT NULL,  -- Код водителя (ссылка на Driver catalogue)
    id_storage INT NOT NULL,  -- Код склада (ссылка на Place catalogue)
    
    CONSTRAINT truck_pk PRIMARY KEY (id_truck),  -- Первичный ключ для код грузовика
    CONSTRAINT truck_car_fk FOREIGN KEY (id_car) REFERENCES Car_catalogue(id_car),  -- Связь с таблицей Car catalogue
    CONSTRAINT truck_driver_fk FOREIGN KEY (id_driver) REFERENCES Driver_catalogue(id_driver),  -- Связь с таблицей Driver catalogue
    CONSTRAINT truck_storage_fk FOREIGN KEY (id_storage) REFERENCES Place_catalogue(id_place),  -- Связь с таблицей Place catalogue
    CONSTRAINT truck_unique UNIQUE (id_car, id_driver, id_storage)
);



-- Таблица Acceptance

CREATE TABLE Acceptance (
    id_acceptance SERIAL,  -- Идентификатор приемки (первичный ключ)
    id_employee INT NOT NULL CONSTRAINT accept_emp_fk REFERENCES Employee_catalogue(id_employee),  -- Код сотрудника (ссылка на Employee catalogue)
    id_contract INT NOT NULL CONSTRAINT accept_contr_fk REFERENCES Contract(id_contract),  -- Код договора (ссылка на Contract)
    id_truck INT NOT NULL CONSTRAINT accept_truck_fk REFERENCES Truck_catalogue(id_truck),  -- Код грузовика (ссылка на Truck catalogue)
    id_place INT NOT NULL CONSTRAINT accept_place_fk REFERENCES Place_catalogue(id_place),  -- Код точки магазина (ссылка на Place catalogue)
    date_create TIMESTAMP NOT NULL,  -- Дата приемки товара (NOT NULL)
    status VARCHAR(20) CHECK (status IN ('в обработке', 'обработано', 'отклонено')) DEFAULT 'в обработке',  -- Статус приемки товара (с ограничением)
    CONSTRAINT accept_pk PRIMARY KEY (id_acceptance)  -- Первичный ключ для id_acceptance
);



-- Таблица Acceptance_of_goods 


-- Создание ENUM типа для столбца 'decision'
CREATE TYPE acceptance_decision AS ENUM ('в ожидании', 'принять', 'отказать');

CREATE TABLE Acceptance_of_goods (
    id_accept_good SERIAL,  -- Код приемки товара (первичный ключ)
    id_acceptance INT NOT NULL CONSTRAINT accept_good_acc_fk REFERENCES Acceptance(id_acceptance),  -- Код приемки (ссылка на таблицу Acceptance)
    id_product INT NOT NULL CONSTRAINT accept_good_product_fk REFERENCES Product_card(id_product),  -- Код товара (ссылка на таблицу Product_card)
    quantity INT NOT NULL,  -- Количество принятого товара
    date_create TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Дата создания приемки товара (по умолчанию текущее время)
    is_match BOOLEAN NOT NULL,  -- Соответствие товара стандартам проверки
    comment TEXT,  -- Комментарий (причины отказа или другого типа результата)
    decision acceptance_decision NOT NULL DEFAULT 'в ожидании',  -- Статус решения (по умолчанию 'в ожидании')

    CONSTRAINT accept_good_quantity_ck CHECK (quantity >= 0),  -- Ограничение для количества товара
    CONSTRAINT accept_good_decision_ck CHECK (decision IN ('в ожидании', 'принять', 'отказать')),  -- Ограничение для значения столбца decision

    CONSTRAINT accept_good_pk PRIMARY KEY (id_accept_good)  -- Первичный ключ для id_accept_good
);


-- Таблица Shelf

-- Создаем тип ENUM для типа полки
CREATE TYPE shelf_type AS ENUM ('обычная', 'холодильник');

-- Создаем таблицу Shelf
CREATE TABLE Shelf (
    id_shelf SERIAL,  -- Код полки (первичный ключ)
    id_place INT NOT NULL,  -- Код места хранения (ссылка на таблицу Place_catalogue)
    hall_number INT NOT NULL,  -- Номер зала (обязательное поле)
    department_number INT NOT NULL,  -- Номер отдела (обязательное поле)
    type shelf_type NOT NULL,  -- Тип полки (ссылка на тип ENUM)
    
    CONSTRAINT shelf_place_fk FOREIGN KEY (id_place) REFERENCES Place_catalogue(id_place),  -- Внешний ключ (ссылка на Place_catalogue)
    CONSTRAINT shelf_pk PRIMARY KEY (id_shelf)  -- Первичный ключ для поля id_shelf
);

-- Таблица Product_on_shelf

CREATE TABLE Product_on_shelf (
    id_product_shelf SERIAL,  -- Код товара на полке
    id_product INT NOT NULL CONSTRAINT product_shelf_pr_fk REFERENCES Product_card(id_product),  -- Код товара (ссылка на Product_card)
    id_shelf INT NOT NULL CONSTRAINT product_shelf_sf_fk REFERENCES Shelf(id_shelf),  -- Номер полки (ссылка на Shelf)
    id_price_list INT NOT NULL CONSTRAINT product_shelf_price_list_fk REFERENCES Price_list(id_price_list),  -- Код прайс-листа (ссылка на Price_list)
    quantity INT NOT NULL CONSTRAINT product_shelf_quantity_ck CHECK (quantity >= 0),  -- Количество товара на полке (ограничение >= 0)
    automarkdown_status VARCHAR(20),  -- Статус автоуценки товара

    CONSTRAINT product_shelf_pk PRIMARY KEY (id_product_shelf)  -- Первичный ключ
);


-- Таблица Write_off

CREATE TABLE Write_Off (
    id_write_off SERIAL,  -- Код списания, первичный ключ
    id_product INT NOT NULL,
    CONSTRAINT write_off_product_fk FOREIGN KEY (id_product) REFERENCES Product_card(id_product),
    
    -- Код сотрудника
    id_employee INT NOT NULL,
    CONSTRAINT write_off_emp_fk FOREIGN KEY (id_employee) REFERENCES Employee_catalogue(id_employee),
    
    -- Код места
    id_place INT NOT NULL,
    CONSTRAINT write_off_place_fk FOREIGN KEY (id_place) REFERENCES Place_catalogue(id_place),
    
    -- Код полки
    id_product_shelf INT NOT NULL,
    CONSTRAINT write_off_shelf_fk FOREIGN KEY (id_product_shelf) REFERENCES Product_on_shelf(id_product_shelf),
    
    -- Дата списания
    date_create TIMESTAMP NOT NULL,  -- Ограничение NOT NULL
    CONSTRAINT write_off_date_nn CHECK (date_create IS NOT NULL),
    
    -- Количество списываемого товара
    quantity INT CHECK (quantity > 0),  -- Проверка на больше чем 0
    CONSTRAINT write_off_quantity_ck CHECK (quantity > 0),  -- Ограничение на значение больше 0
    
    -- Причина списания
    reason VARCHAR(255) NOT NULL,  -- Ограничение NOT NULL
    CONSTRAINT write_off_reason_nn CHECK (reason IS NOT NULL),  -- Ограничение NOT NULL для причины списания
    
    -- Комментарий к списанию
    comment TEXT,  -- Допускаются NULL значения
    
    -- Ограничения на поля таблицы
    CONSTRAINT write_off_pk PRIMARY KEY (id_write_off)  -- Первичный ключ для таблицы
);


-- Таблица Inventory

CREATE TABLE Inventory (
    id_inventory SERIAL,  -- Код инвентаризации
    CONSTRAINT inventory_pk PRIMARY KEY (id_inventory),  -- Первичный ключ для кодов инвентаризаций

    -- Код места, на котором проводилась инвентаризация
    id_point INT NOT NULL,  
    CONSTRAINT inventory_fk FOREIGN KEY (id_point) REFERENCES Place_catalogue(id_place),  -- Связь с таблицей Place_catalogue

    -- Код сотрудника, проводившего инвентаризацию
    id_employee INT NOT NULL,  
    CONSTRAINT inventory_emp_fk FOREIGN KEY (id_employee) REFERENCES Employee_catalogue(id_employee),  -- Связь с таблицей Employee_catalogue

    -- Дата проведения инвентаризации
    date_create TIMESTAMP NOT NULL,  
    CONSTRAINT inventory_date_nn CHECK (date_create IS NOT NULL),  -- Дата инвентаризации не может быть NULL

    -- Дополнительно можно добавить другие ограничения по требованиям
    CONSTRAINT inventory_date_ck CHECK (date_create <= CURRENT_TIMESTAMP)  -- Не может быть дата в будущем
);



-- Таблица Inventory_result

CREATE TABLE Inventory_result (
    id_inventory_result SERIAL,  -- Код результата инвентаризации
    CONSTRAINT inventory_result_pk PRIMARY KEY (id_inventory_result),  -- Первичный ключ для кодов результатов инвентаризаций

    -- Код инвентаризации
    id_inventory INT NOT NULL,  
    CONSTRAINT inventory_result_fk FOREIGN KEY (id_inventory) REFERENCES Inventory(id_inventory),  -- Связь с таблицей Inventory

    -- Код товара
    id_product INT NOT NULL,  
    CONSTRAINT inventory_result_product_fk FOREIGN KEY (id_product) REFERENCES Product_card(id_product),  -- Связь с таблицей Product card

    -- Количество фактического товара
    quantity INT CHECK (quantity >= 0),  -- Количество должно быть >= 0
    CONSTRAINT inventory_result_quantity_ck CHECK (quantity >= 0),  -- Условие: quantity >= 0

    -- Отклонение между ожидаемым и фактическим количеством
    delta INT  -- Разница между ожидаемым и фактическим количеством товара (может быть и отрицательной)
);


-- Таблица Product_in_contract

CREATE TABLE product_in_contract (
    id_product_contract SERIAL,  -- Код товара в договоре
    CONSTRAINT product_contract_pk PRIMARY KEY (id_product_contract),  -- Первичный ключ для товара в договоре

    -- Код договора
    id_contract INT NOT NULL,  
    CONSTRAINT product_contract_ct_fk FOREIGN KEY (id_contract) REFERENCES Contract(id_contract),  -- Связь с таблицей Contract

    -- Код товара
    id_product INT NOT NULL,  
    CONSTRAINT product_contract_pr_fk FOREIGN KEY (id_product) REFERENCES Product_card(id_product),  -- Связь с таблицей Product card

    -- Цена товара
    price NUMERIC(10,2) CHECK (price > 0),  -- Цена должна быть больше 0
    CONSTRAINT product_contract_price_ck CHECK (price > 0),  -- Условие: price > 0

    -- Дата поставки товара
    date_delivery TIMESTAMP NOT NULL,  -- Дата поставки не может быть пустой
    CONSTRAINT product_contract_date_nn CHECK (date_delivery IS NOT NULL),  -- Условие: date_delivery IS NOT NULL

    -- Количество товара
    quantity INT CHECK (quantity > 0),  -- Количество товара для поставки должно быть больше 0
    CONSTRAINT product_contract_quantity_ck CHECK (quantity > 0)  -- Условие: quantity > 0
);


-- Таблица Moving

CREATE TYPE moving_type_enum AS ENUM ('приход', 'расход');  -- Создаем ENUM тип для столбца "Тип перемещения"

CREATE TABLE Moving (
    id_moving SERIAL,  -- Код перемещения
    CONSTRAINT moving_pk PRIMARY KEY (id_moving),  -- Первичный ключ для перемещения

    -- Код товара
    id_product INT NOT NULL,  
    CONSTRAINT moving_product_fk FOREIGN KEY (id_product) REFERENCES Product_card(id_product),  -- Связь с таблицей Product card

    -- Код исходного места
    id_initial_place INT NOT NULL,  
    CONSTRAINT moving_initial_place_fk FOREIGN KEY (id_initial_place) REFERENCES Place_catalogue(id_place),  -- Связь с таблицей Place catalogue

    -- Код целевого места
    id_target_place INT NOT NULL,  
    CONSTRAINT moving_target_place_fk FOREIGN KEY (id_target_place) REFERENCES Place_catalogue(id_place),  -- Связь с таблицей Place catalogue

    -- Код исходной полки
    id_initial_shelf INT NOT NULL,  
    CONSTRAINT moving_initial_shelf_fk FOREIGN KEY (id_initial_shelf) REFERENCES Shelf(id_shelf),  -- Связь с таблицей Shelf

    -- Код целевой полки
    id_target_shelf INT NOT NULL,  
    CONSTRAINT moving_target_shelf_fk FOREIGN KEY (id_target_shelf) REFERENCES Shelf(id_shelf),  -- Связь с таблицей Shelf

    -- Дата перемещения
    date_move TIMESTAMP NOT NULL,  -- Дата перемещения не может быть пустой
    CONSTRAINT moving_date_nn CHECK (date_move IS NOT NULL),  -- Условие: date_move IS NOT NULL

    -- Тип перемещения
    type moving_type_enum,  -- Тип перемещения (приход, расход)
    
    -- Количество товара
    quantity INT CHECK (quantity > 0),  -- Количество товара для перемещения должно быть больше 0
    CONSTRAINT moving_quantity_ck CHECK (quantity > 0)  -- Условие: quantity > 0
);
