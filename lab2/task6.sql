-- CREATE OR REPLACE PROCEDURE counter_on_insert(group_id IN NUMBER)
--     IS
-- BEGIN
--     UPDATE GROUPS SET C_VAL = C_VAL + 1 WHERE ID = group_id;
-- END;
--
-- CREATE OR REPLACE PROCEDURE counter_on_update(old_group_id IN NUMBER, new_group_id IN NUMBER)
--     IS
-- BEGIN
--     IF new_group_id != old_group_id THEN
--         UPDATE GROUPS SET C_VAL = C_VAL - 1 WHERE ID = old_group_id;
--         UPDATE GROUPS SET C_VAL = C_VAL + 1 WHERE ID = new_group_id;
--     END IF;
-- END;
--
-- CREATE OR REPLACE PROCEDURE counter_on_delete(group_id IN NUMBER)
--     IS
-- BEGIN
--     UPDATE GROUPS SET C_VAL = C_VAL - 1 WHERE ID = group_id;
-- END;

CREATE OR REPLACE TRIGGER group_student_counter
    AFTER INSERT OR UPDATE OR DELETE
    ON STUDENTS
    FOR EACH ROW
BEGIN
    IF INSERTING THEN
        UPDATE GROUPS SET C_VAL = C_VAL + 1 WHERE ID = :NEW.GROUP_ID;
    ELSIF UPDATING THEN
        IF :NEW.GROUP_ID != :OLD.GROUP_ID THEN
            UPDATE GROUPS SET C_VAL = C_VAL - 1 WHERE ID = :OLD.GROUP_ID;
            UPDATE GROUPS SET C_VAL = C_VAL + 1 WHERE ID = :NEW.GROUP_ID;
        END IF;
    ELSIF DELETING THEN
        UPDATE GROUPS SET C_VAL = C_VAL - 1 WHERE ID = :OLD.ID;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
                NULL;
END group_student_counter;