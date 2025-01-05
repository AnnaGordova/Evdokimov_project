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