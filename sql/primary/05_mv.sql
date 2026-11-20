CREATE MATERIALIZED VIEW mv_client_operation_totals AS
SELECT 
    (message->>'client_id')::int AS client_id,
    message->>'operation_type' AS operation_type,
    sum(amount) AS total_amount
FROM operations
WHERE state = 1
GROUP BY 1, 2;

CREATE UNIQUE INDEX ON mv_client_operation_totals (client_id, operation_type);

CREATE OR REPLACE FUNCTION refresh_client_operation_totals()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    IF pg_try_advisory_xact_lock(hashtext('refresh_mv_client_totals'))
       AND EXISTS (SELECT 1 FROM old_rows o
                   JOIN new_rows n USING (id, created_at)
                   WHERE o.state = 0 AND n.state = 1)
    THEN
        REFRESH MATERIALIZED VIEW CONCURRENTLY mv_client_operation_totals;
    END IF;
    RETURN NULL;
END $$;

CREATE TRIGGER trg_refresh_client_operation_totals
AFTER UPDATE ON operations
REFERENCING OLD TABLE AS old_rows NEW TABLE AS new_rows
FOR EACH STATEMENT EXECUTE FUNCTION refresh_client_operation_totals();