-- Example0.sql: try connection and simple DDL and DML statements

/*
comment 1
comment 2
*/

create table if not exists schedule (
    day char(1) primary key, 
    task varchar(50)
);

show tables;
describe schedule;

alter table schedule
add taskHours decimal(3,2);

describe schedule;

insert into schedule values('M', 'CS315', 1.5);
insert into schedule values('T', 'CS405', 1.5);

select * from schedule;

delete from schedule where day = 'M';

drop table schedule;
show tables;