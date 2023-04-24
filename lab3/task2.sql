CREATE OR REPLACE PROCEDURE get_procedure_differences(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2) AS
    arguments_count NUMBER;
    dev_procedure_text CLOB;
    prod_procedure_text CLOB;
    CURSOR dev_schema_procedures is
            SELECT DISTINCT NAME FROM ALL_SOURCE
            WHERE TYPE = 'PROCEDURE' AND OWNER = dev_schema_name;
BEGIN
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('PROCEDURES FROM ' || dev_schema_name || ' THAT ARE NOT IN ' || prod_schema_name || ':');
    FOR dev_procedure in dev_schema_procedures LOOP
        SELECT COUNT(*) INTO arguments_count FROM
        (
            (
                SELECT DATA_TYPE, ARGUMENT_NAME
                FROM ALL_ARGUMENTS
                WHERE OWNER = dev_schema_name AND OBJECT_NAME = dev_procedure.NAME
                MINUS
                SELECT DATA_TYPE, ARGUMENT_NAME
                FROM ALL_ARGUMENTS
                WHERE OWNER = prod_schema_name AND OBJECT_NAME = dev_procedure.NAME
                )
            UNION
            (
                SELECT DATA_TYPE, ARGUMENT_NAME
                FROM ALL_ARGUMENTS
                WHERE OWNER = prod_schema_name AND OBJECT_NAME = dev_procedure.NAME
                MINUS
                SELECT DATA_TYPE, ARGUMENT_NAME
                FROM ALL_ARGUMENTS
                WHERE OWNER = dev_schema_name AND OBJECT_NAME = dev_procedure.NAME
            )
        );

        SELECT LISTAGG(TEXT, CHR(10)) INTO dev_procedure_text FROM ALL_SOURCE
        WHERE OWNER = dev_schema_name
            AND TYPE = 'PROCEDURE'
            AND NAME = dev_procedure.NAME
            AND LINE <> 1;

        SELECT LISTAGG(TEXT, CHR(10)) INTO prod_procedure_text FROM ALL_SOURCE
        WHERE OWNER = prod_schema_name
            AND TYPE = 'PROCEDURE'
            AND NAME = dev_procedure.NAME
            AND LINE <> 1;

        dev_procedure_text := REPLACE(dev_procedure_text, 'DEV', '');
        prod_procedure_text := REPLACE(prod_procedure_text, 'PROD', '');

        IF arguments_count <> 0 OR dev_procedure_text <> prod_procedure_text THEN
            DBMS_OUTPUT.PUT_LINE(dev_procedure.NAME);
            IF arguments_count <> 0 THEN
                DBMS_OUTPUT.PUT_LINE(CHR(9) || 'ARGUMENTS');
            END IF;
            IF dev_procedure_text <> prod_procedure_text THEN
                DBMS_OUTPUT.PUT_LINE(CHR(9) || 'CODE');
            END IF;
        END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------');
END get_procedure_differences;

CREATE OR REPLACE PROCEDURE get_function_differences(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2) AS
    arguments_count NUMBER;
    dev_function_text CLOB;
    prod_function_text CLOB;
    CURSOR dev_schema_functions is
            SELECT DISTINCT NAME FROM ALL_SOURCE
            WHERE TYPE = 'FUNCTION' AND OWNER = dev_schema_name;
BEGIN
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('FUNCTIONS FROM ' || dev_schema_name || ' THAT ARE NOT IN ' || prod_schema_name || ':');
    FOR dev_function in dev_schema_functions LOOP
        SELECT COUNT(*) INTO arguments_count FROM
        (
            (
                SELECT DATA_TYPE, ARGUMENT_NAME
                FROM ALL_ARGUMENTS
                WHERE OWNER = dev_schema_name AND OBJECT_NAME = dev_function.NAME
                MINUS
                SELECT DATA_TYPE, ARGUMENT_NAME
                FROM ALL_ARGUMENTS
                WHERE OWNER = prod_schema_name AND OBJECT_NAME = dev_function.NAME
                )
            UNION
            (
                SELECT DATA_TYPE, ARGUMENT_NAME
                FROM ALL_ARGUMENTS
                WHERE OWNER = prod_schema_name AND OBJECT_NAME = dev_function.NAME
                MINUS
                SELECT DATA_TYPE, ARGUMENT_NAME
                FROM ALL_ARGUMENTS
                WHERE OWNER = dev_schema_name AND OBJECT_NAME = dev_function.NAME
            )
        );

        SELECT LISTAGG(TEXT, CHR(10)) INTO dev_function_text FROM ALL_SOURCE
        WHERE OWNER = dev_schema_name
            AND TYPE = 'FUNCTION'
            AND NAME = dev_function.NAME
            AND LINE <> 1;

        SELECT LISTAGG(TEXT, CHR(10)) INTO prod_function_text FROM ALL_SOURCE
        WHERE OWNER = prod_schema_name
            AND TYPE = 'FUNCTION'
            AND NAME = dev_function.NAME
            AND LINE <> 1;

        dev_function_text := REPLACE(dev_function_text, 'DEV', '');
        prod_function_text := REPLACE(prod_function_text, 'PROD', '');

        IF arguments_count <> 0 OR dev_function_text <> prod_function_text THEN
            DBMS_OUTPUT.PUT_LINE(dev_function.NAME);
            IF arguments_count <> 0 THEN
                DBMS_OUTPUT.PUT_LINE(CHR(9) || 'ARGUMENTS');
            END IF;
            IF dev_function_text <> prod_function_text THEN
                DBMS_OUTPUT.PUT_LINE(CHR(9) || 'CODE');
            END IF;
        END IF;
    END LOOP;
END get_function_differences;

CREATE OR REPLACE PROCEDURE get_index_differences(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2) AS
BEGIN

END get_index_differences;

CREATE OR REPLACE PROCEDURE get_package_differences(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2) AS
BEGIN

END get_package_differences;

BEGIN
    get_procedure_differences('DEV', 'PROD');
END;

-- SELECT TEXT FROM ALL_SOURCE
-- WHERE TYPE = 'PROCEDURE' AND OWNER = 'DEV';
--
-- SELECT TEXT FROM ALL_SOURCE
-- WHERE TYPE = 'PROCEDURE' AND OWNER = 'PROD';
