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
end create_procedure;

BEGIN
    create_procedure('DEV', 'PROD', 'TESTPROCEDURE1');
END;