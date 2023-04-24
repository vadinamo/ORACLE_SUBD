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
)