-- Товаровед — полный контроль над приёмкой и учётом товара

CREATE ROLE commodity WITH LOGIN PASSWORD 'iamcommodity';

-- Доступ на чтение/запись к таблицам
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE Acceptance TO commodity;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE Acceptance_of_goods TO commodity;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE Inventory TO commodity;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE Inventory_result TO commodity;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE Write_off TO commodity;
GRANT EXECUTE ON FUNCTION Register_inventory TO commodity;
GRANT EXECUTE ON FUNCTION Register_write_off TO commodity;


-- Кладовщик — работа с инвентаризацией и перемещением товара

CREATE ROLE storekeeper WITH LOGIN PASSWORD 'iamstorekeeper';

-- Доступ на чтение/запись к таблицам
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE Moving TO storekeeper;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE Inventory TO storekeeper;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE Inventory_result TO storekeeper;
GRANT EXECUTE ON FUNCTION Register_inventory TO storekeeper;


-- Продавец — управление перемещением товара

CREATE ROLE seller WITH LOGIN PASSWORD 'iamseller';

-- Доступ на чтение/запись к таблице
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE Moving TO seller;
