-- Example1.sql 
-- Try NOT NULL, UNIQUE constraints

drop table students;

create table students (
    ssn char(9) unique,
    id char(9) primary key,
    lastName varchar(20) not null,
    major varchar(20) default 'CS'
);

-- Rejected: violation of not null constraint for lastName
insert into students(ssn, id) values('111222333', '901111111');

insert into students(ssn, id, lastName) values('111222333', '901111111', 'Smith');
select * from students;

-- Rejected: violation of unique constraint for ssn
insert into students(ssn, id, lastName) values('111222333', '902222222', 'Yang');

