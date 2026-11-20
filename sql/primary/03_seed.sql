CREATE OR REPLACE PROCEDURE seed_operations(p_rows int DEFAULT 120000, p_days_back int DEFAULT 90)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO operations (operation_guid, amount, state, message, created_at)
    SELECT
        gen_random_uuid(),
        round((10 + random() * 49990)::numeric, 2),
        floor(random() * 2)::smallint,
        jsonb_build_object(
            'account_number', 'UA' || lpad((random() * 999999999)::int::text, 12, '0'),
            'client_id',      (1 + random() * 999)::int,
            'operation_type', CASE WHEN random() < 0.7 THEN 'online' ELSE 'offline' END
        ),
        now() - random() * make_interval(days => p_days_back)
    FROM generate_series(1, p_rows);
END $$;

CALL seed_operations();