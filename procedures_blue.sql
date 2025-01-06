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
	WHERE (id_employee = p_id_employee AND session_event = 'login')
	INTO p_time_start;
	
	SELECT event_time FROM Employee_session
	WHERE (id_employee = p_id_employee AND session_event = 'logout')
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