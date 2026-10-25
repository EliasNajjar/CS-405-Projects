ALTER TABLE Employee DROP FOREIGN KEY fk_deptName;
ALTER TABLE Department DROP FOREIGN KEY fk_manager_employee;

DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Department;

DROP TRIGGER IF EXISTS hr_salary_update;
DROP TRIGGER IF EXISTS hr_salary_insert;

-- part b, may have the same name but identified by ID (primary key)
CREATE TABLE Employee (
    ID int PRIMARY KEY,
    name VARCHAR(20),
    salary INT,
    deptName VARCHAR(20)
);

-- part a, each department has a unique name (primary key)
-- manager can be null but must be unique because same employee cannot be manager of multiple departments
CREATE TABLE Department (
    name VARCHAR(20) PRIMARY KEY,
    managerID INT UNIQUE,
    -- part d, manager must be in Employee table, if deleted set null
    CONSTRAINT fk_manager_employee 
    FOREIGN KEY(managerID) REFERENCES Employee(ID)
    ON DELETE SET NULL
);

-- Employee deptName must be the name of a department
-- part e, if department deleted, set employee deptName to null
-- part f, if department updated, cascade to employee deptName
ALTER TABLE Employee ADD CONSTRAINT fk_deptName
FOREIGN KEY(deptName) REFERENCES Department(name)
ON UPDATE CASCADE
ON DELETE SET NULL;

-- part c, HR employee salary cannot be below 20000
delimiter //
CREATE TRIGGER IF NOT EXISTS hr_salary_update
BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
    if new.salary < 20000 and new.deptName = 'HR' THEN
        SIGNAL SQLSTATE '45000' set MESSAGE_TEXT = 'Salary cannot be less than 20,000';
    END IF;
end//
delimiter ;

delimiter //
CREATE TRIGGER IF NOT EXISTS hr_salary_insert
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
    if new.salary < 20000 and new.deptName = 'HR' THEN
        SIGNAL SQLSTATE '45000' set MESSAGE_TEXT = 'Salary cannot be less than 20,000';
    END IF;
end//
delimiter ;

/*
2. The insert will result in an error because the salary is below 20000 and the
   deptName is HR. This will activate the trigger hr_salary_insert defined above.

3. When department SALES is deleted, it sets all values of deptName in the Employee table
   that were SALES to null. So employee 222 will have deptName null after the deletion.
   This is enforced by the foreign key constraint fk_deptName above with ON DELETE SET NULL.

4. When employee 666 is deleted, it sets the managerID of the department with that
   employee as its manager to null. So department HR will have managerID null after
   the deletion. This is enforced by the foreign key constraint fk_manager_employee
   in the department table definition above with ON DELETE SET NULL.

5. When department HR is renamed to Human Resources, the update cascades to the employees
   with deptName HR. So employees 578 and 666 will have deptName Human Resources after the
   update. This is enforced by fk_deptName, with ON UPDATE CASCADE.