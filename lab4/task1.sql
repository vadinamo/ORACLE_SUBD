CREATE OR REPLACE FUNCTION parse_expression(JSON_FILE JSON_OBJECT_T) RETURN CLOB IS
    BUFFER CLOB;
    RESULT CLOB;

    JSON_OBJECT_ARRAY JSON_ARRAY_T;
    JSON_OBJECT_ARRAY_SIZE NUMBER;

    JSON_CONSTRAINT_ARRAY JSON_ARRAY_T;
    JSON_CONSTRAINT_ARRAY_SIZE NUMBER;

    JSON_CONDITION_OBJECT JSON_OBJECT_T;
BEGIN
    IF JSON_FILE.GET_STRING('type') = 'SELECT' THEN
        RESULT := 'SELECT ';

        JSON_OBJECT_ARRAY := JSON_FILE.GET_ARRAY('columns');
        JSON_OBJECT_ARRAY_SIZE := JSON_OBJECT_ARRAY.GET_SIZE() - 1;
        FOR i IN 0..JSON_OBJECT_ARRAY_SIZE LOOP
            RESULT := RESULT || JSON_OBJECT_ARRAY.GET_STRING(i);
            IF i < JSON_OBJECT_ARRAY_SIZE THEN
                RESULT := RESULT || ', ';
            END IF;
        END LOOP;

        RESULT := RESULT || ' FROM ';
        JSON_OBJECT_ARRAY := JSON_FILE.GET_ARRAY('tables');
        JSON_OBJECT_ARRAY_SIZE := JSON_OBJECT_ARRAY.GET_SIZE() - 1;
        FOR i IN 0..JSON_OBJECT_ARRAY_SIZE LOOP
            RESULT := RESULT || JSON_OBJECT_ARRAY.GET_STRING(i);
            IF i < JSON_OBJECT_ARRAY_SIZE THEN
                RESULT := RESULT || ', ';
            END IF;
        END LOOP;

        JSON_OBJECT_ARRAY := JSON_FILE.GET_ARRAY('joins');
        IF JSON_OBJECT_ARRAY IS NOT NULL THEN
            JSON_OBJECT_ARRAY_SIZE := JSON_OBJECT_ARRAY.GET_SIZE() - 1;
            FOR i IN 0..JSON_OBJECT_ARRAY_SIZE LOOP
                JSON_CONDITION_OBJECT := TREAT(JSON_OBJECT_ARRAY.GET(I) AS JSON_OBJECT_T);
                RESULT := RESULT || ' ' || JSON_CONDITION_OBJECT.GET_STRING('type') || ' JOIN ' ||
                          JSON_CONDITION_OBJECT.GET_STRING('table') || ' ON ' || parse_expression(TREAT(JSON_CONDITION_OBJECT.GET('condition') AS JSON_OBJECT_T));
            END LOOP;
        END IF;

        JSON_CONDITION_OBJECT := TREAT(JSON_FILE.GET('condition') AS JSON_OBJECT_T);
        IF JSON_CONDITION_OBJECT IS NOT NULL THEN
            RESULT := RESULT || ' WHERE ' || parse_expression(JSON_CONDITION_OBJECT);
        END IF;

    ELSIF JSON_FILE.GET_STRING('type') = 'INSERT' THEN
        RESULT := 'INSERT INTO ' || JSON_FILE.GET_STRING('table') || ' ';
        JSON_OBJECT_ARRAY := JSON_FILE.GET_ARRAY('names');
        IF JSON_OBJECT_ARRAY IS NOT NULL THEN
            JSON_OBJECT_ARRAY_SIZE := JSON_OBJECT_ARRAY.GET_SIZE() - 1;
            RESULT := RESULT || '(';
            FOR i IN 0..JSON_OBJECT_ARRAY_SIZE LOOP
                RESULT := RESULT || JSON_OBJECT_ARRAY.GET_STRING(i);
                IF i < JSON_OBJECT_ARRAY_SIZE THEN
                    RESULT := RESULT || ', ';
                END IF;
            END LOOP;
            RESULT := RESULT || ') ';
        END IF;

        RESULT := RESULT || 'VALUES (';
        JSON_OBJECT_ARRAY := JSON_FILE.GET_ARRAY('values');
        JSON_OBJECT_ARRAY_SIZE := JSON_OBJECT_ARRAY.GET_SIZE() - 1;
        FOR i IN 0..JSON_OBJECT_ARRAY_SIZE LOOP
            RESULT := RESULT || JSON_OBJECT_ARRAY.GET_STRING(i);
            IF i < JSON_OBJECT_ARRAY_SIZE THEN
                RESULT := RESULT || ', ';
            END IF;
        END LOOP;
        RESULT := RESULT || ')';

    ELSIF JSON_FILE.GET_STRING('type') = 'UPDATE' THEN
        RESULT := 'UPDATE ' || JSON_FILE.GET_STRING('table') || ' SET ';
        JSON_OBJECT_ARRAY := JSON_FILE.GET_ARRAY('values');
        JSON_OBJECT_ARRAY_SIZE := JSON_OBJECT_ARRAY.GET_SIZE() - 1;
        FOR i IN 0..JSON_OBJECT_ARRAY_SIZE LOOP
            JSON_CONDITION_OBJECT := TREAT(JSON_OBJECT_ARRAY.GET(i) AS JSON_OBJECT_T);
            RESULT := RESULT || JSON_CONDITION_OBJECT.GET_STRING('name') || ' = ' || JSON_CONDITION_OBJECT.GET_STRING('value');
            IF i < JSON_OBJECT_ARRAY_SIZE THEN
                RESULT := RESULT || ', ';
            END IF;
        END LOOP;

        JSON_CONDITION_OBJECT := TREAT(JSON_FILE.GET('condition') AS JSON_OBJECT_T);
        IF JSON_CONDITION_OBJECT IS NOT NULL THEN
            RESULT := RESULT || ' WHERE ' || parse_expression(JSON_CONDITION_OBJECT);
        END IF;

    ELSIF JSON_FILE.GET_STRING('type') = 'DELETE' THEN
        RESULT := 'DELETE FROM ' || JSON_FILE.GET_STRING('table');
        JSON_CONDITION_OBJECT := TREAT(JSON_FILE.GET('condition') AS JSON_OBJECT_T);
        IF JSON_CONDITION_OBJECT IS NOT NULL THEN
            RESULT := RESULT || ' WHERE ' || parse_expression(JSON_CONDITION_OBJECT);
        END IF;

    ELSIF JSON_FILE.GET_STRING('type') = 'CREATE' THEN
        RESULT := 'CREATE TABLE ' || JSON_FILE.GET_STRING('table') || ' (';
        JSON_OBJECT_ARRAY := JSON_FILE.GET_ARRAY('columns');
        JSON_OBJECT_ARRAY_SIZE := JSON_OBJECT_ARRAY.GET_SIZE() - 1;
        FOR i IN 0..JSON_OBJECT_ARRAY_SIZE LOOP
            JSON_CONDITION_OBJECT := TREAT(JSON_OBJECT_ARRAY.GET(i) AS JSON_OBJECT_T);
            RESULT := RESULT || JSON_CONDITION_OBJECT.GET_STRING('name') || ' ' || JSON_CONDITION_OBJECT.GET_STRING('type');

            JSON_CONSTRAINT_ARRAY := JSON_CONDITION_OBJECT.GET_ARRAY('constraints');
            IF JSON_CONSTRAINT_ARRAY IS NOT NULL THEN
                JSON_CONSTRAINT_ARRAY_SIZE := JSON_CONSTRAINT_ARRAY.GET_SIZE() - 1;
                FOR j IN 0..JSON_CONSTRAINT_ARRAY_SIZE LOOP
                    RESULT := RESULT || ' ' || JSON_CONSTRAINT_ARRAY.GET_STRING(j);
                    IF JSON_CONSTRAINT_ARRAY.GET_STRING(j) = 'PRIMARY KEY' THEN
                        BUFFER := BUFFER || create_pk_trigger(JSON_FILE.GET_STRING('table'), JSON_CONDITION_OBJECT.GET_STRING('name'));
                    END IF;
                END LOOP;
            END IF;

            IF i < JSON_OBJECT_ARRAY_SIZE THEN
                RESULT := RESULT || ', ';
            END IF;
        END LOOP;

        RESULT := RESULT || ')';
        IF BUFFER IS NOT NULL THEN
            RESULT := RESULT || ';' || CHR(10) || BUFFER;
        END IF;

    ELSIF JSON_FILE.GET_STRING('type') = 'DROP' THEN
        RESULT := 'DROP TABLE ' || JSON_FILE.GET_STRING('table');

    ELSIF JSON_FILE.GET_STRING('type') = 'operation' THEN
        RESULT := parse_expression(TREAT(JSON_FILE.GET('left') AS JSON_OBJECT_T)) ||
                  ' ' || JSON_FILE.GET_STRING('operation') || ' ' ||
                  parse_expression(TREAT(JSON_FILE.GET('right') AS JSON_OBJECT_T));
    ELSIF JSON_FILE.GET_STRING('type') = 'unary' THEN
        RESULT := parse_expression(TREAT(JSON_FILE.GET('left') AS JSON_OBJECT_T)) ||
                  ' ' || JSON_FILE.GET_STRING('operation') || ' (' ||
                  parse_expression(TREAT(JSON_FILE.GET('right') AS JSON_OBJECT_T)) || ')';
    ELSE
        RESULT := JSON_FILE.GET_STRING('operand');
    END IF;

    RETURN RESULT;
END parse_expression;

CREATE OR REPLACE FUNCTION create_pk_trigger(table_name VARCHAR2, column_name VARCHAR2) RETURN CLOB IS
    SEQUENCE_NAME CLOB;
    RESULT CLOB;
BEGIN
    SEQUENCE_NAME := table_name || '_' || column_name;
    RESULT := 'CREATE SEQUENCE ' || SEQUENCE_NAME || ';' || CHR(10) ||
              'CREATE OR REPLACE TRIGGER ' || table_name || '_' || 'insert' || '_' || column_name || CHR(10) ||
              'BEFORE INSERT ON ' || table_name || ' FOR EACH ROW' || CHR(10) ||
              'BEGIN' || CHR(10) ||
              ':NEW.' || column_name || ' := ' || SEQUENCE_NAME || '.NEXTVAL;' || CHR(10) ||
              'END ' || table_name || '_' || 'insert' || '_' || column_name || ';' || CHR(10);
    RETURN RESULT;
END create_pk_trigger;

DECLARE
    JSON_TEXT CLOB;
BEGIN
    JSON_TEXT := '
{
  "type": "CREATE",
  "table": "Cars",
  "columns": [
    {
      "name": "ID",
      "type": "NUMBER",
      "constraints": ["UNIQUE", "PRIMARY KEY"]
    },
    {
      "name": "BRAND",
      "type": "VARCHAR2(100)"
    },
    {
      "name": "MODEL",
      "type": "VARCHAR2(100)"
    }
  ]
}
';
    DBMS_OUTPUT.PUT_LINE(parse_expression(JSON_OBJECT_T.PARSE(JSON_TEXT)));
END;