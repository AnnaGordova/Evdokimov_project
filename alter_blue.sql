ALTER TABLE Employee_catalogue
ADD CONSTRAINT EMP_SURNAME_CHECK CHECK (surname ~ '^[A-ZА-ЯЁ][a-zа-яё]+(-[A-ZА-ЯЁ][a-zа-яё]+)*$');