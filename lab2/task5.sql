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

CREATE OR REPLACE PROCEDURE restore(time TIMESTAMP)
IS
BEGIN
    FOR event IN (SELECT * FROM Students_logs WHERE event_time <= time ORDER BY event_time DESC) LOOP
        IF event.event = 'INSERT' THEN
            DELETE FROM STUDENTS
            WHERE ID = event.new_id;
        ELSIF event.event = 'UPDATE' THEN
            UPDATE STUDENTS
            SET ID = event.old_id, NAME = event.old_name, GROUP_ID = event.old_group_id
            WHERE ID = event.new_id;
        ELSIF event.event = 'DELETE' THEN
            INSERT INTO STUDENTS(NAME, GROUP_ID)
            VALUES(event.old_name, event.old_group_id);
        END IF;
    END LOOP;
end;