CREATE OR REPLACE FUNCTION task6(salary NUMBER, reward_percent NUMBER)
    RETURN VARCHAR
    IS
BEGIN
    IF reward_percent < 0 THEN
        RETURN 'percent cannot be negative';
    END IF;
    IF salary < 0 THEN
        RETURN 'salary cannot be negative';
    END IF;
    RETURN (1 + reward_percent) / 100 * 12 * salary;
END;