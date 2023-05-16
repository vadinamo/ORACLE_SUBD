CREATE OR REPLACE PROCEDURE get_table_differences(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2) AS
    columns_count NUMBER;
    constraints_count NUMBER;
    CURSOR dev_schema_tables is
        SELECT * FROM ALL_TABLES
        WHERE OWNER = dev_schema_name;
BEGIN
    DBMS_OUTPUT.PUT_LINE(DASHES('TABLES FROM ' || dev_schema_name || ' THAT ARE NOT IN ' || prod_schema_name || ':'));

    FOR dev_table in dev_schema_tables LOOP
        SELECT COUNT(*) INTO columns_count FROM
        (
            (
                SELECT COLUMN_NAME, DATA_TYPE, DATA_LENGTH, NULLABLE --count of rows from dev that are not in prod
                FROM ALL_TAB_COLUMNS
                WHERE OWNER = dev_schema_name
                AND TABLE_NAME = dev_table.TABLE_NAME
                MINUS
                SELECT COLUMN_NAME, DATA_TYPE, DATA_LENGTH, NULLABLE
                FROM ALL_TAB_COLUMNS
                WHERE OWNER = prod_schema_name
                AND TABLE_NAME = dev_table.TABLE_NAME
            )
            UNION
            (
                SELECT COLUMN_NAME, DATA_TYPE, DATA_LENGTH, NULLABLE --count of rows from prod that are not in dev
                FROM ALL_TAB_COLUMNS
                WHERE OWNER = prod_schema_name
                AND TABLE_NAME = dev_table.TABLE_NAME
                MINUS
                SELECT COLUMN_NAME, DATA_TYPE, DATA_LENGTH, NULLABLE
                FROM ALL_TAB_COLUMNS
                WHERE OWNER = dev_schema_name
                AND TABLE_NAME = dev_table.TABLE_NAME
            )
        );

        SELECT COUNT(*) INTO constraints_count FROM (
            (
                SELECT ALL_CONSTRAINTS.CONSTRAINT_TYPE, ALL_CONS_COLUMNS.COLUMN_NAME, ALL_CONS_COLUMNS.CONSTRAINT_NAME --count of constraints from dev that are not in prod
                FROM ALL_CONS_COLUMNS JOIN ALL_CONSTRAINTS
                ON ALL_CONSTRAINTS.TABLE_NAME = ALL_CONS_COLUMNS.TABLE_NAME
                WHERE ALL_CONSTRAINTS.OWNER = dev_schema_name AND ALL_CONS_COLUMNS.TABLE_NAME = dev_table.TABLE_NAME
                MINUS
                SELECT ALL_CONSTRAINTS.CONSTRAINT_TYPE, ALL_CONS_COLUMNS.COLUMN_NAME, ALL_CONS_COLUMNS.CONSTRAINT_NAME
                FROM ALL_CONS_COLUMNS JOIN ALL_CONSTRAINTS
                ON ALL_CONSTRAINTS.TABLE_NAME = ALL_CONS_COLUMNS.TABLE_NAME
                WHERE ALL_CONSTRAINTS.OWNER = prod_schema_name AND ALL_CONS_COLUMNS.TABLE_NAME = dev_table.TABLE_NAME
            )
            UNION
            (
                SELECT ALL_CONSTRAINTS.CONSTRAINT_TYPE, ALL_CONS_COLUMNS.COLUMN_NAME, ALL_CONS_COLUMNS.CONSTRAINT_NAME --count of constraints from prod that are not in dev
                FROM ALL_CONS_COLUMNS JOIN ALL_CONSTRAINTS
                ON ALL_CONSTRAINTS.TABLE_NAME = ALL_CONS_COLUMNS.TABLE_NAME
                WHERE ALL_CONSTRAINTS.OWNER = prod_schema_name AND ALL_CONS_COLUMNS.TABLE_NAME = dev_table.TABLE_NAME
                MINUS
                SELECT ALL_CONSTRAINTS.CONSTRAINT_TYPE, ALL_CONS_COLUMNS.COLUMN_NAME, ALL_CONS_COLUMNS.CONSTRAINT_NAME
                FROM ALL_CONS_COLUMNS JOIN ALL_CONSTRAINTS
                ON ALL_CONSTRAINTS.TABLE_NAME = ALL_CONS_COLUMNS.TABLE_NAME
                WHERE ALL_CONSTRAINTS.OWNER = dev_schema_name AND ALL_CONS_COLUMNS.TABLE_NAME = dev_table.TABLE_NAME
            )
        );

        IF columns_count <> 0 OR constraints_count <> 0 THEN
            DBMS_OUTPUT.PUT_LINE(dev_table.TABLE_NAME);
            CREATE_TABLE(dev_schema_name, prod_schema_name, dev_table.TABLE_NAME);
            DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
--             IF columns_count <> 0 THEN
--                 DBMS_OUTPUT.PUT_LINE(CHR(9) || ' COLUMNS ');
--             END IF;
--             IF constraints_count <> 0 THEN
--                 DBMS_OUTPUT.PUT_LINE(CHR(9) || ' CONSTRAINTS ');
--             END IF;
        END IF;
    END LOOP;
end get_table_differences;

-- BEGIN
--     get_table_differences('DEV','PROD');
-- END;
