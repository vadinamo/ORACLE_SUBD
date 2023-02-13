CREATE OR REPLACE FUNCTION task4(id_to_find NUMBER)
    RETURN VARCHAR
    IS
    val_to_find NUMBER;
BEGIN
    SELECT val INTO val_to_find
    FROM MyTable
    WHERE id = id_to_find;

    RETURN ('INSERT INTO MyTable VALUES(' || id_to_find || ', ' || val_to_find || ')');
EXCEPTION
    WHEN no_data_found
    THEN RETURN 'No matching entry found';
END;