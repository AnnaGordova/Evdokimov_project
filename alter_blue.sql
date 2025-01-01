ALTER TABLE Employee_catalogue
ADD CONSTRAINT EMP_SURNAME_CHECK CHECK (surname ~ '^[A-ZА-ЯЁ][a-zа-яё]+(-[A-ZА-ЯЁ][a-zа-яё]+)*$');

ALTER TABLE Employee_catalogue
ADD CONSTRAINT EMP_NAME_CHECK CHECK (name ~ '^[A-ZА-ЯЁ][a-zа-яё]+(-[A-ZА-ЯЁ][a-zа-яё]+)*$');

ALTER TABLE Employee_catalogue
ADD CONSTRAINT EMP_PATRONYMIC_CHECK CHECK (patronymic ~ '^[A-ZА-ЯЁ][a-zа-яё]+(-[A-ZА-ЯЁ][a-zа-яё]+)*$');

ALTER TABLE Employee_catalogue
ADD CONSTRAINT EMP_BIRTH_CHECK CHECK (birth <= CURRENT_DATE - INTERVAL '18 years' AND birth >= CURRENT_DATE - INTERVAL '100 years');

ALTER TABLE Employee_catalogue
ADD CONSTRAINT EMP_SUBDIVISION_CHECK CHECK (subdivision ~ '^[A-Za-zА-Яа-яЁё]+$');

ALTER TABLE Employee_catalogue
ADD CONSTRAINT EMP_LOGIN_CHECK CHECK (login ~ '^[A-Za-z0-9!@#$%^&*()_+=-]+$');

ALTER TABLE Employee_catalogue
ADD CONSTRAINT EMP_PASSWORD_CHECK CHECK (LENGTH(password) > 8 AND password ~ '^[A-Za-z0-9!@#$%^&*()_+=-]+$' AND password ~ '[!@#$%^&*()_+=-]');

ALTER TABLE Employee_catalogue
ADD CONSTRAINT EMP_ROLE_CHECK CHECK (role ~ '^[A-Za-zА-Яа-яЁё]+$');

ALTER TABLE Employee_catalogue
ADD CONSTRAINT EMP_WORK_NUMBER_CHECK CHECK (work_number ~ '^8-\d{3}-\d{3}$');

ALTER TABLE Employee_catalogue
ADD CONSTRAINT EMP_PERS_NUMBER_CHECK CHECK (personal_number ~ '^8-\d{3}-\d{3}-\d{2}-\d{2}$');

ALTER TABLE Employee_catalogue
ADD CONSTRAINT EMP_EMAIL_CHECK CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}$');

ALTER TABLE Employee_catalogue
ADD CONSTRAINT EMP_INN_CHECK CHECK (INN ~ '^\d{12}$');

ALTER TABLE Employee_catalogue
ADD CONSTRAINT EMP_SNILS_CHECK CHECK (SNILS ~ '^\d{11}$');

ALTER TABLE Employee_catalogue
ADD CONSTRAINT EMP_DATE_EMPLOYMENT_CHECK CHECK (date_employment >= '2010-01-01' AND date_employment <= CURRENT_DATE);


  


ALTER TABLE Passport_catalogue
ADD CONSTRAINT PASSPORT_SERIES_CHECK CHECK (series ~ '^\d{4}$');

ALTER TABLE Passport_catalogue
ADD CONSTRAINT PASSPORT_NUMBER_CHECK CHECK (number ~ '^\d{6}$');

ALTER TABLE Passport_catalogue
ADD CONSTRAINT PASSPORT_REGISTRATION_CHECK CHECK (registration_address ~ '^[a-zA-Zа-яА-Я0-9,.\(\)/ -]*$');

ALTER TABLE Passport_catalogue
ADD CONSTRAINT PASSPORT_COUNTRY_CHECK CHECK (country ~ '^[A-Za-z]{2}$');





ALTER TABLE Post_catalogue
ADD CONSTRAINT POST_NAME_CHECK CHECK (name ~ '^[а-яА-ЯёЁ\s-]+$');

ALTER TABLE Post_catalogue
ADD CONSTRAINT POST_OKZ_CHECK CHECK (OKZ_code ~ '^\d{3}\.\d{3}$');





ALTER TABLE Rate_catalogue
ADD CONSTRAINT RATE_NAME_CHECK CHECK (name ~ '^[а-яА-ЯёЁ\s-]+$');

ALTER TABLE Rate_catalogue
ADD CONSTRAINT RATE_TYPE_CHECK CHECK (type ~ '^[а-яА-ЯёЁ\s-]+$');

ALTER TABLE Rate_catalogue
ADD CONSTRAINT RATE_SIZE_CHECK CHECK (size BETWEEN 10000 AND 1000000);

ALTER TABLE Rate_catalogue
ADD CONSTRAINT RATE_PERIODICITY_CHECK CHECK (periodicity ~ '^[а-яА-ЯёЁ\s-]+$');