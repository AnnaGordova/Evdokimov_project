$$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION product_expired(
    p_id_product product_card.id_product%type,
    p_date DATE DEFAULT CURRENT_DATE
) 
RETURNS BOOLEAN AS
$$
DECLARE
    total_received NUMERIC; -- общее количество поступившего товара
    total_sold NUMERIC; -- общее количество проданного товара
    remaining_stock NUMERIC; -- остаток товара на складе
    expiration_threshold NUMERIC := 0.10; -- порог остатка (10%)
BEGIN
    SELECT COALESCE(SUM(ag.count), 0)
    INTO total_received
    FROM acceptance_of_goods ag
    WHERE ag.id_product = p_id_product
      AND ag.acceptance_date <= p_date;
    SELECT COALESCE(SUM(s.count), 0)
    INTO total_sold
    FROM sale s
    WHERE s.id_product = p_id_product
      AND s.sale_date <= p_date;
    remaining_stock := total_received - total_sold;
    IF remaining_stock < total_received * expiration_threshold THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;

