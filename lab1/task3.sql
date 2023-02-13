CREATE OR REPLACE FUNCTION task3
    RETURN VARCHAR
    IS
    total_count NUMBER := 0;
    even_count  NUMBER := 0;
BEGIN
    SELECT COUNT(*),
           SUM(CASE WHEN MOD(val, 2) = 0 THEN 1 ELSE 0 END)
    INTO total_count, even_count
    FROM MyTable;
    IF even_count > total_count / 2 THEN
        RETURN 'TRUE';
    ELSIF even_count < total_count / 2 THEN
        RETURN 'FALSE';
    ELSE
        RETURN 'EQUAL';
    END IF;
END;