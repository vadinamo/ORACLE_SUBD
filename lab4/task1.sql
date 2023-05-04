CREATE OR REPLACE FUNCTION parse_expression(JSON_FILE JSON_OBJECT_T) RETURN CLOB IS
    RESULT CLOB;

    JSON_OBJECT_ARRAY JSON_ARRAY_T;
    JSON_OBJECT_ARRAY_SIZE NUMBER;

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

DECLARE
    JSON_TEXT CLOB;
BEGIN
    JSON_TEXT := '
{
  "type": "INSERT",
  "table": "Citizens",
  "names": ["id", "name", "house"],
  "values": [6, "''John Davis Jr.''", 1]
}
';
    DBMS_OUTPUT.PUT_LINE(parse_expression(JSON_OBJECT_T.PARSE(JSON_TEXT)));
END;
