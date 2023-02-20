CREATE OR REPLACE TRIGGER student_logger
    BEFORE INSERT OR UPDATE OR DELETE ON STUDENTS
    FOR EACH ROW
DECLARE
  operation VARCHAR2(100);
BEGIN
    IF INSERTING THEN
        operation := 'INSERT, GROUP ID: ' || :NEW.GROUP_ID || ',NAME: ' || :NEW.NAME;
    ELSIF UPDATING THEN
        operation := 'UPDATE, GROUP ID: ' || :NEW.GROUP_ID || ',NAME: ' || :NEW.NAME;
    ELSIF DELETING THEN
        operation := 'DELETE, GROUP ID: ' || :OLD.GROUP_ID || ',NAME: ' || :OLD.NAME;
    END IF;

    DBMS_OUTPUT.PUT_LINE(operation);
END student_logger;