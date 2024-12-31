CREATE TYPE enum_skill_level_Post_catalogue AS ENUM ('низкий', 'средний', 'высокий');
CREATE TYPE enum_gender_Employee_catalogue AS ENUM('м', 'ж');
CREATE TYPE enum_citizenship_Employee_catalogue AS ENUM('РФ', 'Иностранное');
CREATE TYPE enum_is_confirmed_Weekly_report AS ENUM('подтвержден', 'не подтвержден');
CREATE TYPE enum_is_confirmed_Absence AS ENUM('подтвержден', 'не подтвержден');
CREATE TYPE enum_currency_Rate_catalogue AS ENUM('USD', 'EUR', 'RUB', 'GBP', 'JPY');
CREATE TYPE enum_day_week_Schedule_template AS ENUM('ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС');

CREATE TABLE Passport_catalogue 
(
	id_passport SERIAL PRIMARY KEY,
	serias CHAR(4),
	number CHAR(6),
	registration_address VARCHAR(255),
	country CHAR(2)
);

CREATE TABLE Post_catalogue
(
	id_post SERIAL PRIMARY KEY,
	name VARCHAR(255),
	description TEXT,
	skill_level enum_skill_level_Post_catalogue,
	OKZ_code CHAR(7),
	responsibilities TEXT,
);

CREATE TABLE Employee_catalogue
(
	id_employee SERIAL PRIMARY KEY,
	surname VARCHAR(255),
	name VARCHAR(255),
	patronomyc VARCHAR(255),
	birth DATE,
	subdivision VARCHAR(255),
	login VARCHAR(255),
	password VARCHAR(255),
	role VARCHAR(50),
	work_number CHAR(9),
	personal_number CHAR (15),
	email VARCHAR(255),
	gender enum_gender_Employee_catalogue,
	INN CHAR (12),
	SNILS CHAR(11),
	date_employment DATE,
	citizenship enum_citizenship_Employee_catalogue,
	id_passport INTEGER REFERENCES Passport_catalogue (id_passport) ON DELETE CASCADE ON UPDATE CASCADE,
	id_post INTEGER REFERENCES Post_catalogue (id_post) ON DELETE CASCADE ON UPDATE CASCADE
);



CREATE TABLE Worklog 
(
	id_worklog SERIAL PRIMARY KEY,
	date_start DATE,
	date_end DATE,
	time_start TIME,
	time_end TIME,
	total_time NUMERIC(5, 2),
	overtime NUMERIC(5, 2),
	undertime NUMERIC(5, 2),
	id_employee INTEGER REFERENCES Employee_catalogue (id_employee) ON DELETE CASCADE ON UPDATE CASCADE
 
);

CREATE TABLE Weekly_report
(
	id_weekly_report SERIAL PRIMARY KEY,
	date_create TIMESTAMP,
	is_confirmed enum_is_confirmed_Weekly_report,
	note TEXT,
	id_employee INTEGER REFERENCES Employee_catalogue (id_employee) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Absence
(
	id_absence SERIAL PRIMARY KEY,
	date_start DATE,
	date_end DATE,
	type VARCHAR(255),
	supporting_document VARCHAR(255),
	is_confirmed enum_is_confirmed_Absence,
	id_employee INTEGER REFERENCES Employee_catalogue (id_employee) ON DELETE CASCADE ON UPDATE CASCADE
);



CREATE TABLE Rate_catalogue
(
	id_rate SERIAL PRIMARY KEY,
	name VARCHAR(100),
	type VARCHAR(100),
	size NUMERIC(10, 2),
	currency enum_currency_Rate_catalogue,
	peridoicity VARCHAR(100),
	id_post INTEGER REFERENCES Post_catalogue (id_post) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Worktime_catalogue
(
	id_worktime SERIAL PRIMARY KEY,
	hours_count NUMERIC(5, 2),
	shift_count INTEGER,
	week_start_date DATE,
	week_end_date DATE,
	comments TEXT,
	id_post INTEGER REFERENCES Post_catalogue (id_post) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Schedule_template
(
	id_template SERIAL PRIMARY KEY,
	day_week enum_day_week_Schedule_template,
	time_start TIME,
	time_end TIME,
	id_post INTEGER REFERENCES Post_catalogue (id_post) ON DELETE CASCADE ON UPDATE CASCADE
);




CREATE TABLE Contractor_catalogue
(
	id_contractor SERIAL PRIMARY KEY,
	company_name VARCHAR(255),
	legal_address TEXT,
	actual_address TEXT,
	INN CHAR(10),
	OGRN CHAR(13),
	ownership_form VARCHAR(20),
	site VARCHAR(50),
	email VARCHAR(50)
);

CREATE TABLE Contact_catalogue
(
	id_contact SERIAL PRIMARY KEY,
	surname VARCHAR(255),
	name VARCHAR(255),
	patronomyc VARCHAR(255),
	post VARCHAR(100),
	phone CHAR(15),
	email VARCHAR(255),
	id_contractor INTEGER REFERENCES Contractor_catalogue (id_contractor) ON DELETE CASCADE ON UPDATE CASCADE
);
