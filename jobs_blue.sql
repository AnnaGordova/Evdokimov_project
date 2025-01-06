CREATE EXTENSION pg_cron;
SELECT cron.schedule('0 0 * * *', $$CALL add_worklog();$$);

--CALL add_worklog();

SELECT cron.schedule('0 18 * * 0', $$CALL generate_weekly_report();$$);

