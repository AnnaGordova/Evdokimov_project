CREATE OR REPLACE PROCEDURE add_worklog(
	p_id_employee worklog.id_employee%type,
	p_date_start employee_session.event_date%type
)
LANGUAGE plpgsql
AS $$
DECLARE
   	p_time_start TIME;
	p_time_end TIME;
	p_norm_time_start TIME;
	p_norm_time_end TIME;
	p_total_time TIME;
	p_norm_total_time TIME;
	p_overtime TIME;
	p_undertime TIME;
	
	
BEGIN
    SELECT event_time FROM Employee_session
	WHERE (id_employee = p_id_employee AND session_event = 'login' AND event_date = p_date_start)
	INTO p_time_start;
	
	SELECT event_time FROM Employee_session
	WHERE (id_employee = p_id_employee AND session_event = 'logout' AND event_date = p_date_start)
	INTO p_time_end;
	
	SELECT St.time_start FROM Schedule_template as St, Employee_catalogue as Ec, Post_catalogue as Pc
	WHERE (Ec.id_employee = p_id_employee AND Ec.id_post = Pc.id_post AND Pc.id_post = St.id_post)
	INTO p_norm_time_start;
	
	SELECT St.time_end FROM Schedule_template as St, Employee_catalogue as Ec, Post_catalogue as Pc
	WHERE (Ec.id_employee = p_id_employee AND Ec.id_post = Pc.id_post AND Pc.id_post = St.id_post)
	INTO p_norm_time_end;
	
	p_total_time := p_time_end - p_time_start - INTERVAL '00:30:00';
	p_norm_total_time := p_norm_time_end - p_norm_time_start - INTERVAL '00:30:00';
	
	
	
	IF p_total_time > p_norm_total_time THEN
		p_overtime := p_total_time - p_norm_total_time;
		p_undertime := '00:00:00';
	END IF;
	
	IF p_overtime < '00:30:00' THEN
		p_overtime = '00:00:00';
	END IF;
	
	IF p_total_time < p_norm_total_time THEN
		p_undertime := p_norm_total_time - p_total_time;
		p_overtime := '00:00:00';
	END IF;
	
	IF p_undertime < '00:30:00' THEN
		p_undertime = '00:00:00';
	END IF;
	
	IF p_total_time = p_norm_total_time THEN
		p_undertime := '00:00:00';
		p_overtime := '00:00:00';
	END IF;
	
	INSERT INTO Worklog (date_start, time_start, time_end, total_time, overtime, undertime, id_employee)
	VALUES (p_date_start, p_time_start, p_time_end, p_total_time, p_overtime, p_undertime, p_id_employee);
END;
$$;

--CALL add_worklog(14, '06-01-2025')






CREATE OR REPLACE PROCEDURE generate_weekly_report_one(
    p_id_employee worklog.id_employee%type,
	p_week_start_date DATE DEFAULT current_date,
    p_week_end_date DATE DEFAULT current_date
	
)

LANGUAGE plpgsql
AS $$
DECLARE 
	p_totaltime TIME;
	p_undertime TIME;
	p_overtime TIME;
	p_note TEXT;
BEGIN
    SELECT SUM(w.total_time) 
	FROM Worklog as w 
	WHERE ('06-01-2025' <= w.date_start AND w.date_start <= '12-01-2025' AND w.id_employee = p_id_employee)
	GROUP BY w.id_employee
	INTO p_totaltime;
	
	SELECT  
	SUM(w.undertime)
	FROM Worklog as w 
	WHERE ('06-01-2025' <= w.date_start AND w.date_start <= '12-01-2025' AND w.id_employee = p_id_employee)
	GROUP BY w.id_employee
	INTO p_undertime;
	
	SELECT SUM(w.overtime) 
	FROM Worklog as w 
	WHERE ('06-01-2025' <= w.date_start AND w.date_start <= '12-01-2025' AND w.id_employee = p_id_employee)
	GROUP BY w.id_employee
	INTO p_overtime;
	
	
	p_note := format('Всего отработано: %s, недоработки: %s, переработки: %s', p_totaltime, p_undertime, p_overtime);
	
	INSERT INTO Weekly_report (date_create, is_confirmed, note, id_employee)
	VALUES (current_date, 'не подтвержден', p_note, p_id_employee);
END;
$$;

--CALL generate_weekly_report_one(14, '06-01-2025', '12-01-2025');
--CALL generate_weekly_report_one(19, '06-01-2025', '12-01-2025');






CREATE OR REPLACE PROCEDURE generate_weekly_report(
	p_week_start_date DATE DEFAULT current_date,
    p_week_end_date DATE DEFAULT current_date
	
)

LANGUAGE plpgsql
AS $$
DECLARE 
	rec RECORD;
BEGIN
   FOR rec in SELECT DISTINCT id_employee FROM worklog LOOP
	  CALL generate_weekly_report_one(rec.id_employee, p_week_start_date, p_week_end_date);
   END LOOP;
END;
$$;


--CALL generate_weekly_report('06-01-2025', '12-01-2025');




CREATE OR REPLACE PROCEDURE edit_and_confirm_weekly_report(
    p_id_weekly_report weekly_report.id_weekly_report%type	
)

LANGUAGE plpgsql
AS $$
BEGIN
	UPDATE Weekly_report SET is_confirmed = 'подтвержден'
	WHERE id_weekly_report = p_id_weekly_report;

END;
$$;




CREATE OR REPLACE PROCEDURE edit_and_confirm_weekly_report(
    p_id_weekly_report weekly_report.id_weekly_report%type,
	p_note weekly_report.note%type	
)

LANGUAGE plpgsql
AS $$
BEGIN
	UPDATE Weekly_report SET is_confirmed = 'подтвержден'
	WHERE id_weekly_report = p_id_weekly_report;
	
	UPDATE Weekly_report SET note = p_note
	WHERE id_weekly_report = p_id_weekly_report;
END;
$$;

--CALL edit_and_confirm_weekly_report(2, 'уволить!');







CREATE OR REPLACE PROCEDURE add_absence(
	p_date_start absence.date_start%type,
	p_date_end absence.date_end%type,
	p_type absence.type%type,
  	p_supporting_document absence.supporting_document%type,
  	p_id_employee absence.id_employee%type
) 
LANGUAGE plpgsql 
AS $$
DECLARE 
	p_relax_days INTEGER;
BEGIN 
	
	SELECT SUM(date_end- date_start) FROM Absence 
	WHERE (id_employee = 19 AND is_confirmed = 'подтвержден' 
		AND type = 'отпуск' AND CURRENT_DATE - date_start > 2*365) 
	INTO p_relax_days;
	IF (p_date_end - p_date_start + p_relax_days < 84) THEN
		INSERT INTO Absence (date_start, date_end, type, supporting_document, is_confirmed, id_employee) 
		VALUES (p_date_start, p_date_end, p_type, p_supporting_document, 'не подтвержден', p_id_employee);
	END IF;
	
	IF(p_date_end - p_date_start + p_relax_days >= 84) THEN 
		RAISE EXCEPTION 'Условия предоставления отпуска не выполнены';
	END IF;
	
END; 
$$;

--CALL add_absence('03-06-2025', '10-06-2025', 'отпуск', 'заявление на отпуск',19);







CREATE OR REPLACE PROCEDURE confirm_absence(
	p_id_absence absence.id_absence%type
) 
LANGUAGE plpgsql 
AS $$

BEGIN 

	UPDATE Absence SET is_confirmed = 'подтвержден' 
	WHERE (id_absence = p_id_absence AND NOT(type = 'больничный' 
		   AND supporting_document IS NULL AND 
		   CURRENT_DATE > date_start + INTERVAL '7 days'));
END; 
$$;

--CALL confirm_absence(17);






CREATE OR REPLACE PROCEDURE add_supporting_document(
	p_id_absence absence.id_absence%type,
	p_supporting_document absence.supporting_document%type
) 
LANGUAGE plpgsql 
AS $$

BEGIN 

	UPDATE Absence SET supporting_document = p_supporting_document 
	WHERE (id_absence = p_id_absence);
END; 
$$;

--CALL add_supporting_document(13, 'заявление на отпуск');