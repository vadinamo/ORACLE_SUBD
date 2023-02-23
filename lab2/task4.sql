CREATE OR REPLACE TRIGGER student_logger
    AFTER INSERT OR UPDATE OR DELETE
    ON STUDENTS
    FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO STUDENTS_LOGS(event, event_time, new_id, new_name, new_group_id)
        VALUES ('INSERT', SYSTIMESTAMP, :NEW.ID, :NEW.NAME, :NEW.GROUP_ID);
    ELSIF UPDATING THEN
        INSERT INTO STUDENTS_LOGS(event, event_time, old_id, old_name, old_group_id, new_id, new_name, new_group_id)
        VALUES ('UPDATE', SYSTIMESTAMP, :OLD.ID, :OLD.NAME, :OLD.GROUP_ID, :NEW.ID, :NEW.NAME, :NEW.GROUP_ID);
    ELSIF DELETING THEN
        INSERT INTO STUDENTS_LOGS(event, event_time, old_id, old_name, old_group_id)
        VALUES ('DELETE', SYSTIMESTAMP, :OLD.ID, :OLD.NAME, :OLD.GROUP_ID);
    END IF;
END student_logger;