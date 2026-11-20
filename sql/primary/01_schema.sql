CREATE TABLE operations (
    id bigint GENERATED ALWAYS AS IDENTITY,
    operation_guid uuid NOT NULL,
    amount numeric(10, 2) NOT NULL,
    state smallint NOT NULL DEFAULT 0,
    message jsonb NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);

CREATE OR REPLACE FUNCTION create_month_partition(month date)
RETURNS void
LANGUAGE plpgsql AS $$
DECLARE
    date_from date := date_trunc('month', month)::date;
    date_to   date := (date_from + interval '1 month')::date;
BEGIN
    EXECUTE format(
        'CREATE TABLE IF NOT EXISTS %I PARTITION OF operations FOR VALUES FROM (%L) TO (%L)',
        'operations_' || to_char(date_from, 'YYYY_MM'), date_from, date_to);
END $$;

SELECT create_month_partition((CURRENT_DATE + make_interval(months => m))::date)
FROM generate_series(-3, 1) AS m;

CREATE INDEX idx_operations_state_id ON operations (state, id);

CREATE TABLE operations_default PARTITION OF operations DEFAULT;