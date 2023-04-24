ALTER SESSION SET "_ORACLE_SCRIPT"= TRUE; --switch to old mode
CREATE USER prod IDENTIFIED BY prod; --prod user creating
GRANT ALL PRIVILEGES TO prod; --grant rights

DROP TABLE PROD.TestTable;
CREATE TABLE PROD.TestTable(
    id NUMBER,
    val NUMBER
);

CREATE INDEX PROD.TestIndex1 ON PROD.TestTable (id, val);
DROP INDEX PROD.TestIndex1;

CREATE OR REPLACE PROCEDURE PROD.TestProcedure1(id1 NUMBER, id2 NUMBER, asd number) AS
    val1 NUMBER;
    val2 NUMBER;
BEGIN
    SELECT val INTO val1 FROM PROD.TestTable WHERE id = id1;
    SELECT val INTO val2 FROM PROD.TestTable WHERE id = id2;

    IF val1 <> val2 THEN
        DBMS_OUTPUT.PUT_LINE('VALUES ARE DIFFERENT');
    end if;
END TestProcedure1;

CREATE OR REPLACE PROCEDURE PROD.TestProcedure2(id1 NUMBER) AS
    value number;
    count NUMBER;
BEGIN
    SELECT val INTO value FROM TestTable WHERE id = id1;

    SELECT COUNT(*) INTO COUNT
    FROM PROD.TestTable
    WHERE val = value AND id <> id1;

    IF value = 0 THEN
        DBMS_OUTPUT.PUT_LINE('VALUE IS UNIQUE');
    ELSE
        DBMS_OUTPUT.PUT_LINE('VALUE IS NOT UNIQUE');
    END IF;
END;

CREATE OR REPLACE FUNCTION PROD.TestFunction1(id1 NUMBER, id2 NUMBER, asd number)
    RETURN BOOLEAN
IS
    val1 NUMBER;
    val2 NUMBER;
BEGIN
    SELECT val INTO val1 FROM PROD.TestTable WHERE id = id1;
    SELECT val INTO val2 FROM PROD.TestTable WHERE id = id2;

    RETURN val1 = val2;
END TestFunction1;