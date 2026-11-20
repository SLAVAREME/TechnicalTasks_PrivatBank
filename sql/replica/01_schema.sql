CREATE TABLE operations (
    id bigint NOT NULL,
    operation_guid uuid NOT NULL,
    amount numeric(10, 2) NOT NULL,
    state smallint NOT NULL,
    message jsonb NOT NULL,
    created_at timestamptz NOT NULL,
    PRIMARY KEY (id, created_at)
);  