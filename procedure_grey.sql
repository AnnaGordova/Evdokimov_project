CREATE OR REPLACE PROCEDURE update_price(
    p_price_list_id INT,
    p_new_price NUMERIC(10, 2),
    p_price_type SMALLINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_new_price <= 0 THEN
        RAISE EXCEPTION 'Price must be greater than zero';
    END IF;
    
    IF p_price_type NOT IN (0, 1, 2) THEN
        RAISE EXCEPTION 'Invalid price type';
    END IF;

    UPDATE price_list
    SET итоговая_цена = p_new_price
    WHERE код_прайс_листа = p_price_list_id;
    
END;
$$;

CREATE EXTENSION IF NOT EXISTS pg_cron;
SELECT cron.schedule('0 6 * * *', $$CALL update_price(p_price_list_id, p_new_price, p_price_type)$$);
