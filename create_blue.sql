CREATE TYPE enum_status_Post_catalogue AS ENUM ('м', 'ж', 'pending');
CREATE TYPE enum_gender_Employee_catalogue AS ENUM('м', 'ж');
CREATE TYPE enum_citizenship_Employee_catalogue AS ENUM('РФ', 'Иностранное');
CREATE TYPE enum_is_confirmed_Weekly_report AS ENUM('подтвержден', 'не подтвержден');

CREATE TABLE Passport_catalogue 
(
	id_passport SERIAL PRIMARY KEY,
	serias VARCHAR(4),
	number VARCHAR(6),
	registration_address VARCHAR(255),
	country VARCHAR(255),
	valid_until DATE 
);

CREATE TABLE Post_catalogue
(
	id_post SERIAL PRIMARY KEY,
	name VARCHAR(255),
	description TEXT,
	skill_level VARCHAR(50),
	OKZ_code VARCHAR(20),
	responsibilities TEXT,
	status enum_status_Post_catalogue
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
	work_number VARCHAR(20),
	personal_number VARCHAR (20),
	email VARCHAR(255),
	gender enum_gender_Employee_catalogue,
	INN VARCHAR (12),
	SNILS VARCHAR(11),
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
	overtime NUMERIC(5, 2),
	undertime NUMERIC(5, 2),
	id_employee INTEGER REFERENCES Employee_catalogue (id_employee) ON DELETE CASCADE ON UPDATE CASCADE
 
);

CREATE TABLE Weekly_report
(
	id_weekly_report SERIAL PRIMARY KEY,
	date_create TIMESTAMP,
	is_confirmed enum_is_confirmed_Weekly_report,
	note VARCHAR(255),
	id_employee INTEGER REFERENCES Employee_catalogue (id_employee) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Absence
(
	id_absence SERIAL PRIMARY KEY,
	date_start DATE,
	date_end DATE,
	type VARCHAR(255),
	supporting_document VARCHAR(255),
	is_confirmed BOOLEAN,
	id_employee INTEGER REFERENCES Employee_catalogue (id_employee) ON DELETE CASCADE ON UPDATE CASCADE
);



CREATE TABLE Rate_catalogue
(
	id_rate SERIAL PRIMARY KEY,
	name VARCHAR(255),
	type VARCHAR(255),
	size NUMERIC(10, 2),
	currency VARCHAR(3),
	peridoicity VARCHAR(255),
	id_post INTEGER REFERENCES Post_catalogue (id_post) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Worktime_catalogue
(
	id_worktime SERIAL PRIMARY KEY,
	hours_count NUMERIC(5, 2),
	type_employment VARCHAR(255),
	id_post INTEGER REFERENCES Post_catalogue (id_post) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Schedule_template
(
	id_template SERIAL PRIMARY KEY,
	day_week INTEGER,
	time_start TIME,
	time_end TIME,
	id_post INTEGER REFERENCES Post_catalogue (id_post) ON DELETE CASCADE ON UPDATE CASCADE
);

