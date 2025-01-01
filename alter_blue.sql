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






ALTER TABLE Worktime_catalogue
ADD CONSTRAINT WORKTIME_HOURS_CHECK CHECK (hours_count BETWEEN 8 and 448);

ALTER TABLE Worktime_catalogue
ADD CONSTRAINT WORKTIME_SHIFT_CHECK CHECK (shift_count BETWEEN 0 AND 56);





ALTER TABLE Contact_catalogue
ADD CONSTRAINT CONTACT_SURNAME_CHECK CHECK (surname ~ '^[A-ZА-ЯЁ][a-zа-яё]+(-[A-ZА-ЯЁ][a-zа-яё]+)*$');

ALTER TABLE Contact_catalogue
ADD CONSTRAINT CONTACT_NAME_CHECK CHECK (name ~ '^[A-ZА-ЯЁ][a-zа-яё]+(-[A-ZА-ЯЁ][a-zа-яё]+)*$');

ALTER TABLE Contact_catalogue
ADD CONSTRAINT CONTACT_PATRONYMIC_CHECK CHECK (patronymic ~ '^[A-ZА-ЯЁ][a-zа-яё]+(-[A-ZА-ЯЁ][a-zа-яё]+)*$');

ALTER TABLE Contact_catalogue
ADD CONSTRAINT CONTACT_POST_CHECK CHECK (post ~ '^[A-ZА-ЯЁ][a-zа-яё]+(-[A-ZА-ЯЁ][a-zа-яё]+)*$');

ALTER TABLE Contact_catalogue
ADD CONSTRAINT CONTACT_PHONE_CHECK CHECK (phone ~ '^8-\d{3}-\d{3}-\d{2}-\d{2}$');

ALTER TABLE Contact_catalogue
ADD CONSTRAINT CONTACT_EMAIL_CHECK CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}$');






ALTER TABLE Contractor_catalogue
ADD CONSTRAINT CONTRACTOR_NAME_CHECK CHECK (company_name ~ '^[A-ZА-ЯЁ][a-zа-яё]+(-[A-ZА-ЯЁ][a-zа-яё]+)*$');

ALTER TABLE Contractor_catalogue
ADD CONSTRAINT CONTRACTOR_LEGAL_ADDR_CHECK CHECK (legal_address ~ '^[a-zA-Zа-яА-Я0-9,.\(\)/ -]*$');

ALTER TABLE Contractor_catalogue
ADD CONSTRAINT CONTRACTOR_ACTUAL_ADDR_CHECK CHECK (actual_address ~ '^[a-zA-Zа-яА-Я0-9,.\(\)/ -]*$');

ALTER TABLE Contractor_catalogue
ADD CONSTRAINT CONTRACTOR_INN_CHECK CHECK (INN ~ '^\d{10}$');

ALTER TABLE Contractor_catalogue
ADD CONSTRAINT CONTRACTOR_OGRN_CHECK CHECK (OGRN ~ '^\d{13}$');

ALTER TABLE Contractor_catalogue
ADD CONSTRAINT CONTRACTOR_FORM_CHECK CHECK (ownership_form ~ '^[A-ZА-ЯЁ][a-zа-яё]+(-[A-ZА-ЯЁ][a-zа-яё]+)*$');

ALTER TABLE Contractor_catalogue
ADD CONSTRAINT CONTRACTOR_SITE_CHECK CHECK (site ~* '^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}(/[\w&%+/$=]*)?$');

ALTER TABLE Contractor_catalogue
ADD CONSTRAINT CONTRACTOR_EMAIL_CHECK CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}$');






ALTER TABLE Worklog
ADD CONSTRAINT WORKLOG_DATE_START_CHECK CHECK (date_start <= date_end AND EXTRACT(YEAR FROM date_start) = EXTRACT(YEAR FROM CURRENT_DATE));

ALTER TABLE Worklog
ADD CONSTRAINT WORKLOG_DATE_END_CHECK CHECK (date_start <= date_end AND EXTRACT(YEAR FROM date_end) = EXTRACT(YEAR FROM CURRENT_DATE));

ALTER TABLE Worklog
ADD CONSTRAINT WORKLOG_TIME_START_CHECK CHECK (time_start <= time_end);

ALTER TABLE Worklog
ADD CONSTRAINT WORKLOG_TIME_END_CHECK CHECK (time_start <= time_end);

ALTER TABLE Worklog
ADD CONSTRAINT WORKLOG_TOTAL_TIME_CHECK CHECK (total_time >= 0 AND total_time <= 24);

ALTER TABLE Worklog
ADD CONSTRAINT WORKLOG_OVERTIME_CHECK CHECK (overtime >= 0 AND overtime <= 24);

ALTER TABLE Worklog
ADD CONSTRAINT WORKLOG_UNDERTIME_CHECK CHECK (undertime >= 0 AND undertime <= 24);






