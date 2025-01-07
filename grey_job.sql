CREATE EXTENSION pg_cron;

SELECT cron.schedule('0 8 * * *', $$CALL price_formation();$$);
