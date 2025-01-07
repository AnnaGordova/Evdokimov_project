CREATE ROLE seller WITH LOGIN PASSWORD 'iamseller';
GRANT SELECT ON TABLE Prices TO seller;

CREATE ROLE store_manager WITH LOGIN PASSWORD 'iamstoremanager';
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO store_manager;

--GRANT EXECUTE ON PROCEDURE price_formation TO store_manager;
GRANT EXECUTE ON PROCEDURE get_price_lists_for_product TO store_manager;
GRANT EXECUTE ON PROCEDURE bind_price_list_to_product TO store_manager;
GRANT EXECUTE ON PROCEDURE change_price_list TO store_manager;
--GRANT EXECUTE ON FUNCTION get_new_prices TO store_manager;
