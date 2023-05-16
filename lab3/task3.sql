CREATE OR REPLACE PROCEDURE create_procedure(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2, procedure_name VARCHAR2) AS
    arguments CLOB;
    code CLOB;
BEGIN
    arguments := GET_ARGUMENTS(dev_schema_name, procedure_name);

    code := 'CREATE OR REPLACE PROCEDURE ' || prod_schema_name || '.' || procedure_name;
    IF arguments IS NOT NULL THEN
        code := code || '(' || arguments || ')';
    END IF;
    code := code || ' AS' || CHR(10) || GET_CODE(dev_schema_name, procedure_name, 'PROCEDURE');

    DBMS_OUTPUT.PUT_LINE(code);
--     EXECUTE IMMEDIATE code;
END create_procedure;

CREATE OR REPLACE PROCEDURE create_function(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2, function_name VARCHAR2) AS
    arguments CLOB;
    comma_index NUMBER;
    return_statement CLOB;
    code CLOB;
BEGIN
    arguments := GET_ARGUMENTS(dev_schema_name, function_name);
    comma_index := INSTR(arguments, ',');

    IF comma_index <> 0 THEN
        return_statement := TRIM(SUBSTR(arguments, 1, comma_index - 1));
        return_statement := REPLACE(return_statement, 'PL/SQL', '');
        arguments := TRIM(SUBSTR(arguments, comma_index + 1));
    ELSE
        return_statement := arguments;
        arguments := '';
    END IF;

    code := 'CREATE OR REPLACE FUNCTION ' || prod_schema_name || '.' || function_name;
    IF arguments IS NOT NULL THEN
        code := code || '(' || arguments || ')';
    END IF;
--     code := code || CHR(10) || 'RETURN ' || return_statement || CHR(10) || 'IS' || CHR(10);
    code := code || chr(10) || GET_CODE(dev_schema_name, function_name, 'FUNCTION');

    DBMS_OUTPUT.PUT_LINE(code);
--     EXECUTE IMMEDIATE code;
END create_function;

CREATE OR REPLACE PROCEDURE create_index(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2, index_name VARCHAR2) AS
    code CLOB;
BEGIN
    code := 'CREATE INDEX ' || prod_schema_name || '.' || index_name ||
            ' ON ' || prod_schema_name || '.' || GET_TABLE(dev_schema_name, index_name) ||
            '(' || GET_INDEX_COLUMNS(dev_schema_name, index_name) || ')';
    DBMS_OUTPUT.PUT_LINE(code);
--     EXECUTE IMMEDIATE code;
END create_index;

CREATE OR REPLACE PROCEDURE create_package(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2, package_name VARCHAR2) AS
    code CLOB;
BEGIN
    code := 'CREATE OR REPLACE PACKAGE ' || prod_schema_name || '.' || package_name || ' AS ' || CHR(10) ||
            GET_CODE(dev_schema_name, package_name, 'PACKAGE');
    DBMS_OUTPUT.PUT_LINE(code);
--     EXECUTE IMMEDIATE code;
END create_package;

CREATE OR REPLACE PROCEDURE create_table(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2, table_name VARCHAR2) AS
    code CLOB;
    CURSOR table_columns IS
        SELECT COLUMN_NAME, DATA_TYPE, DATA_LENGTH, NULLABLE
        FROM ALL_TAB_COLUMNS
        WHERE OWNER = dev_schema_name AND ALL_TAB_COLUMNS.TABLE_NAME = create_table.table_name;
    CURSOR table_constraints IS
        SELECT ALL_CONSTRAINTS.CONSTRAINT_TYPE, ALL_CONS_COLUMNS.COLUMN_NAME as col1, ALL_CONS_COLUMNS.CONSTRAINT_NAME,
               ALL_IND_COLUMNS.TABLE_NAME, ALL_IND_COLUMNS.COLUMN_NAME as col2
        FROM ALL_CONS_COLUMNS
        JOIN ALL_CONSTRAINTS
        ON ALL_CONSTRAINTS.TABLE_NAME = ALL_CONS_COLUMNS.TABLE_NAME
        LEFT JOIN ALL_IND_COLUMNS
        ON ALL_CONSTRAINTS.R_CONSTRAINT_NAME = ALL_IND_COLUMNS.INDEX_NAME
        WHERE ALL_CONSTRAINTS.OWNER = dev_schema_name
            AND ALL_CONS_COLUMNS.TABLE_NAME = create_table.table_name
            AND ALL_CONSTRAINTS.CONSTRAINT_TYPE <> 'C';
BEGIN
    code := 'CREATE TABLE ' || prod_schema_name || '.' || table_name || '(' || CHR(10);
    FOR table_column IN table_columns LOOP
        code := code || table_column.COLUMN_NAME || ' ' || table_column.DATA_TYPE ||
                '(' || table_column.DATA_LENGTH || ')';

        IF table_column.NULLABLE = 'N' THEN
            code := code || ' NOT NULL';
        END IF;

        code := code || ', '|| CHR(10);
    END LOOP;
    FOR table_constraint IN table_constraints LOOP
        IF table_constraint.CONSTRAINT_TYPE = 'U' THEN
            code := code || 'CONSTRAINT ' || table_constraint.CONSTRAINT_NAME || ' UNIQUE (' ||
                    table_constraint.col1 || ')';
        ELSIF table_constraint.CONSTRAINT_TYPE = 'P' THEN
            code := code || 'CONSTRAINT ' || table_constraint.CONSTRAINT_NAME || ' PRIMARY KEY (' ||
                    table_constraint.col1 || ')';
        ELSIF table_constraint.CONSTRAINT_TYPE = 'R' THEN
            code := code || 'CONSTRAINT ' || table_constraint.CONSTRAINT_NAME || ' FOREIGN KEY (' ||
                    table_constraint.col1 || ') REFERENCES ' || prod_schema_name || '.' || table_constraint.TABLE_NAME ||
                    '(' || table_constraint.col2 || ')';
        END IF;

        code := code || ', '|| CHR(10);
    END LOOP;

    code := SUBSTR(code, 1, LENGTH(code)-2) || ')';
    code := REPLACE(code, ',)', ')');
    DBMS_OUTPUT.PUT_LINE(code);
--     EXECUTE IMMEDIATE code;
END create_table;

CREATE OR REPLACE PROCEDURE REMOVE_EXTRA_FROM_PROD(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2) AS
    CURSOR dev_schema_procedures IS
        SELECT DISTINCT NAME FROM ALL_SOURCE
            WHERE OWNER = prod_schema_name
                AND ALL_SOURCE.TYPE = 'PROCEDURE'
        MINUS
        SELECT DISTINCT NAME FROM ALL_SOURCE
            WHERE OWNER = dev_schema_name
                AND ALL_SOURCE.TYPE = 'PROCEDURE';

    CURSOR dev_schema_functions IS
        SELECT DISTINCT NAME FROM ALL_SOURCE
            WHERE OWNER = prod_schema_name
                AND ALL_SOURCE.TYPE = 'FUNCTION'
        MINUS
        SELECT DISTINCT NAME FROM ALL_SOURCE
            WHERE OWNER = dev_schema_name
                AND ALL_SOURCE.TYPE = 'FUNCTION';

    CURSOR dev_schema_indexes IS
        SELECT INDEX_NAME FROM ALL_INDEXES
            WHERE OWNER = prod_schema_name
        MINUS
        SELECT INDEX_NAME FROM ALL_INDEXES
            WHERE OWNER = dev_schema_name;

    CURSOR dev_schema_packages IS
        SELECT DISTINCT NAME FROM ALL_SOURCE
            WHERE OWNER = prod_schema_name
                AND ALL_SOURCE.TYPE = 'PACKAGE'
        MINUS
        SELECT DISTINCT NAME FROM ALL_SOURCE
            WHERE OWNER = dev_schema_name
                AND ALL_SOURCE.TYPE = 'PACKAGE';

    CURSOR dev_schema_tables IS
        SELECT TABLE_NAME FROM ALL_TABLES
            WHERE OWNER = prod_schema_name
        MINUS
        SELECT TABLE_NAME FROM ALL_TABLES
            WHERE OWNER = dev_schema_name;
BEGIN
    FOR dev_procedure in dev_schema_procedures LOOP
        DBMS_OUTPUT.PUT_LINE('REMOVING PROCEDURE ' || dev_procedure.NAME);
--         EXECUTE IMMEDIATE 'DROP PROCEDURE ' || prod_schema_name || '.' || dev_procedure.NAME;
    END LOOP;

    FOR dev_function in dev_schema_functions LOOP
        DBMS_OUTPUT.PUT_LINE('REMOVING FUNCTION ' || dev_function.NAME);
--         EXECUTE IMMEDIATE 'DROP FUNCTION ' || prod_schema_name || '.' || dev_function.NAME;
    END LOOP;

    FOR dev_index in dev_schema_indexes LOOP
        DBMS_OUTPUT.PUT_LINE('REMOVING INDEX ' || dev_index.INDEX_NAME);
--         EXECUTE IMMEDIATE 'DROP INDEX ' || prod_schema_name || '.' || dev_index.INDEX_NAME;
    END LOOP;

    FOR dev_package in dev_schema_packages LOOP
        DBMS_OUTPUT.PUT_LINE('REMOVING PACKAGE ' || dev_package.NAME);
--         EXECUTE IMMEDIATE 'DROP PACKAGE ' || prod_schema_name || '.' || dev_package.NAME;
    END LOOP;

    FOR dev_table in dev_schema_tables LOOP
        DBMS_OUTPUT.PUT_LINE('REMOVING TABLE ' || dev_table.TABLE_NAME);
--         EXECUTE IMMEDIATE 'DROP TABLE ' || prod_schema_name || '.' || dev_table.TABLE_NAME;
    END LOOP;
END REMOVE_EXTRA_FROM_PROD;

DROP TABLE CYCLE_CHECK;
CREATE TABLE cycle_check
(
    name VARCHAR2(40),
    num NUMBER
);

CREATE OR REPLACE PROCEDURE CHECK_CYCLE(
    schema IN VARCHAR2
)
IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM (
            WITH table_hierarchy AS
                (
                    SELECT child_owner, child_table, parent_owner, parent_table
                    FROM (
                            SELECT owner child_owner,
                                   table_name child_table,
                                   r_owner parent_owner,
                                   r_constraint_name constraint_name
                            FROM all_constraints
                            WHERE constraint_type = 'R' AND owner = schema
                    )
                    JOIN (
                            SELECT owner parent_owner,
                                   constraint_name, table_name parent_table
                            FROM all_constraints
                            WHERE constraint_type = 'P' AND owner = schema
                    )
                    USING (parent_owner, constraint_name)
                )
                SELECT DISTINCT child_owner, child_table
                FROM (
                        SELECT *
                        FROM table_hierarchy
                        WHERE (child_owner, child_table) IN (
                            SELECT parent_owner, parent_table
                            FROM table_hierarchy)
                        ) a
                        WHERE connect_by_iscycle = 1
                        CONNECT BY nocycle (
                            PRIOR child_owner,
                            PRIOR child_table
                        ) = (( parent_owner, parent_table ))
    );

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20343,'CYCLE IN TABLES');
    END IF;
END;

DECLARE
    dev_schema_name VARCHAR2(32767);
    prod_schema_name VARCHAR2(32767);
BEGIN
    dev_schema_name := 'DEV';
--     prod_schema_name := 'PROD';
--     REMOVE_EXTRA_FROM_PROD(dev_schema_name, prod_schema_name);

    GET_TABLE_DIFFERENCES(dev_schema_name, prod_schema_name);
    CHECK_CYCLE(dev_schema_name);

--     GET_PROCEDURE_DIFFERENCES(dev_schema_name, prod_schema_name);
--     GET_FUNCTION_DIFFERENCES(dev_schema_name, prod_schema_name);
--     GET_INDEX_DIFFERENCES(dev_schema_name, prod_schema_name);
--     GET_PACKAGE_DIFFERENCES(dev_schema_name, prod_schema_name);
END;

DECLARE
    COMMAND CLOB;
BEGIN
    FOR T IN (SELECT TABLE_NAME, OWNER FROM ALL_TABLES WHERE OWNER = 'DEV' OR OWNER = 'PROD') LOOP
        FOR C IN (SELECT CONSTRAINT_NAME FROM ALL_CONSTRAINTS WHERE TABLE_NAME = T.TABLE_NAME) LOOP
            COMMAND := 'ALTER TABLE ' || T.OWNER || '.' || T.TABLE_NAME || ' DROP CONSTRAINT ' || C.CONSTRAINT_NAME;
            EXECUTE IMMEDIATE COMMAND;
        END LOOP;
        COMMAND := 'DROP TABLE ' || T.OWNER || '.' || T.TABLE_NAME;
        EXECUTE IMMEDIATE COMMAND;
    END LOOP;
END;

SELECT * FROM ALL_TABLES WHERE OWNER = 'DEV';
SELECT * FROM ALL_CONSTRAINTS WHERE TABLE_NAME = 'TABLE1' AND OWNER = 'DEV';

ALTER TABLE DEV.table2 DROP CONSTRAINT SYS_C008335;
ALTER TABLE DEV.table1 DROP CONSTRAINT SYS_C008334;

SELECT * FROM DEV.TESTTABLE;
