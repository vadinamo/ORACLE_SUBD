DROP SEQUENCE group_id;
DROP SEQUENCE student_id;

CREATE SEQUENCE group_id;
CREATE SEQUENCE student_id;

CREATE OR REPLACE TRIGGER group_insert_id
    BEFORE INSERT ON GROUPS
    FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        :NEW.id := group_id.NEXTVAL;
    end if;
END group_insert_id;

CREATE OR REPLACE TRIGGER group_insert_name
    BEFORE INSERT ON GROUPS
    FOR EACH ROW
DECLARE
    result NUMBER;
BEGIN
    SELECT COUNT(*) INTO result
    FROM GROUPS
    WHERE NAME = :NEW.name;

    IF NOT result = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Group name must be unique.');
    END IF;
END group_insert_name;

CREATE OR REPLACE TRIGGER student_insert_id
    BEFORE INSERT ON STUDENTS
    FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        :NEW.id := student_id.NEXTVAL;
    end if;
END student_insert_id;
