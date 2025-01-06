
CREATE OR REPLACE PROCEDURE change_price_list(
    p_id_price_list price_list.id_price_list%type,
    p_new_price price_list.final_price%type
)
LANGUAGE plpgsql
AS
$$
DECLARE
    v_current_price NUMERIC(10, 2);
    v_category_id INT;
    v_markup_percent NUMERIC(5, 2);
    v_delta_percent NUMERIC(5, 2);
    v_last_price NUMERIC(10, 2);
    v_is_stop BOOLEAN := FALSE;
BEGIN
    SELECT final_price, id_product INTO v_current_price, v_category_id
    FROM price_list
    WHERE id_price_list = p_id_price_list;
    SELECT percent_markup, percent_delta INTO v_markup_percent, v_delta_percent
    FROM markup_category
    JOIN product_category ON markup_category.id_category_markup = product_category.id_category_markup
    WHERE product_category.id_category = v_category_id;
    IF p_new_price > v_current_price * (1 + v_markup_percent / 100) THEN
        v_is_stop := TRUE;
    END IF;

    SELECT final_price INTO v_last_price
    FROM price_list
    WHERE id_product = (SELECT id_product FROM price_list WHERE id_price_list = p_id_price_list)
    ORDER BY date_create DESC LIMIT 1;

    IF ABS(p_new_price - v_last_price) > v_last_price * (v_delta_percent / 100) THEN
        v_is_stop := TRUE;
    END IF;

    IF v_is_stop THEN
        UPDATE product_card
        SET is_stop = TRUE
        WHERE id_product = (SELECT id_product FROM price_list WHERE id_price_list = p_id_price_list);
    END IF;

    UPDATE price_list
    SET final_price = p_new_price
    WHERE id_price_list = p_id_price_list;
    
    RAISE NOTICE 'Price updated successfully';
END;
$$;


---------------------------------

create FUNCTION trg_add_price_jr()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.final_price <> OLD.final_price THEN
        INSERT INTO prices_jr (old_price, new_price, date_create, id_price_list)
        VALUES (OLD.final_price, NEW.final_price, CURRENT_DATE, NEW.id_price_list);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER add_price_jr
AFTER UPDATE OF final_price
ON price_list
FOR EACH ROW
EXECUTE FUNCTION trg_add_price_jr();

-------------------------------

--- у меня нет таблиц sales, accepatance of goods

CREATE OR REPLACE PROCEDURE price_formation(p_date DATE DEFAULT current_date)
LANGUAGE plpgsql AS $$
DECLARE
    rec RECORD;
    min_price NUMERIC(10, 2);
    min_price_list INT;
    prod_expired BOOLEAN;
BEGIN
    FOR rec IN
        SELECT p.id_product, p.id_price, p.id_category, p.id_unit, p.id_manufacturer
        FROM product_card p
    LOOP
        IF rec.id_price IS NULL THEN
            SELECT MIN(pl.final_price), pl.id_price_list
            INTO min_price, min_price_list
            FROM price_list pl
            WHERE pl.id_product = rec.id_product
              AND pl.date_create <= p_date
              AND pl.date_end >= p_date
            GROUP BY pl.id_product;
            INSERT INTO prices (main_price, date_create, id_price_list)
            VALUES (min_price, p_date, min_price_list);
        ELSE
            SELECT pl.final_price, pl.id_price_list
            INTO min_price, min_price_list
            FROM price_list pl
            WHERE pl.id_product = rec.id_product
              AND pl.id_price_list = rec.id_price
              AND pl.date_create <= p_date
              AND pl.date_end >= p_date
            LIMIT 1;
            IF rec.id_price <> min_price_list THEN
                INSERT INTO prices (main_price, date_create, id_price_list)
                VALUES (min_price, p_date, min_price_list);
            END IF;
        END IF;
        PERFORM product_expired(rec.id_product, p_date);
        IF FOUND THEN
            SELECT MIN(pl.final_price), pl.id_price_list
            INTO min_price, min_price_list
            FROM price_list pl
            WHERE pl.id_product = rec.id_product
              AND pl.date_create <= p_date
              AND pl.date_end >= p_date
            GROUP BY pl.id_product;
            UPDATE prices
            SET main_price = min_price, id_price_list = min_price_list
            WHERE id_product = rec.id_product;
        END IF;
    END LOOP;
END;
$$;


-----------------
--- НЕТУ ТАБЛИЦ

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
    SELECT expiration_date
    INTO expiration_date
    FROM product_card
    WHERE id_product = p_id_product;
    IF expiration_date <= p_date THEN
        RETURN TRUE;
    END IF;
    SELECT COALESCE(SUM(sale_quantity), 0)
    INTO total_sales
    FROM sales
    WHERE product_id = p_id_product
      AND sale_date <= p_date;
    SELECT COALESCE(SUM(received_quantity), 0)
    INTO total_received
    FROM acceptance_of_goods
    WHERE product_id = p_id_product
      AND acceptance_date <= p_date;
    total_in_stock := total_received - total_sales;
    remaining_stock := (total_in_stock / total_received) * 100;

    IF remaining_stock <= 10 THEN
        RETURN TRUE;  
    ELSE
        RETURN FALSE; 
    END IF;
END;
$$ LANGUAGE plpgsql;

--------------

CREATE TYPE stop_table AS (
    id_product INT,
    name_product VARCHAR(255),
    final_price NUMERIC(10, 2),
    start_price NUMERIC(10, 2)
);

CREATE OR REPLACE FUNCTION product_in_stop()
RETURNS SETOF stop_table AS $$
DECLARE
    product_record RECORD;
BEGIN
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
        UPDATE product_card
        SET is_stop = FALSE
        WHERE id_product = product_record.id_product;
        RETURN NEXT product_record;
    END LOOP;

    RETURN;
END;
$$ LANGUAGE plpgsql;

--------------

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

CREATE OR REPLACE FUNCTION get_new_prices(p_date DATE DEFAULT CURRENT_DATE)
RETURNS SETOF new_prices AS $$
DECLARE
    new_price_record RECORD;
BEGIN
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
        RETURN NEXT new_price_record;
    END LOOP;

    RETURN;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_new_prices('2025-01-01');

----------------------

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



-------------------

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


-- ПРАВКА ПРОЦЕДУР И ФУНКЦИЙ ОТ ДЕНЗЕЛЯ --
----------------------------------------------------------------------
-- Процедура change_price_list
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
