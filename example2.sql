/*
 example2.sql
 1. CHECK constraint
 2. FOREIGN KEY constraint
*/

/* 
 drop tables if they already exist
 */
-- drop the foreign keys in the child table before dropping their parent tables
alter table registration drop foreign key fk_registration_studentID;
alter table registration drop foreign key fk_registration_cno;

drop table if exists students;
drop table if exists courses;
drop table if exists registration;

/*
 Create tables
*/
create table students (
 id char(9) primary key,
 name varchar(20) not null,
 major varchar(20) default 'TBD'
);

create table courses (
 no char(6) primary key,
 name varchar(50) default 'NA',
 credits decimal(1,0), 
 constraint ck_courses_credit CHECK(credits in (0, 1, 2, 3, 4, 5)),
 constraint ck_courses_csCredit CHECK(credits <= 4 or no not like 'CS%')     -- any CS course: credits should be <= 4
);
-- De Morgan's Law: not(credits>4 and no like 'CS%') = (credits<=4) or (no like 'CS%') 

create table registration (
 studentID char(9),
 cno char(6),
 primary key (cno, studentID),
 constraint fk_registration_studentID foreign key(studentID) references students(id), -- students: parent table
 constraint fk_registration_cno foreign key(cno) references courses(no)
);

show tables;

select
    table_name,
    constraint_name,
    constraint_type
from information_schema.table_constraints
where constraint_schema = database()
order by table_name, constraint_type, constraint_name;

/*
 Insert tuples into tables
*/

insert into students values ('111222999', 'John', 'CS');
insert into students values ('333111666', 'Robert', 'MATH');
insert into students values ('555222444', 'Jenny', 'CS');
insert into students values ('212343565', 'Robert', 'CS');

insert into courses(no) values ('CS500');
insert into courses values ('CS215', 'C++', 4);
insert into courses values ('CS405', 'Intro to Databases', 3);
insert into courses values ('MA113', 'Calculus I', 3);

insert into registration values ('555222444', 'CS405');
insert into registration values ('555222444', 'MA113');
insert into registration values ('555222444', 'CS215');
insert into registration values ('111222999', 'CS215');
insert into registration values ('333111666', 'CS215');

select * from students;
select * from courses;
select * from registration;

/*
 Understanding CHECK constraints
*/
insert into courses values('CS600', 'Mobile Computing', 5);     -- failed
update courses set name='Wireless Networks', credits = 6 where no='CS500';  -- failed


/*
 Understanding FOREIGN KEY constraints
*/
-- any insert and update in a "Child" table that violates the FK constraint will be rejected!
insert into registration values('333111666', 'MAT107');             -- failed
update registration set cno='CS200' where studentID='333111666';    -- failed

/*
 ON DELETE CASCADE
 ON DELETE SET NULL
*/
-- In the future, let's complete all schema declarations BEFORE DML statements (delete, insert, update)
-- delete and update in a "parent" table: use ON DELETE / ON UPDATE clause to allow the operation if it will violate the FK constraint

delete from students where id='111222999';      -- failed

alter table registration drop constraint fk_registration_studentID;
alter table registration add constraint fk_registration_studentID 
    foreign key(studentID) references students(id)
    on delete CASCADE;

select * from students;
select * from registration;

delete from students where id='111222999';      -- successful

select * from students;
select * from registration;

/*
 ON UPDATE CASCADE
*/
update courses set no='CS015' where name='C++';     -- failed

-- In the future, let's complete all schema declarations BEFORE DML statements (delete, insert, update)
alter table registration drop constraint fk_registration_cno;
alter table registration add constraint fk_registration_cno 
    foreign key(cno) references courses(no) 
    on update cascade;

select * from courses;
select * from registration;

update courses set no='CS015' where name='C++';     -- successful

select * from courses;
select * from registration;