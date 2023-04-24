-- CREATE OR REPLACE FUNCTION SELECT_ARGUMENTS(schema_name varchar2, entity_name varchar2)
--     RETURN SYS_REFCURSOR
-- IS
--     return_cursor SYS_REFCURSOR;
-- BEGIN
--     OPEN return_cursor FOR
--         SELECT DATA_TYPE, ARGUMENT_NAME
--         FROM ALL_ARGUMENTS
--         WHERE OWNER = schema_name AND OBJECT_NAME = entity_name;
--     RETURN return_cursor;
-- END SELECT_ARGUMENTS;
--
-- CREATE OR REPLACE FUNCTION SELECT_INDEX_COLUMNS(schema_owner varchar2, entity_name varchar2)
--     RETURN SYS_REFCURSOR
-- IS
--     return_cursor SYS_REFCURSOR;
-- BEGIN
--     OPEN return_cursor FOR
--         SELECT ALL_INDEXES.INDEX_TYPE, ALL_INDEXES.TABLE_NAME, ALL_INDEXES.UNIQUENESS,
--                ALL_INDEXES.CONSTRAINT_INDEX, ALL_IND_COLUMNS.COLUMN_NAME, ALL_IND_COLUMNS.COLUMN_POSITION
--         FROM ALL_INDEXES
--             JOIN ALL_IND_COLUMNS
--                 ON ALL_INDEXES.INDEX_NAME = ALL_IND_COLUMNS.INDEX_NAME
--             WHERE ALL_INDEXES.INDEX_NAME = entity_name
--             AND ALL_INDEXES.OWNER = schema_owner
--             AND ALL_IND_COLUMNS.TABLE_OWNER = schema_owner;
--     RETURN return_cursor;
-- END SELECT_INDEX_COLUMNS;

CREATE OR REPLACE FUNCTION DASHES(input_string VARCHAR2)
    RETURN VARCHAR2
IS
    before_count NUMBER;
    after_count NUMBER;
BEGIN
    before_count := TRUNC((50 - LENGTH(input_string)) / 2);
    after_count := CEIL((50 - LENGTH(input_string)) / 2);
    RETURN RPAD('-', before_count, '-') || input_string || LPAD('-', after_count, '-');
END DASHES;