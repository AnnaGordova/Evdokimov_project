CREATE OR REPLACE FUNCTION add_price_jr_function() 
RETURNS TRIGGER AS
$$
BEGIN
    IF NEW.final_price <> OLD.final_price THEN
        INSERT INTO prices_jr(id_price_list, old_price, new_price)
        VALUES (NEW.id_price_list, OLD.final_price, NEW.final_price);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER add_price_jr
AFTER UPDATE OF final_price
ON price_list
FOR EACH ROW
EXECUTE FUNCTION add_price_jr_function();
