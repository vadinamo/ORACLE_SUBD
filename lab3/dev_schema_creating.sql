ALTER SESSION SET "_ORACLE_SCRIPT"= TRUE; --switch to old mode
CREATE USER dev IDENTIFIED BY dev; --dev user creating
GRANT ALL PRIVILEGES TO dev; --grant rights

DROP TABLE DEV.TestTable1;
DROP TABLE DEV.TestTable;
CREATE TABLE DEV.TestTable(
    id NUMBER UNIQUE,
    val NUMBER,
    CONSTRAINT id_unique UNIQUE (id)
);
ALTER TABLE DEV.TestTable ADD CONSTRAINT id_unique UNIQUE (id);
ALTER TABLE DEV.TestTable DROP CONSTRAINT id_unique;

select * from ALL_CONSTRAINTS where OWNER = 'DEV'


CREATE TABLE DEV.TestTable1(
    id NUMBER,
    val NUMBER
);

CREATE INDEX DEV.TestIndex1 ON DEV.TestTable (val);
DROP INDEX DEV.TestIndex1;

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
    END IF;
END TestProcedure1;

CREATE OR REPLACE PROCEDURE DEV.TestProcedure2(id1 NUMBER) AS
    value number;
    count NUMBER;
BEGIN
    SELECT val INTO value FROM TestTable WHERE id = id1;

    SELECT COUNT(*) INTO COUNT
    FROM DEV.TestTable
    WHERE val = value AND id <> id1;

    IF value = 0 THEN
        DBMS_OUTPUT.PUT_LINE('VALUE IS UNIQUE');
    ELSE
        DBMS_OUTPUT.PUT_LINE('VALUE IS NOT UNIQUE');
    END IF;
END;

CREATE OR REPLACE FUNCTION DEV.TestFunction1(id1 NUMBER, id2 NUMBER)
    RETURN BOOLEAN
IS
    val1 NUMBER;
    val2 NUMBER;
BEGIN
    SELECT val INTO val1 FROM DEV.TestTable WHERE id = id1;
    SELECT val INTO val2 FROM DEV.TestTable WHERE id = id2;

    RETURN val1 = val2;
END TestFunction1;







CREATE TABLE DEV.table1 (
   id NUMBER PRIMARY KEY,
   val1 NUMBER,
   ref_table NUMBER
);

-- Создаем вторую таблицу
CREATE TABLE DEV.table2 (
   id NUMBER PRIMARY KEY,
   val2 NUMBER,
   ref_table NUMBER
);

-- Создаем третью таблицу
CREATE TABLE DEV.table3 (
   id NUMBER PRIMARY KEY,
   val3 NUMBER,
   ref_table NUMBER
);

ALTER TABLE dev.table1 MODIFY ref_table REFERENCES dev.table2(id);
ALTER TABLE dev.table2 MODIFY ref_table REFERENCES dev.table1(id);
ALTER TABLE dev.table3 MODIFY ref_table REFERENCES dev.table1(id);

DROP TABLE DEV.table1;
DROP TABLE DEV.table2;
DROP TABLE DEV.table3;

SELECT constraint_name
FROM all_constraints
WHERE owner = 'DEV' AND table_name = 'TABLE1' AND constraint_type = 'R';
SELECT constraint_name
FROM all_constraints
WHERE owner = 'DEV' AND table_name = 'TABLE2' AND constraint_type = 'R';
SELECT constraint_name
FROM all_constraints
WHERE owner = 'DEV' AND table_name = 'TABLE3' AND constraint_type = 'R';

ALTER TABLE dev.table1 DROP CONSTRAINT SYS_C008333;
ALTER TABLE dev.table2 DROP CONSTRAINT SYS_C008333;
ALTER TABLE dev.table3 DROP CONSTRAINT SYS_C008333;
