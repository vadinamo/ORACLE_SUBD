ALTER SESSION SET "_ORACLE_SCRIPT"= TRUE; --switch to old mode
CREATE USER dev IDENTIFIED BY dev; --dev user creating
GRANT ALL PRIVILEGES TO dev; --grant rights

CREATE TABLE DEV.TestTable(
    id NUMBER,
    val NUMBER,
    CONSTRAINT id_unique UNIQUE (id)
);

CREATE TABLE DEV.TestTable1(
    id NUMBER,
    val NUMBER
);

CREATE OR REPLACE PROCEDURE DEV.TestProcedure1(id1 NUMBER, id2 NUMBER) AS
    val1 NUMBER;
    val2 NUMBER;
BEGIN
    SELECT val INTO val1 FROM DEV.TestTable WHERE id = id1;
    SELECT val INTO val2 FROM DEV.TestTable WHERE id = id2;

    IF val1 <> val2 THEN
        DBMS_OUTPUT.PUT_LINE('VALUES ARE DIFFERENT');
    ELSE
        DBMS_OUTPUT.PUT_LINE('VALUES ARE SAME');
    end if;
END TestProcedure1;