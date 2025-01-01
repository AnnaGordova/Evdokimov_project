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

