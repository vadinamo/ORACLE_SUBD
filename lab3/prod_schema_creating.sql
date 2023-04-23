ALTER SESSION SET "_ORACLE_SCRIPT"= TRUE; --switch to old mode
CREATE USER prod IDENTIFIED BY prod; --prod user creating
GRANT ALL PRIVILEGES TO prod; --grant rights