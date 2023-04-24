CREATE OR REPLACE PROCEDURE get_procedure_differences(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2) AS
    arguments_count NUMBER;
    dev_procedure_text CLOB;
    prod_procedure_text CLOB;
    CURSOR dev_schema_procedures is
        SELECT DISTINCT NAME FROM ALL_SOURCE
        WHERE ALL_SOURCE.TYPE = 'PROCEDURE' AND OWNER = dev_schema_name;
BEGIN
    DBMS_OUTPUT.PUT_LINE(DASHES('PROCEDURES FROM ' || dev_schema_name || ' THAT ARE NOT IN ' || prod_schema_name || ':'));
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
            AND ALL_SOURCE.TYPE = 'PROCEDURE'
            AND NAME = dev_procedure.NAME
            AND LINE > 1;

        SELECT LISTAGG(TEXT, CHR(10)) INTO prod_procedure_text FROM ALL_SOURCE
        WHERE OWNER = prod_schema_name
            AND ALL_SOURCE.TYPE = 'PROCEDURE'
            AND NAME = dev_procedure.NAME
            AND LINE > 1;

        dev_procedure_text := REPLACE(dev_procedure_text, dev_schema_name, '');
        prod_procedure_text := REPLACE(prod_procedure_text, prod_schema_name, '');

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
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
END get_procedure_differences;

CREATE OR REPLACE PROCEDURE get_function_differences(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2) AS
    arguments_count NUMBER;
    dev_function_text CLOB;
    prod_function_text CLOB;
    CURSOR dev_schema_functions is
            SELECT DISTINCT NAME FROM ALL_SOURCE
            WHERE ALL_SOURCE.TYPE = 'FUNCTION' AND OWNER = dev_schema_name;
BEGIN
    DBMS_OUTPUT.PUT_LINE(DASHES('FUNCTIONS FROM ' || dev_schema_name || ' THAT ARE NOT IN ' || prod_schema_name || ':'));
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
            AND ALL_SOURCE.TYPE = 'FUNCTION'
            AND NAME = dev_function.NAME
            AND LINE > 1;

        SELECT LISTAGG(TEXT, CHR(10)) INTO prod_function_text FROM ALL_SOURCE
        WHERE OWNER = prod_schema_name
            AND ALL_SOURCE.TYPE = 'FUNCTION'
            AND NAME = dev_function.NAME
            AND LINE > 1;

        dev_function_text := REPLACE(dev_function_text, dev_schema_name, '');
        prod_function_text := REPLACE(prod_function_text, prod_schema_name, '');

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
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
END get_function_differences;

CREATE OR REPLACE PROCEDURE get_index_differences(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2) AS
    index_count NUMBER;
    CURSOR dev_schema_indexes is
        SELECT * FROM ALL_INDEXES
        WHERE OWNER = dev_schema_name;
BEGIN
    DBMS_OUTPUT.PUT_LINE(DASHES('INDEXES FROM ' || dev_schema_name || ' THAT ARE NOT IN ' || prod_schema_name || ':'));
    FOR dev_index IN dev_schema_indexes LOOP
        SELECT COUNT(*) INTO index_count FROM
        (
            (
            SELECT ALL_INDEXES.INDEX_TYPE, ALL_INDEXES.TABLE_NAME, ALL_INDEXES.UNIQUENESS,
                   ALL_INDEXES.CONSTRAINT_INDEX, ALL_IND_COLUMNS.COLUMN_NAME, ALL_IND_COLUMNS.COLUMN_POSITION
            FROM ALL_INDEXES
                JOIN ALL_IND_COLUMNS
                    ON ALL_INDEXES.INDEX_NAME = ALL_IND_COLUMNS.INDEX_NAME
                WHERE ALL_INDEXES.INDEX_NAME = dev_index.INDEX_NAME
                AND ALL_INDEXES.OWNER = dev_schema_name
                AND ALL_IND_COLUMNS.TABLE_OWNER = dev_schema_name
            MINUS
            SELECT ALL_INDEXES.INDEX_TYPE, ALL_INDEXES.TABLE_NAME, ALL_INDEXES.UNIQUENESS,
                   ALL_INDEXES.CONSTRAINT_INDEX, ALL_IND_COLUMNS.COLUMN_NAME, ALL_IND_COLUMNS.COLUMN_POSITION
            FROM ALL_INDEXES
                JOIN ALL_IND_COLUMNS
                    ON ALL_INDEXES.INDEX_NAME = ALL_IND_COLUMNS.INDEX_NAME
                WHERE ALL_INDEXES.INDEX_NAME = dev_index.INDEX_NAME
                AND ALL_INDEXES.OWNER = prod_schema_name
                AND ALL_IND_COLUMNS.TABLE_OWNER = prod_schema_name
            )
            UNION
            (
                SELECT ALL_INDEXES.INDEX_TYPE, ALL_INDEXES.TABLE_NAME, ALL_INDEXES.UNIQUENESS,
                   ALL_INDEXES.CONSTRAINT_INDEX, ALL_IND_COLUMNS.COLUMN_NAME, ALL_IND_COLUMNS.COLUMN_POSITION
            FROM ALL_INDEXES
                JOIN ALL_IND_COLUMNS
                    ON ALL_INDEXES.INDEX_NAME = ALL_IND_COLUMNS.INDEX_NAME
                WHERE ALL_INDEXES.INDEX_NAME = dev_index.INDEX_NAME
                AND ALL_INDEXES.OWNER = prod_schema_name
                AND ALL_IND_COLUMNS.TABLE_OWNER = prod_schema_name
            MINUS
            SELECT ALL_INDEXES.INDEX_TYPE, ALL_INDEXES.TABLE_NAME, ALL_INDEXES.UNIQUENESS,
                   ALL_INDEXES.CONSTRAINT_INDEX, ALL_IND_COLUMNS.COLUMN_NAME, ALL_IND_COLUMNS.COLUMN_POSITION
            FROM ALL_INDEXES
                JOIN ALL_IND_COLUMNS
                    ON ALL_INDEXES.INDEX_NAME = ALL_IND_COLUMNS.INDEX_NAME
                WHERE ALL_INDEXES.INDEX_NAME = dev_index.INDEX_NAME
                AND ALL_INDEXES.OWNER = dev_schema_name
                AND ALL_IND_COLUMNS.TABLE_OWNER = dev_schema_name
            )
        );

        IF index_count <> 0 THEN
            DBMS_OUTPUT.PUT_LINE(dev_index.INDEX_NAME);
        END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
END get_index_differences;

CREATE OR REPLACE PROCEDURE get_package_differences(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2) AS
    dev_package_text CLOB;
    prod_package_text CLOB;
    CURSOR dev_schema_packages is
        SELECT DISTINCT NAME FROM ALL_SOURCE
            WHERE OWNER = dev_schema_name AND ALL_SOURCE.TYPE = 'PACKAGE';
BEGIN
    DBMS_OUTPUT.PUT_LINE(DASHES('PACKAGES FROM ' || dev_schema_name || ' THAT ARE NOT IN ' || prod_schema_name || ':'));
    FOR dev_package in dev_schema_packages LOOP
        SELECT LISTAGG(TEXT, CHR(10)) INTO dev_package_text FROM ALL_SOURCE
        WHERE OWNER = dev_schema_name
            AND ALL_SOURCE.TYPE = 'PACKAGE'
            AND NAME = dev_package.NAME
            AND LINE > 1;

        SELECT LISTAGG(TEXT, CHR(10)) INTO dev_package_text FROM ALL_SOURCE
        WHERE OWNER = prod_schema_name
            AND ALL_SOURCE.TYPE = 'PACKAGE'
            AND NAME = dev_package.NAME
            AND LINE > 1;

        IF dev_package_text <> prod_package_text THEN
            DBMS_OUTPUT.PUT_LINE(dev_package.NAME);
        END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
END get_package_differences;

DECLARE
    dev_schema_name VARCHAR2(32767);
    prod_schema_name VARCHAR2(32767);
BEGIN
    dev_schema_name := 'DEV';
    prod_schema_name := 'PROD';
    get_table_differences(dev_schema_name, prod_schema_name);
    get_procedure_differences(dev_schema_name, prod_schema_name);
    get_function_differences(dev_schema_name, prod_schema_name);
    get_index_differences(dev_schema_name, prod_schema_name);
    get_package_differences(dev_schema_name, prod_schema_name);
END;
