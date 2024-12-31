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
	serias CHAR(4) NOT NULL UNIQUE,
	number CHAR(6) NOT NULL UNIQUE,
	registration_address VARCHAR(255) NOT NULL,
	country CHAR(2) NOT NULL
);

CREATE TABLE Post_catalogue
(
	id_post SERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	description TEXT NOT NULL,
	skill_level enum_skill_level_Post_catalogue NOT NULL,
	OKZ_code CHAR(7) NOT NULL UNIQUE,
	responsibilities TEXT NOT NULL,
);

CREATE TABLE Employee_catalogue
(
	id_employee SERIAL PRIMARY KEY,
	surname VARCHAR(255) NOT NULL,
	name VARCHAR(255) NOT NULL,
	patronomyc VARCHAR(255),
	birth DATE NOT NULL,
	subdivision VARCHAR(255) NOT NULL,
	login VARCHAR(255) NOT NULL UNIQUE,
	password VARCHAR(255) NOT NULL,
	role VARCHAR(50) NOT NULL,
	work_number CHAR(9) NOT NULL UNIQUE,
	personal_number CHAR (15) NOT NULL UNIQUE,
	email VARCHAR(255) NOT NULL UNIQUE,
	gender enum_gender_Employee_catalogue NOT NULL,
	INN CHAR (12) NOT NULL UNIQUE,
	SNILS CHAR(11) NOT NULL UNIQUE,
	date_employment DATE NOT NULL,
	citizenship enum_citizenship_Employee_catalogue NOT NULL,
	id_passport INTEGER NOT NULL REFERENCES Passport_catalogue (id_passport) ON DELETE CASCADE ON UPDATE CASCADE,
	id_post INTEGER NOT NULL REFERENCES Post_catalogue (id_post) ON DELETE CASCADE ON UPDATE CASCADE
);



CREATE TABLE Worklog 
(
	id_worklog SERIAL PRIMARY KEY,
	date_start DATE NOT NULL,
	date_end DATENOT NULL,
	time_start TIME NOT NULL,
	time_end TIME NOT NULL,
	total_time NUMERIC(5, 2),
	overtime NUMERIC(5, 2),
	undertime NUMERIC(5, 2),
	id_employee INTEGER NOT NULL REFERENCES Employee_catalogue (id_employee) ON DELETE CASCADE ON UPDATE CASCADE
 
);

CREATE TABLE Weekly_report
(
	id_weekly_report SERIAL PRIMARY KEY,
	date_create TIMESTAMP NOT NULL,
	is_confirmed enum_is_confirmed_Weekly_report NOT NULL,
	note TEXT,
	id_employee INTEGER NOT NULL REFERENCES Employee_catalogue (id_employee) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Absence
(
	id_absence SERIAL PRIMARY KEY,
	date_start DATE NOT NULL,
	date_end DATE NOT NULL,
	type VARCHAR(255) NOT NULL,
	supporting_document VARCHAR(255),
	is_confirmed enum_is_confirmed_Absence,
	id_employee INTEGER NOT NULL REFERENCES Employee_catalogue (id_employee) ON DELETE CASCADE ON UPDATE CASCADE
);



CREATE TABLE Rate_catalogue
(
	id_rate SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL UNIQUE,
	type VARCHAR(100) NOT NULL,
	size NUMERIC(10, 2) NOT NULL,
	currency enum_currency_Rate_catalogue NOT NULL,
	peridoicity VARCHAR(100) NOT NULL,
	id_post INTEGER NOT NULL REFERENCES Post_catalogue (id_post) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Worktime_catalogue
(
	id_worktime SERIAL PRIMARY KEY,
	hours_count NUMERIC(5, 2) NOT NULL,
	shift_count INTEGER NOT NULL,
	week_start_date DATE NOT NULL,
	week_end_date DATE NOT NULL,
	comments TEXT,
	id_post INTEGERNOT NULL REFERENCES Post_catalogue (id_post) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Schedule_template
(
	id_template SERIAL PRIMARY KEY,
	day_week enum_day_week_Schedule_template NOT NULL,
	time_start TIME NOT NULL,
	time_end TIMENOT NULL,
	id_post INTEGER NOT NULL REFERENCES Post_catalogue (id_post) ON DELETE CASCADE ON UPDATE CASCADE
);




CREATE TABLE Contractor_catalogue
(
	id_contractor SERIAL PRIMARY KEY,
	company_name VARCHAR(255) NOT NULL,
	legal_address TEXT NOT NULL,
	actual_address TEXT NOT NULL,
	INN CHAR(10) NOT NULL UNIQUE,
	OGRN CHAR(13) NOT NULL UNIQUE,
	ownership_form VARCHAR(20) NOT NULL,
	site VARCHAR(50) NOT NULL UNIQUE,
	email VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Contact_catalogue
(
	id_contact SERIAL PRIMARY KEY,
	surname VARCHAR(255) NOT NULL,
	name VARCHAR(255) NOT NULL,
	patronomyc VARCHAR(255),
	post VARCHAR(100) NOT NULL,
	phone CHAR(15) NOT NULL UNIQUE,
	email VARCHAR(255) NOT NULL UNIQUE,
	id_contractor INTEGER NOT NULL REFERENCES Contractor_catalogue (id_contractor) ON DELETE CASCADE ON UPDATE CASCADE
);
