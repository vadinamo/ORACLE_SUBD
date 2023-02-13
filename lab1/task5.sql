CREATE OR REPLACE PROCEDURE insert_into_my_table(new_val NUMBER)
    IS
    new_id NUMBER;
BEGIN
    SELECT MAX(id) + 1 INTO new_id FROM MYTABLE;
    IF NOT SQL%NOTFOUND THEN
        INSERT INTO MYTABLE VALUES (0, new_val);
    ELSE
        INSERT INTO MYTABLE VALUES (new_id, new_val);
    end if;

END;

CREATE OR REPLACE PROCEDURE update_my_table(record_id NUMBER, new_val NUMBER)
    IS
BEGIN
    UPDATE MYTABLE SET val = new_val WHERE ID = record_id;
END;

CREATE OR REPLACE PROCEDURE delete_from_my_table(record_id NUMBER)
    IS
BEGIN
    DELETE FROM MYTABLE WHERE ID = record_id;
END;