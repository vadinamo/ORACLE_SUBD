CREATE TABLE Houses (
    ID NUMBER,
    ADDRESS VARCHAR2(100)
);

CREATE TABLE Citizens (
    ID NUMBER,
    NAME VARCHAR2(100),
    HOUSE NUMBER
);

INSERT INTO Houses VALUES (1, '1600 Amphitheatre Parkway, Mountain View');
INSERT INTO Houses VALUES (2, '221B Baker Street, San Francisco');
INSERT INTO Houses VALUES (3, '1600 Pennsylvania Avenue NW, Washington D.C.');

INSERT INTO Citizens VALUES (1, 'John Davis', 1);
INSERT INTO Citizens VALUES (2, 'Emma Davis', 1);
INSERT INTO Citizens VALUES (3, 'Sophia Rodriguez', 2);
INSERT INTO Citizens VALUES (4, 'Michael Thompson Jr.', 3);
INSERT INTO Citizens(ID, NAME) VALUES (5, 'William Lee');