CREATE OR REPLACE PROCEDURE restore(time TIMESTAMP)
IS
BEGIN
    FOR event IN (SELECT * FROM Students_logs WHERE event_time >= time ORDER BY event_time DESC) LOOP
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