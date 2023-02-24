CREATE OR REPLACE TRIGGER cascade_delete
    BEFORE DELETE ON GROUPS
    FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    EXECUTE IMMEDIATE 'ALTER TRIGGER group_student_counter DISABLE';
    DELETE FROM STUDENTS
    WHERE GROUP_ID = :OLD.id;
    EXECUTE IMMEDIATE 'ALTER TRIGGER group_student_counter ENABLE';
    commit;
END cascade_delete;