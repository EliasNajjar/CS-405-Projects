/*
 example4.sql
 Single-relation query
*/

/*
 Drop tables if they already exist
*/
-- Drop the foreign keys in the child table (REGISTRATION table)
-- alter table registration drop foreign key fk_registration_studentid;
-- alter table registration drop foreign key fk_registration_cno;

-- Drop the child table (REGISTRATION) before dropping its parent tables
drop table if exists registration;

drop table if exists students;
drop table if exists courses;

/*
 Create tables
*/

create table students (
 id char(9) primary key,
 name varchar(20) not null,
 gpa decimal(3,2),
 major varchar(20) default 'undetermined'
);

create table courses (
 cno char(6) primary key,
 name varchar(50),
 credits decimal(1,0)
);

create table registration (
 sid char(9),
 cno char(6),
 primary key (cno, sid),
 constraint fk_registration_studentid foreign key (sid) references students(id) on delete cascade,
 constraint fk_registration_cno foreign key (cno) references courses(cno) on delete cascade
);

/*
 Insert records into tables
*/

insert into courses values 
    ('cs500', null, null),
    ('cs215', 'C++', 4),
    ('cs405', 'Databases', 3),
    ('mat124', 'Calculus', 5);

insert into students values 
    ('111222999', 'John', 3.15, 'CS'),
    ('333111666', 'Robert', 3.58, 'MATH'),
    ('555222444', 'Jenny', 3.5, 'CS'),
    ('212343565', 'Mike', 3.25, 'CS');

insert into registration values 
    ('555222444', 'cs405'),
    ('555222444', 'mat124'), 
    ('555222444', 'cs215'),
    ('111222999', 'cs215'),
    ('333111666', 'cs215'),
    ('212343565', 'mat124');

select * from students;
select * from courses;
select * from registration;


select major from students;
select distinct major from students;

-- set operators: union, intersect, and except
(select id, name from students where major = 'CS')
except
(select id, name from students where gpa<3.5);

-- arithmetic operations in SELECT or WHERE clauses
select id, gpa * 1.1 as projectedGPA
from students;

select * 
from students
where gpa * 1.1 > 3.5 and major = 'CS';

-- order resulting records
select * from students order by major desc, gpa;

-- string pattern matching
select * from students where name like '%e%';
select * from students where name like '%e';
select * from students where name like '___e%';

select * from courses where name = null;
select * from courses where name is null;