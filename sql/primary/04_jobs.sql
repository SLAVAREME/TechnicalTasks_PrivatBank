CREATE EXTENSION IF NOT EXISTS pg_cron;

CREATE OR REPLACE PROCEDURE add_pending_operation()
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO operations (operation_guid, amount, state, message)
    VALUES (
        gen_random_uuid(),
        round((10 + random() * 49990)::numeric, 2),
        0,
        jsonb_build_object(
            'account_number', 'UA' || lpad((random() * 999999999)::int::text, 12, '0'),
            'client_id',      (1 + random() * 999)::int,
            'operation_type', CASE WHEN random() < 0.7 THEN 'online' ELSE 'offline' END
        )
    );
END $$;

CREATE OR REPLACE PROCEDURE process_pending_operations()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE operations
    SET state = 1
    WHERE state = 0
    AND id % 2 = floor(extract(second FROM clock_timestamp()))::int % 2;
END $$;

SELECT cron.schedule('add-pending-operation', '5 seconds', 'CALL add_pending_operation();');
SELECT cron.schedule('process-pending-operations', '3 seconds', 'CALL process_pending_operations();');