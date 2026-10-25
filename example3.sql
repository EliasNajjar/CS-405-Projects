/* -----------------------------
 example3.sql
 Triggers
 -------------------------------
*/

/*
 Drop tables if they already exist
 - good practice: drop foreign keys before dropping tables
 - then drop child tables and parent tables
*/

alter table registration drop foreign key fk_registration_studentid;
alter table registration drop foreign key fk_registration_cno;

drop table if exists registration;

drop table if exists students;
drop table if exists courses;

drop table if exists courseChangeHistory;

/* ....................
 Create tables
 ......................
*/

create table students (
 id char(9) primary key,
 name varchar(20) not null,
 major varchar(20) default 'TBD'
);

create table courses (
 no char(6) primary key,
 name varchar(50) default 'NA',
 credits TINYINT, 
 capacity SMALLINT
);

create table registration (
 studentID char(9),
 cno char(6),
 primary key (cno, studentID),
 constraint fk_registration_studentid foreign key (studentID) references students(id) on delete cascade,
 constraint fk_registration_cno foreign key (cno) references courses(no) on update cascade
);

-- Used to log all changes on course credits 
create table courseChangeHistory (
 seqno INT AUTO_INCREMENT primary key,
 cno char(6) ,
 oldCredits decimal(1,0),
 newCredits decimal(1,0)
);

SELECT
    CONSTRAINT_SCHEMA,
    TABLE_NAME,
    CONSTRAINT_NAME,
    CONSTRAINT_TYPE
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = DATABASE()
ORDER BY TABLE_NAME, CONSTRAINT_TYPE, CONSTRAINT_NAME;

/* ....................
  Create triggers
  .....................
*/

-- reject an insert into the Registration table if the class is already full
delimiter //
create trigger if not exists trigger_registration_insert
before insert on registration
for each row
begin
  declare cap SMALLINT;       -- capacity of the course
  declare enrolled SMALLINT;  -- number of seats already taken

  select capacity into cap
  from courses
  where no = new.cno;

  select count(*) into enrolled
  from registration
  where cno = new.cno;

  if (enrolled >= cap) then
    SIGNAL SQLSTATE '45000' set MESSAGE_TEXT = 'Class is full!';
    end if;
end//

delimiter ;

-- whenever a course changes its credits, let's log this change by creating a new log record in table courseChangeHistory
delimiter //
create trigger if not exists trigger_creditsUpdate_log
after update on courses
for each row
begin 
  if (old.credits <> new.credits) then
    insert into courseChangeHistory(cno, oldCredits, newCredits) values(new.no, old.credits, new.credits);
  end if;
end//
delimiter ;

select 
  trigger_name, 
  event_object_table, 
  action_timing, 
  event_manipulation
from INFORMATION_SCHEMA.triggers
where trigger_schema = database(); 


/* ....................
  Insert tuples into tables
  .....................
*/

insert into students values ('111222999', 'John', 'CS');
insert into students values ('333111666', 'Robert', 'MATH');
insert into students values ('555222444', 'Jenny', 'CS');
insert into students values ('212343565', 'Robert', 'CS');

insert into courses(no, capacity) values ('CS500', 1);
insert into courses values ('CS215', 'C++', 4, 200);
insert into courses values ('CS405', 'Intro to Databases', 3, 100);
insert into courses values ('MA113', 'Calculus I', 3, 200);

insert into registration values ('555222444', 'CS500');
insert into registration values ('555222444', 'MA113');
insert into registration values ('555222444', 'CS215');
insert into registration values ('111222999', 'CS215');
insert into registration values ('333111666', 'CS215');

select * from students;
select * from courses;
select * from registration;
select * from courseChangeHistory;

/* ....................
  Test triggers
  .....................
*/

insert into registration values('111222999', 'CS500');    -- rejected according to the 1st trigger

update courses set credits = credits + 1 where no = 'MA113';  -- will add a new log record according to the 2nd trigger
select * from courseChangeHistory;                

