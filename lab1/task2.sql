DECLARE
    i NUMBER := 0;
BEGIN
    LOOP
        INSERT INTO MyTable
            VALUES (i, ROUND(DBMS_RANDOM.VALUE(-10000, 10000)));
        i := i + 1;
        EXIT WHEN i >= 10;
    END LOOP;
END;