CREATE OR REPLACE PROCEDURE change_price_list(
    p_id_price_list INT,          -- Идентификатор прайс-листа
    p_new_price NUMERIC           -- Новая цена
)
LANGUAGE plpgsql AS
$$
DECLARE
    v_old_price NUMERIC;         -- Старая цена из прайс-листа
    v_markup NUMERIC;            -- Наценка
    v_product_category INT;      -- Категория товара
    v_max_markup NUMERIC;       -- Максимально допустимая наценка для категории
    v_max_delta NUMERIC;        -- Максимально допустимая дельта для изменения цены
    v_last_price NUMERIC;       -- Последняя цена из прайс-листа для товара
BEGIN
    SELECT final_price
    INTO v_old_price
    FROM price_list
    WHERE id_price_list = p_id_price_list;
    IF v_old_price IS NULL THEN
        RAISE EXCEPTION 'Price list entry not found for id_price_list = %', p_id_price_list;
    END IF;
    SELECT pc.category_id
    INTO v_product_category
    FROM product_card pc
    JOIN price_list pl ON pl.id_product = pc.id_product
    WHERE pl.id_price_list = p_id_price_list;

    SELECT markup_percentage
    INTO v_max_markup
    FROM markup_catalogy
    WHERE category_id = v_product_category;

    v_markup := (p_new_price - v_old_price) / v_old_price * 100;
    IF v_markup > v_max_markup THEN
        UPDATE product_card
        SET is_stop = 1
        WHERE id_product = (SELECT id_product FROM price_list WHERE id_price_list = p_id_price_list);
        RAISE NOTICE 'Product is marked as STOP due to markup exceedance.';
    END IF;

    SELECT final_price
    INTO v_last_price
    FROM price_list
    WHERE id_product = (SELECT id_product FROM price_list WHERE id_price_list = p_id_price_list)
    ORDER BY effective_date DESC LIMIT 1;

    v_max_delta := v_last_price * 0.10;

    IF ABS(p_new_price - v_last_price) > v_max_delta THEN
        UPDATE product_card
        SET is_stop = 1
        WHERE id_product = (SELECT id_product FROM price_list WHERE id_price_list = p_id_price_list);
        RAISE NOTICE 'Product is marked as STOP due to price delta exceedance.';
    END IF;
    UPDATE price_list
    SET final_price = p_new_price
    WHERE id_price_list = p_id_price_list;

    RAISE NOTICE 'Price updated successfully in price_list for id_price_list = %', p_id_price_list;
END;
$$;

CREATE OR REPLACE PROCEDURE price_formation(p_date DATE DEFAULT CURRENT_DATE)
LANGUAGE plpgsql
AS
$$
DECLARE
    rec RECORD;
    min_price NUMERIC;
    selected_price_list INT;
    expired BOOLEAN;
BEGIN
    FOR rec IN
        SELECT pc.id_product, pc.category_id, ps.id_price_list, ps.final_price
        FROM product_card pc
        LEFT JOIN prices ps ON pc.id_product = ps.id_product
    LOOP
        IF rec.id_price_list IS NULL THEN
            SELECT MIN(pl.final_price)
            INTO min_price
            FROM price_list pl
            WHERE pl.category_id = rec.category_id
              AND pl.product_id = rec.id_product
              AND pl.is_active = TRUE;

            SELECT pl.id_price_list
            INTO selected_price_list
            FROM price_list pl
            WHERE pl.final_price = min_price
              AND pl.product_id = rec.id_product
              AND pl.is_active = TRUE
            LIMIT 1;

            INSERT INTO prices(id_product, id_price_list, main_price)
            VALUES (rec.id_product, selected_price_list, min_price);
    
        ELSE
            IF rec.final_price <> (SELECT final_price FROM price_list WHERE id_price_list = rec.id_price_list) THEN
                SELECT MIN(pl.final_price)
                INTO min_price
                FROM price_list pl
                WHERE pl.category_id = rec.category_id
                  AND pl.product_id = rec.id_product
                  AND pl.is_active = TRUE;
                SELECT pl.id_price_list
                INTO selected_price_list
                FROM price_list pl
                WHERE pl.final_price = min_price
                  AND pl.product_id = rec.id_product
                  AND pl.is_active = TRUE
                LIMIT 1;
                UPDATE prices
                SET id_price_list = selected_price_list, main_price = min_price
                WHERE id_product = rec.id_product;
            END IF;
        END IF;

        PERFORM product_expired(rec.id_product, p_date, expired);
        IF expired THEN
            SELECT MIN(pl.final_price)
            INTO min_price
            FROM price_list pl
            WHERE pl.category_id = rec.category_id
              AND pl.product_id = rec.id_product
              AND pl.is_active = TRUE
              AND pl.is_warehouse_price = TRUE;
            UPDATE prices
            SET id_price_list = selected_price_list, main_price = min_price
            WHERE id_product = rec.id_product;
        END IF;
    END LOOP;
END;
$$;
