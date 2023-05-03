CREATE OR REPLACE FUNCTION parse_select(JSON_FILE JSON_OBJECT_T) RETURN CLOB IS
    RESULT CLOB;

    JSON_OBJECT_ARRAY JSON_ARRAY_T;
    JSON_OBJECT_ARRAY_SIZE NUMBER;

    JSON_CONDITION_OBJECT JSON_OBJECT_T;
BEGIN
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

    JSON_CONDITION_OBJECT := TREAT(JSON_FILE.GET('condition') AS JSON_OBJECT_T);
    IF JSON_CONDITION_OBJECT IS NOT NULL THEN
        RESULT := RESULT || ' WHERE ' || parse_condition(JSON_CONDITION_OBJECT);
    END IF;

    RETURN RESULT;
END parse_select;

CREATE OR REPLACE FUNCTION parse_condition(JSON_FILE JSON_OBJECT_T) RETURN CLOB IS
    RESULT CLOB;
BEGIN
    IF JSON_FILE.GET_STRING('type') = 'operation' THEN
        RESULT := PARSE_CONDITION(TREAT(JSON_FILE.GET('left') AS JSON_OBJECT_T)) ||
                  ' ' || JSON_FILE.GET_STRING('operation') || ' ' ||
                  PARSE_CONDITION(TREAT(JSON_FILE.GET('right') AS JSON_OBJECT_T));
    ELSE
        RESULT := JSON_FILE.GET_STRING('operand');
    END IF;
    RETURN RESULT;
END parse_condition;

DECLARE
    JSON_TEXT CLOB;
BEGIN
    JSON_TEXT := '
{
  "type": "SELECT",
  "columns": ["Citizens.name"],
  "tables": ["Citizens"],
  "condition": {
    "type": "operation",
    "operation": "IS NOT",
    "left": {
      "type": "operand",
      "operand": "Citizens.house"
    },
    "right": {
      "type": "operand",
      "operand": "NULL"
    }
  }
}
';
    DBMS_OUTPUT.PUT_LINE(parse_select(JSON_OBJECT_T.PARSE(JSON_TEXT)));
END;
