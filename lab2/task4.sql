-- 5
DROP SEQUENCE students_logs_id;
CREATE SEQUENCE students_logs_id;

DROP TABLE Students_logs;
CREATE TABLE Students_logs (
    id NUMBER,
    event VARCHAR2(10),
    event_time TIMESTAMP,

    old_id NUMBER,
    old_name VARCHAR2(100),
    old_group_id NUMBER,

    new_id NUMBER,
    new_name VARCHAR2(100),
    new_group_id NUMBER
);

CREATE OR REPLACE TRIGGER student_logs_insert_id
    BEFORE INSERT ON Students_logs
    FOR EACH ROW
BEGIN
    :NEW.id := students_logs_id.NEXTVAL;
END student_logs_insert_id;

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