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

BEGIN
--     create_procedure('DEV', 'PROD', 'TESTPROCEDURE1');
--     create_function('DEV', 'PROD', 'TESTFUNCTION1');
--     create_index('DEV', 'PROD', 'TESTINDEX1');
END;