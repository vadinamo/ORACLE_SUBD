DROP TABLE STUDENTS;
DROP TABLE GROUPS;

CREATE TABLE Students (
	id NUMBER,
	name VARCHAR2(100),
	group_id number
);

CREATE TABLE Groups (
    id NUMBER,
    name VARCHAR2(100),
    c_val NUMBER
)