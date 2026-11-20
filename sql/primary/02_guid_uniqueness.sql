CREATE TABLE operations_guid_registry (
    operation_guid uuid PRIMARY KEY
);

CREATE OR REPLACE FUNCTION sync_operation_guid()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO operations_guid_registry VALUES (NEW.operation_guid);
    ELSIF TG_OP = 'DELETE' THEN
        DELETE FROM operations_guid_registry WHERE operation_guid = OLD.operation_guid;
    END IF;
    RETURN NULL;
END $$;

CREATE TRIGGER trg_sync_operation_guid
AFTER INSERT OR DELETE ON operations
FOR EACH ROW EXECUTE FUNCTION sync_operation_guid();

CREATE OR REPLACE FUNCTION forbid_guid_change()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'operation_guid is immutable';
END $$;

CREATE TRIGGER trg_forbid_guid_change
BEFORE UPDATE OF operation_guid ON operations
FOR EACH ROW WHEN (OLD.operation_guid IS DISTINCT FROM NEW.operation_guid)
EXECUTE FUNCTION forbid_guid_change();