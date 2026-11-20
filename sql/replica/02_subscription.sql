CREATE SUBSCRIPTION sub_operations
    CONNECTION 'host=pg_primary port=5432 dbname=operations_db user=postgres password=postgres'
    PUBLICATION pub_operations;