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
END create_function;

CREATE OR REPLACE PROCEDURE create_index(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2, index_name VARCHAR2) AS
    code CLOB;
BEGIN
    code := 'CREATE INDEX ' || prod_schema_name || '.' || index_name ||
            ' ON ' || prod_schema_name || '.' || GET_TABLE(dev_schema_name, index_name) ||
            '(' || GET_INDEX_COLUMNS(dev_schema_name, index_name) || ')';
    DBMS_OUTPUT.PUT_LINE(code);
END create_index;

CREATE OR REPLACE PROCEDURE create_package(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2, package_name VARCHAR2) AS
    code CLOB;
BEGIN
    code := 'CREATE OR REPLACE PACKAGE ' || prod_schema_name || '.' || package_name || ' AS ' || CHR(10) ||
            GET_CODE(dev_schema_name, package_name, 'PACKAGE');
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

        code := code || CHR(10);
    END LOOP;
    FOR table_constraint IN table_constraints LOOP
        IF table_constraint.CONSTRAINT_TYPE = 'U' THEN
            code := code || 'CONSTRAINT ' || table_constraint.CONSTRAINT_NAME || ' UNIQUE (' ||
                    table_constraint.col1 || '),';
        ELSIF table_constraint.CONSTRAINT_TYPE = 'P' AND FIRST_SYMBOL(table_constraint.CONSTRAINT_NAME) = 'P' THEN
            code := code || 'CONSTRAINT ' || table_constraint.CONSTRAINT_NAME || ' PRIMARY KEY (' ||
                    table_constraint.col1 || '),';
        ELSIF table_constraint.CONSTRAINT_TYPE = 'R' AND FIRST_SYMBOL(table_constraint.CONSTRAINT_NAME) = 'F' THEN
            code := code || 'CONSTRAINT ' || table_constraint.CONSTRAINT_NAME || ' FOREIGN KEY (' ||
                    table_constraint.col1 || ') REFERENCES ' || prod_schema_name || '.' || table_constraint.TABLE_NAME ||
                    '(' || table_constraint.col2 || '),';
        END IF;

        code := code || CHR(10);
    END LOOP;

    code := code || ')';
    DBMS_OUTPUT.PUT_LINE(code);
END create_table;

BEGIN
--     create_procedure('DEV', 'PROD', 'TESTPROCEDURE1');
--     create_function('DEV', 'PROD', 'TESTFUNCTION1');
--     create_index('DEV', 'PROD', 'TESTINDEX1');
    CREATE_TABLE('DEV', 'PROD', 'TESTTABLE1');
END;
