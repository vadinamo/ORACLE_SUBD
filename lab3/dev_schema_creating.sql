ALTER SESSION SET "_ORACLE_SCRIPT"= TRUE; --switch to old mode
CREATE USER dev IDENTIFIED BY dev; --dev user creating
GRANT ALL PRIVILEGES TO dev; --grant rights