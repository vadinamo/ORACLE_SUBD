CREATE OR REPLACE PROCEDURE CREATE_REPORT(FROM_TIME TIMESTAMP, TILL_TIME TIMESTAMP) IS
    CODE CLOB;
    COUNTER NUMBER;
    FILE_HANDLE UTL_FILE.FILE_TYPE;
BEGIN
    CODE := '
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
';
    CODE := CODE || '<h1>' || 'PEOPLE' || '</h1>';
    CODE := CODE || '<ul>' || CHR(10);
    SELECT COUNT(*) INTO COUNTER
    FROM PEOPLE_LOGS
        WHERE EVENT_TIME BETWEEN FROM_TIME AND TILL_TIME AND EVENT = 'INSERT';
    CODE := CODE || '<li>' || 'INSERT' || ': ' || COUNTER || '</li>' || CHR(10);

    SELECT COUNT(*) INTO COUNTER
    FROM PEOPLE_LOGS
        WHERE EVENT_TIME BETWEEN FROM_TIME AND TILL_TIME AND EVENT = 'UPDATE';
    CODE := CODE || '<li>' || 'UPDATE' || ': ' || COUNTER || '</li>' || CHR(10);

    SELECT COUNT(*) INTO COUNTER
    FROM PEOPLE_LOGS
        WHERE EVENT_TIME BETWEEN FROM_TIME AND TILL_TIME AND EVENT = 'DELETE';
    CODE := CODE || '<li>' || 'DELETE' || ': ' || COUNTER || '</li>' || CHR(10);
    CODE := CODE || '</ul>' || CHR(10);


    CODE := CODE || '<h1>' || 'LOCATIONS' || '</h1>';
    CODE := CODE || '<ul>' || CHR(10);
    SELECT COUNT(*) INTO COUNTER
    FROM LOCATIONS_LOGS
        WHERE EVENT_TIME BETWEEN FROM_TIME AND TILL_TIME AND EVENT = 'INSERT';
    CODE := CODE || '<li>' || 'INSERT' || ': ' || COUNTER || '</li>' || CHR(10);

    SELECT COUNT(*) INTO COUNTER
    FROM LOCATIONS_LOGS
        WHERE EVENT_TIME BETWEEN FROM_TIME AND TILL_TIME AND EVENT = 'UPDATE';
    CODE := CODE || '<li>' || 'UPDATE' || ': ' || COUNTER || '</li>' || CHR(10);

    SELECT COUNT(*) INTO COUNTER
    FROM LOCATIONS_LOGS
        WHERE EVENT_TIME BETWEEN FROM_TIME AND TILL_TIME AND EVENT = 'DELETE';
    CODE := CODE || '<li>' || 'DELETE' || ': ' || COUNTER || '</li>' || CHR(10);
    CODE := CODE || '</ul>' || CHR(10);

    CODE := CODE || '<h1>' || 'PASSPORTS' || '</h1>';
    CODE := CODE || '<ul>' || CHR(10);
    SELECT COUNT(*) INTO COUNTER
    FROM PASSPORTS_LOGS
        WHERE EVENT_TIME BETWEEN FROM_TIME AND TILL_TIME AND EVENT = 'INSERT';
    CODE := CODE || '<li>' || 'INSERT' || ': ' || COUNTER || '</li>' || CHR(10);

    SELECT COUNT(*) INTO COUNTER
    FROM PASSPORTS_LOGS
        WHERE EVENT_TIME BETWEEN FROM_TIME AND TILL_TIME AND EVENT = 'UPDATE';
    CODE := CODE || '<li>' || 'UPDATE' || ': ' || COUNTER || '</li>' || CHR(10);

    SELECT COUNT(*) INTO COUNTER
    FROM PASSPORTS_LOGS
        WHERE EVENT_TIME BETWEEN FROM_TIME AND TILL_TIME AND EVENT = 'DELETE';
    CODE := CODE || '<li>' || 'DELETE' || ': ' || COUNTER || '</li>' || CHR(10);
    CODE := CODE || '</ul>' || CHR(10);

    CODE := CODE || '</body>' || CHR(10) || '</html>';

    FILE_HANDLE := UTL_FILE.FOPEN(my_dir, 'report.html', 'W');
    UTL_FILE.PUT_LINE(FILE_HANDLE, CODE);
    UTL_FILE.FCLOSE(FILE_HANDLE);
END CREATE_REPORT;

CREATE OR REPLACE DIRECTORY my_dir AS '/Users/vadinamo/Documents/Oracle/subd';


BEGIN
    CREATE_REPORT(TO_TIMESTAMP('2023-03-10', 'YYYY-MM-DD'), SYSTIMESTAMP);
END;