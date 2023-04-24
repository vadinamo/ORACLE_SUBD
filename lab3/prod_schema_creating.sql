ALTER SESSION SET "_ORACLE_SCRIPT"= TRUE; --switch to old mode
CREATE USER prod IDENTIFIED BY prod; --prod user creating
GRANT ALL PRIVILEGES TO prod; --grant rights

CREATE TABLE PROD.TestTable(
    id NUMBER,
    val NUMBER
);

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