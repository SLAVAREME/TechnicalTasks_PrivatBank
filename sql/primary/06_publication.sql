CREATE PUBLICATION pub_operations
    FOR TABLE operations
    WITH (publish_via_partition_root = true);