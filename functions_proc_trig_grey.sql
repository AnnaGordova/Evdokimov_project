-- Пройедура change_price_list 

CREATE OR REPLACE PROCEDURE change_price_list(
    p_id_price_list price_list.id_price_list%type,
    p_new_price price_list.final_price%type
)
LANGUAGE plpgsql
AS
$$
-- Объявляем переменные
DECLARE
    v_current_price NUMERIC(10, 2);
    v_category_id INT;
    v_markup_percent NUMERIC(5, 2);
    v_delta_percent NUMERIC(5, 2);
    v_last_price NUMERIC(10, 2);
    v_is_stop BOOLEAN := FALSE;
BEGIN
    -- Получаем текущую цену и категорию продукта
    SELECT final_price, id_product INTO v_current_price, v_category_id
    FROM price_list
    WHERE id_price_list = p_id_price_list;
    -- Получаем наценку и допустимое изменение цены для категории продукта
    SELECT percent_markup, percent_delta INTO v_markup_percent, v_delta_percent
    FROM markup_category
    JOIN product_category ON markup_category.id_category_markup = product_category.id_category_markup
    WHERE product_category.id_category = v_category_id;
    -- Проверяем, не превышает ли новая цена допустимый предел
    IF p_new_price > v_current_price * (1 + v_markup_percent / 100) THEN
        v_is_stop := TRUE;
    END IF;

    -- Проверяем, не превышает ли изменение цены допустимый процент
    SELECT final_price INTO v_last_price
    FROM price_list
    WHERE id_product = (SELECT id_product FROM price_list WHERE id_price_list = p_id_price_list)
    ORDER BY date_create DESC LIMIT 1;

    IF ABS(p_new_price - v_last_price) > v_last_price * (v_delta_percent / 100) THEN
        v_is_stop := TRUE;
    END IF;
    
    -- Если новой ценой превышены допустимые пределы, останавливаем продажу продукта
    IF v_is_stop THEN
        UPDATE product_card
        SET is_stop = TRUE
        WHERE id_product = (SELECT id_product FROM price_list WHERE id_price_list = p_id_price_list);
    END IF;

    -- Обновляем цену продукта
    UPDATE price_list
    SET final_price = p_new_price
    WHERE id_price_list = p_id_price_list;
    
    RAISE NOTICE 'Price updated successfully';
END;
$$;


----------------------------------------------------------------------
-- Создаем функцию-триггер для отслеживания изменений цены
create FUNCTION trg_add_price_jr()
RETURNS TRIGGER AS $$
BEGIN
    -- Если новая цена отличается от старой
    IF NEW.final_price <> OLD.final_price THEN
        -- Вставляем запись в таблицу с историей цен
        INSERT INTO prices_jr (old_price, new_price, date_create, id_price_list)
        VALUES (OLD.final_price, NEW.final_price, CURRENT_DATE, NEW.id_price_list);
    END IF;
    -- Возвращаем новую цену
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Создаем триггер, который будет вызывать функцию-триггер после обновления поля final_price в таблице price_list
CREATE TRIGGER add_price_jr
AFTER UPDATE OF final_price
ON price_list
FOR EACH ROW
EXECUTE FUNCTION trg_add_price_jr();

----------------------------------------------------------------------

--- у меня нет таблиц sales, accepatance of goods
-- Процедура price_formation

CREATE OR REPLACE PROCEDURE price_formation(p_date DATE DEFAULT current_date)
LANGUAGE plpgsql AS $$
DECLARE
    rec RECORD;
    min_price NUMERIC(10, 2);
    min_price_list INT;
    prod_expired BOOLEAN;
BEGIN
    -- Итерируемся по всем продуктам
    FOR rec IN
        SELECT p.id_product, p.id_price, p.id_category, p.id_unit, p.id_manufacturer
        FROM product_card p
    LOOP
        -- Если у продукта еще нет цены
        IF rec.id_price IS NULL THEN
        -- Находим минимальную цену для этого продукта на заданную дату
            SELECT MIN(pl.final_price), pl.id_price_list
            INTO min_price, min_price_list
            FROM price_list pl
            WHERE pl.id_product = rec.id_product
              AND pl.date_create <= p_date
              AND pl.date_end >= p_date
            GROUP BY pl.id_product;
            -- Вставляем новую запись в таблицу цен с минимальной ценой
            INSERT INTO prices (main_price, date_create, id_price_list)
            VALUES (min_price, p_date, min_price_list);
        ELSE
            -- Находим минимальную цену для этого продукта на заданную дату из существующих цен
            SELECT pl.final_price, pl.id_price_list
            INTO min_price, min_price_list
            FROM price_list pl
            WHERE pl.id_product = rec.id_product
              AND pl.id_price_list = rec.id_price
              AND pl.date_create <= p_date
              AND pl.date_end >= p_date
            LIMIT 1;
            -- Если найденная минимальная цена отличается от текущей цены продукта
            IF rec.id_price <> min_price_list THEN
                -- Вставляем новую запись в таблицу цен с минимальной ценой
                INSERT INTO prices (main_price, date_create, id_price_list)
                VALUES (min_price, p_date, min_price_list);
            END IF;
        END IF;
        -- Выполняем функцию проверки срока годности продукта
        PERFORM product_expired(rec.id_product, p_date);
        -- Если продукт просрочен
        IF FOUND THEN
            -- Находим минимальную цену для просроченного продукта на заданную дату
            SELECT MIN(pl.final_price), pl.id_price_list
            INTO min_price, min_price_list
            FROM price_list pl
            WHERE pl.id_product = rec.id_product
              AND pl.date_create <= p_date
              AND pl.date_end >= p_date
            GROUP BY pl.id_product;
            -- Обновляем цену просроченного продукта в таблице цен
            UPDATE prices
            SET main_price = min_price, id_price_list = min_price_list
            WHERE id_product = rec.id_product;
        END IF;
    END LOOP;
END;
$$;


----------------------------------------------------------------------
--- НЕТУ ТАБЛИЦ
-- Функция product_expired

CREATE OR REPLACE FUNCTION product_expired(
    p_id_product INT,
    p_date DATE DEFAULT current_date
)
RETURNS BOOLEAN AS $$
DECLARE
    total_sales NUMERIC(10, 2);
    total_received NUMERIC(10, 2);
    total_in_stock NUMERIC(10, 2);
    expiration_date DATE;
    remaining_stock NUMERIC(10, 2);
BEGIN
    -- Получаем дату истечения срока годности продукта
    SELECT expiration_date
    INTO expiration_date
    FROM product_card
    WHERE id_product = p_id_product;
    IF expiration_date <= p_date THEN
        RETURN TRUE;
    END IF;
    -- Получаем общее количество проданного продукта
    SELECT COALESCE(SUM(sale_quantity), 0)
    INTO total_sales
    FROM sales
    WHERE product_id = p_id_product
      AND sale_date <= p_date;
    -- Получаем общее количество поступившего продукта
    SELECT COALESCE(SUM(received_quantity), 0)
    INTO total_received
    FROM acceptance_of_goods
    WHERE product_id = p_id_product
      AND acceptance_date <= p_date;
    -- Рассчитываем общее количество продукта в наличии
    total_in_stock := total_received - total_sales;
    -- Рассчитываем процент оставшегося продукта
    remaining_stock := (total_in_stock / total_received) * 100;

    -- Проверяем, осталось ли менее 10% продукта
    IF remaining_stock <= 10 THEN
        RETURN TRUE;  
    ELSE
        RETURN FALSE; 
    END IF;
END;
$$ LANGUAGE plpgsql;

----------------------------------------------------------------------
-- Тип stop_table

CREATE TYPE stop_table AS (
    id_product INT,
    name_product VARCHAR(255),
    final_price NUMERIC(10, 2),
    start_price NUMERIC(10, 2)
);

-- Функция product_in_stop

CREATE OR REPLACE FUNCTION product_in_stop()
RETURNS SETOF stop_table AS $$
DECLARE
    product_record RECORD;
BEGIN
    -- Итерируемся по всем продуктам с установленным флагом остановки продаж
    FOR product_record IN
        SELECT 
            p.id_product,
            p.name,
            pl.final_price,
            pl.entrance_price
        FROM product_card p
        JOIN price_list pl ON p.id_product = pl.id_product
        WHERE p.is_stop = TRUE
    LOOP
        -- Снимаем флаг остановки продаж для продукта
        UPDATE product_card
        SET is_stop = FALSE
        WHERE id_product = product_record.id_product;
        -- Возвращаем текущую запись продукта
        RETURN NEXT product_record;
    END LOOP;

    -- Если в таблице нет продуктов с установленным флагом остановки продаж, то возвращаем пустое множество
    RETURN;
END;
$$ LANGUAGE plpgsql;

----------------------------------------------------------------------
-- Тип new_prices

CREATE TYPE new_prices AS (
    id_product INT,
    name_product VARCHAR(255),
    main_price NUMERIC(10, 2),
    add_price NUMERIC(10, 2),
    type_price SMALLINT,
    prom_text VARCHAR(255),
    id_shelf INT
);

-- НЕТУУУУУУУУУУУУУУУУУУУ
-- Функция get_new_prices

CREATE OR REPLACE FUNCTION get_new_prices(p_date DATE DEFAULT CURRENT_DATE)
RETURNS SETOF new_prices AS $$
DECLARE
    new_price_record RECORD;
BEGIN
    -- Итерируемся по всем продуктам с установленным флагом остановки продаж и получившим новую цену на заданную дату
    FOR new_price_record IN
        SELECT 
            p.id_product,
            p.name AS name_product,
            pr.main_price,
            pr.add_price,
            pl.price_type AS type_price,
            pc.name AS prom_text,
            pos.id_shelf
        FROM product_card p
        JOIN prices pr ON p.id_product = pr.id_product
        JOIN price_list pl ON pr.id_price_list = pl.id_price_list
        LEFT JOIN promotion_catalogue pc ON pr.id_promotion = pc.id_promotion
        JOIN product_on_shelf pos ON p.id_product = pos.id_product
        WHERE p.is_stop = TRUE
        AND pr.date_create = p_date
    LOOP
        -- Возвращаем текущую запись с информацией о новом продукте и его цене
        RETURN NEXT new_price_record;
    END LOOP;

    -- Если в таблице нет продуктов с установленным флагом остановки продаж и получивших новую цену на заданную дату, то возвращаем пустое множество
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- Пример использования функции
SELECT * FROM get_new_prices('2025-01-01');

----------------------------------------------------------------------
-- Процедура get_price_lists_for_product

CREATE OR REPLACE PROCEDURE get_price_lists_for_product(
    p_id_product INT,
    p_date DATE DEFAULT CURRENT_DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    r_price_list RECORD;
BEGIN
    FOR r_price_list IN
        SELECT 
            pl.id_price_list,
            pl.entrance_price,
            pl.final_price,
            pl.price_type,
            pl.date_create,
            pl.date_end
        FROM price_list pl
        JOIN product_card p ON pl.id_product = p.id_product
        WHERE p.id_product = p_id_product
        AND p_date BETWEEN pl.date_create AND COALESCE(pl.date_end, CURRENT_DATE)
        ORDER BY pl.date_create
    LOOP
        RAISE NOTICE 'id_price_list: %, entrance_price: %, final_price: %, price_type: %, date_create: %, date_end: %',
            r_price_list.id_price_list,
            r_price_list.entrance_price,
            r_price_list.final_price,
            r_price_list.price_type,
            r_price_list.date_create,
            r_price_list.date_end;
    END LOOP;
END;
$$;



----------------------------------------------------------------------
-- Процедура bind_price_list_to_product

CREATE OR REPLACE PROCEDURE bind_price_list_to_product(
    p_id_price_list INT,
    p_date DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_price_list RECORD;
    v_rc_price_list RECORD;
BEGIN
    SELECT *
    INTO v_price_list
    FROM price_list
    WHERE id_price_list = p_id_price_list
      AND date_create <= p_date
      AND (date_end IS NULL OR date_end >= p_date);

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Price list % is not active on date %', p_id_price_list, p_date;
    END IF;
    IF v_price_list.price_type IN (1, 2) THEN
        SELECT *
        INTO v_rc_price_list
        FROM price_list
        WHERE id_product = v_price_list.id_product
          AND price_type = 0
          AND date_create <= p_date
          AND (date_end IS NULL OR date_end >= p_date)
        ORDER BY final_price ASC
        LIMIT 1;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'No active RC price list found for product % on date %', v_price_list.id_product, p_date;
        END IF;
        INSERT INTO prices (main_price, add_price, date_create, id_price_list)
        VALUES (v_rc_price_list.final_price, v_price_list.final_price, p_date, p_id_price_list);

    ELSE
        INSERT INTO prices (main_price, add_price, date_create, id_price_list)
        VALUES (v_price_list.final_price, NULL, p_date, p_id_price_list);
    END IF;

    RAISE NOTICE 'Price list % successfully bound to product % on date %', p_id_price_list, v_price_list.id_product, p_date;
END;
$$;
----------------------------------------------------------------------





-- ПРАВКА ПРОЦЕДУР И ФУНКЦИЙ ОТ ДЕНЗЕЛЯ --
----------------------------------------------------------------------
-- 1) Процедура change_price_list
-- Назначение: добавление новой строки в таблицу Write off, уменьшение количества товара на полке

CREATE OR REPLACE PROCEDURE change_price_list(
  IN p_id_price_list integer,
  IN p_new_price numeric(10, 2)
)
LANGUAGE plpgsql AS
$$
DECLARE
  v_current_price numeric(10, 2);
  v_percent_markup numeric(5, 2);
  v_percent_delta numeric(5, 2);
BEGIN
  -- Получить текущую цену товара
  SELECT
    final_price
  INTO
    v_current_price
  FROM
    price_list
  WHERE
    id_price_list = p_id_price_list;

  -- Проверка, действительна ли новая цена
  IF v_current_price IS NULL THEN
    RAISE EXCEPTION 'Invalid price list ID';
  ELSIF p_new_price <= 0 THEN
    RAISE EXCEPTION 'Invalid new price';
  END IF;

  -- Получение наценки и дельта-проценты для категории продукта
  SELECT
    percent_markup,
    percent_delta
  INTO
    v_percent_markup,
    v_percent_delta
  FROM
    markup_category
  WHERE
    id_category_markup = (
      SELECT
        id_category_markup
      FROM
        product_category
      WHERE
        id_category = (
          SELECT
            id_category
          FROM
            product_card
          WHERE
            id_product = (
              SELECT
                id_product
              FROM
                price_list
              WHERE
                id_price_list = p_id_price_list
            )
        )
    );

  -- Проверка, не превышает ли новая цена максимальную наценку
  IF (p_new_price / v_current_price - 1) * 100 > v_percent_markup THEN
    -- Обновление флага is_stop для продукта на true
    UPDATE
      product_card
    SET
      is_stop = true
    WHERE
      id_product = (
        SELECT
          id_product
        FROM
          price_list
        WHERE
          id_price_list = p_id_price_list
      );
  END IF;

  -- Проверка, не превышает ли новое изменение цены максимальную дельту
  IF ABS((p_new_price - v_current_price) / v_current_price) * 100 > v_percent_delta THEN
    -- Обновление флага is_stop для продукта на true
    UPDATE
      product_card
    SET
      is_stop = true
    WHERE
      id_product = (
        SELECT
          id_product
        FROM
          price_list
        WHERE
          id_price_list = p_id_price_list
      );
  END IF;

  -- Обновление прайс-листа новой ценой
  UPDATE
    price_list
  SET
    final_price = p_new_price
  WHERE
    id_price_list = p_id_price_list;

  -- Вставка новой строки в таблицу списания
  INSERT INTO
    write_off(
      id_product,
      quantity
    )
    VALUES(
      (
        SELECT
          id_product
        FROM
          price_list
        WHERE
          id_price_list = p_id_price_list
      ),
      (
        SELECT
          quantity
        FROM
          stock
        WHERE
          id_product = (
            SELECT
              id_product
            FROM
              price_list
            WHERE
              id_price_list = p_id_price_list
          )
        ORDER BY
          date_create
        DESC
        LIMIT 1
      )
    );

  -- Обновление количества на складе
  UPDATE
    stock
  SET
    quantity = (
      SELECT
        SUM(quantity)
      FROM
        stock
      WHERE
        id_product = (
          SELECT
            id_product
          FROM
            price_list
          WHERE
            id_price_list = p_id_price_list
        )
    )
  WHERE
    id_product = (
      SELECT
        id_product
      FROM
        price_list
      WHERE
        id_price_list = p_id_price_list
    );
END;
$$;



----------------------------------------------------------------------
-- 2) Процедура price_formation
-- Назначение: Обновление таблицы prices с установкой актуальных цен.

CREATE OR REPLACE PROCEDURE price_formation(
  IN p_date date DEFAULT CURRENT_DATE
)
LANGUAGE plpgsql AS
$$
DECLARE
  v_product_id integer;
  v_store_id integer;
  v_main_price numeric(10, 2);
  v_add_price numeric(10, 2);
  v_price_list_id integer;
  v_price_list_id_min integer;
  v_price numeric(10, 2);
  v_is_expired boolean;
BEGIN
  -- Просмотр всех продуктов в цикле
  FOR v_product_id IN SELECT id_product FROM product_card LOOP
    -- Получение идентификаторов магазина для продукта
    SELECT
      id_store
    INTO
      v_store_id
    FROM
      stock
    WHERE
      id_product = v_product_id
    ORDER BY
      date_create
    DESC
    LIMIT 1;

    -- Проверка, есть ли у товара ссылка на таблицу цен
    IF EXISTS(
      SELECT
        1
      FROM
        prices
      WHERE
        id_product = v_product_id
    ) THEN
      -- Получение текущей цены из таблицы цен
      SELECT
        main_price,
        add_price,
        price_list_id
      INTO
        v_main_price,
        v_add_price,
        v_price_list_id
      FROM
        prices
      WHERE
        id_product = v_product_id;

      -- Проверка, отличается ли текущая цена от цены в таблице price_list
      SELECT
        final_price
      INTO
        v_price
      FROM
        price_list
      WHERE
        id_price_list = v_price_list_id;

      IF v_price <> v_main_price THEN
        -- Получение минимальной цены на товар и магазина из таблицы price_list
        SELECT
          id_price_list,
          final_price
        INTO
          v_price_list_id_min,
          v_main_price
        FROM
          price_list
        WHERE
          id_product = v_product_id
          AND id_store = v_store_id
          AND price_type = 0
          AND date_create <= p_date
        ORDER BY
          final_price
        LIMIT 1;

        -- Обновление таблицы цен с помощью новой цены и идентификатора price_list
        UPDATE
          prices
        SET
          main_price = v_main_price,
          price_list_id = v_price_list_id_min
        WHERE
          id_product = v_product_id;
      END IF;
    ELSE
      -- Получение минимальной обычной цены на товар и магазина из таблицы price_list
      SELECT
        id_price_list,
        final_price
      INTO
        v_price_list_id_min,
        v_main_price
      FROM
        price_list
      WHERE
        id_product = v_product_id
        AND id_store = v_store_id
        AND price_type = 0
        AND date_create <= p_date
      ORDER BY
        final_price
      LIMIT 1;

      -- Проверка, не истек ли срок годности продукта
      SELECT
        product_expired(v_product_id, p_date)
      INTO
        v_is_expired;

      IF v_is_expired THEN
        -- Получение минимальной цены оформления заказа для товара и магазина из таблицы price_list
        SELECT
          id_price_list,
          final_price
        INTO
          v_price_list_id_min,
          v_add_price
        FROM
          price_list
        WHERE
          id_product = v_product_id
          AND id_store = v_store_id
          AND price_type = 2
          AND date_create <= p_date
        ORDER BY
          final_price
        LIMIT 1;
      END IF;

      -- Вставка новой строки в таблицу цен
      INSERT INTO
        prices(
          id_product,
          main_price,
          add_price,
          price_list_id
        )
        VALUES(
          v_product_id,
          v_main_price,
          v_add_price,
          v_price_list_id_min
        );
    END IF;
  END LOOP;
END;
$$;



----------------------------------------------------------------------
-- 3) Функция product_expired
-- Назначение: Проверка на истекание срока годности у товара.

CREATE OR REPLACE FUNCTION product_expired(
  p_id_product integer,
  p_date date DEFAULT CURRENT_DATE
)
RETURNS BOOLEAN AS
$$
DECLARE
  v_expiration_date date;
  v_quantity_sold integer;
  v_quantity_accepted integer;
  v_quantity_left integer;
BEGIN
  -- Поиск срока годности продукта
  SELECT
    expiration_date
  INTO
    v_expiration_date
  FROM
    product_card
  WHERE
    id_product = p_id_product;

  -- Получение количества продуктов, проданных в период между датой истечения срока годности и текущей датой
  SELECT
    SUM(quantity)
  INTO
    v_quantity_sold
  FROM
    sale
  WHERE
    id_product = p_id_product
    AND date_sale >= v_expiration_date
    AND date_sale <= p_date;

  -- Получение количества продуктов, принятых в период между датой истечения срока годности и текущей датой
  SELECT
    SUM(quantity)
  INTO
    v_quantity_accepted
  FROM
    acceptance_of_goods
  WHERE
    id_product = p_id_product
    AND date_create >= v_expiration_date
    AND date_create <= p_date;

  -- Подсчет количества оставшихся продуктов
  v_quantity_left := v_quantity_accepted - v_quantity_sold;

  -- Возвращение значения true, если оставшееся количество продуктов составляет менее 10% от принятого количества, в противном случае вернется значение false
  RETURN CASE
    WHEN v_quantity_left < (v_quantity_accepted * 0.1) THEN true
    ELSE false
  END;
END;
$$
LANGUAGE plpgsql;



----------------------------------------------------------------------
-- 4) Функция get_new_prices
-- Назначение: возвращает таблицу с товарами в стопе, которые передаются ГК.

CREATE OR REPLACE FUNCTION get_new_prices(
    P_date DATE
)
RETURNS TABLE (
    id_product INT,
    name VARCHAR(255),
    expiration_date DATE,
    SKU VARCHAR(32),
    barcode_number VARCHAR(13),
    is_stop BOOLEAN,
    main_price NUMERIC(10, 2),
    entrance_price NUMERIC(10, 2),
    final_price NUMERIC(10, 2),
    price_type SMALLINT,
    id_promotion INT
)
AS $$
BEGIN
    RETURN QUERY
        SELECT
            pc.id_product,
            pc.name,
            pc.expiration_date,
            pc.SKU,
            pc.barcode_number,
            pc.is_stop,
            pr.main_price,
            pl.entrance_price,
            pl.final_price,
            pl.price_type,
            pl.id_promotion
        FROM Product_card AS pc
        JOIN Prices AS pr
            ON pc.id_price = pr.id_price
        JOIN Price_list AS pl
            ON pr.id_price_list = pl.id_price_list
        LEFT JOIN Product_on_shelf AS pos
            ON pc.id_product = pos.id_product
        LEFT JOIN Promotion_catalogue AS promo
            ON pl.id_promotion = promo.id_promotion
        WHERE
            pr.date_create = P_date AND pc.is_stop = TRUE;
END;
$$ LANGUAGE plpgsql;
