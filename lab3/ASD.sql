SELECT * FROM ALL_SOURCE WHERE TYPE = 'FUNCTION' AND OWNER = 'PROD';

DROP FUNCTION PROD.TESTFUNCTION1;

DECLARE
    dev_schema_name VARCHAR2(32767);
    prod_schema_name VARCHAR2(32767);
BEGIN
    dev_schema_name := 'DEV';
    prod_schema_name := 'PROD';

--     GET_FUNCTION_DIFFERENCES(dev_schema_name, prod_schema_name);
--     CHECK_CYCLE(dev_schema_name);
    GET_TABLE_DIFFERENCES(dev_schema_name, prod_schema_name);
end;