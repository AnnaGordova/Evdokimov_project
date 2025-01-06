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
	
	IF p_total_time < p_norm_total_time THEN
		p_undertime := p_norm_total_time - p_total_time;
		p_overtime := '00:00:00';
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
BEGIN 
	INSERT INTO Absence (date_start, date_end, type, supporting_document, is_confirmed, id_employee) 
	VALUES (p_date_start, p_date_end, p_type, p_supporting_document, 'не подтвержден'); 
END; 
$$;

--CALL add_absence ('01.01.2025', '02.01.2025', 'Пьянка', 'Выписка из ывтрезвителя', 12)