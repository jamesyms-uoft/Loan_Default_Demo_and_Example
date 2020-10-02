drop database bank;
create database if not exists bank;

use bank;

create table if not exists accounts(
        account_id          int,
        district_id         int,
        frequency           varchar(255),
        dt                  date,
        PRIMARY KEY(account_id)
);

truncate table accounts;
set global local_infile='ON';
load data local infile 'C:\\Users\\james\\Desktop\\Wecloud_Data_Bootcamp\\bank_loan\\account.asc'
into table accounts
character set 'latin1'
fields terminated by ';'Enclosed by '"'
lines terminated by '\n'
ignore 1 lines
(account_id,district_id,frequency, @dt)
SET dt = str_to_date(@dt, '%y%m%d');

select * from accounts;

create table if not exists clients(
        client_id           int,
        birth_date          date,
        district_id         int,
        gender              tinyint,
        PRIMARY KEY(client_id)
);
truncate table clients;

create table if not exists clients_0(
        client_id           int,
        birth_date          varchar(255),
        district_id         int
);
truncate table clients_0;

load data local infile 'C:\\Users\\james\\Desktop\\Wecloud_Data_Bootcamp\\bank_loan\\client.asc'
into table clients_0
character set 'latin1'
fields terminated by ';'Enclosed by '"'
lines terminated by '\r\n'
ignore 1 lines;

insert into bank.clients(client_id,
                        birth_date,
                        district_id,
                        gender)
select client_id,
       case when substr(birth_date,3,2) <=12 then str_to_date(concat('19',birth_date),'%Y%m%d')
       else str_to_date(concat('19',substr(birth_date,1,2),
                               lpad(substr(birth_date,3,2)-50,2,'0'),substr(birth_date,5,2)),'%Y%m%d') end,
       district_id,
       case when substr(birth_date,3,2) <=12 then 1 else 0 end
from clients_0;
select * from clients_0;
select * from clients;

drop table clients_0;


create table if not exists disps(
        disp_id             int,
        client_id           int,
        account_id          int,
        type                varchar(255),
        PRIMARY KEY(disp_id)
);
truncate table disps;

load data local infile 'C:\\Users\\james\\Desktop\\Wecloud_Data_Bootcamp\\bank_loan\\disp.asc'
into table disps
character set 'latin1'
fields terminated by ';'Enclosed by '"'
lines terminated by '\r\n'
ignore 1 lines;

create table if not exists orders(
        order_id            int,
        account_id          int,
        bank_to             varchar(255),
        account_to          int,
        amount              decimal(10,2),
        k_symbol            varchar(255),
        PRIMARY KEY(order_id)
);
truncate table orders;

load data local infile 'C:\\Users\\james\\Desktop\\Wecloud_Data_Bootcamp\\bank_loan\\order.asc'
into table orders
character set 'latin1'
fields terminated by ';'Enclosed by '"'
lines terminated by '\r\n'
ignore 1 lines;

create table if not exists loans(
        loan_id             int,
        account_id          int,
        loan_date           date,
        amount              int,
        duration            int,
        payments            decimal(10,2),
        status              varchar(255),
        PRIMARY KEY(loan_id)
);
truncate table loans;

load data local infile 'C:\\Users\\james\\Desktop\\Wecloud_Data_Bootcamp\\bank_loan\\loan.asc'
into table loans
character set 'latin1'
fields terminated by ';'Enclosed by '"'
lines terminated by '\r\n'
ignore 1 lines
(loan_id,account_id, @loan_date, amount,duration,payments,status)
SET loan_date = str_to_date(@loan_date,'%y%m%d');


create table if not exists cards(
        card_id             int,
        disp_id             int,
        `type`              varchar(255),
        issue_date          date,
        PRIMARY KEY(card_id)
);
truncate table cards;

load data local infile 'C:\\Users\\james\\Desktop\\Wecloud_Data_Bootcamp\\bank_loan\\card.asc'
into table cards
character set 'latin1'
fields terminated by ';'Enclosed by '"'
lines terminated by '\n'
ignore 1 lines
(card_id,disp_id,`type`,@issue_date)
SET issue_date = str_to_date(@issue_date, '%y%m%d');

create table if not exists districts(
        district_id         int,
        A2                  varchar(225),
        A3                  varchar(255),
        A4                  int,
        A5                  int,
        A6                  int,
        A7                  int,
        A8                  int,
        A9                  int,
        A10                 decimal(5,2),
        A11                 int,
        A12                 decimal(5,2),
        A13                 decimal(5,2),
        A14                 int,
        A15                 int,
        A16                 int,
        PRIMARY KEY(district_id)
);
truncate table districts;

load data local infile 'C:\\Users\\james\\Desktop\\Wecloud_Data_Bootcamp\\bank_loan\\district.asc'
into table districts
character set 'latin1'
fields terminated by ';'Enclosed by '"'
lines terminated by '\n'
ignore 1 lines;

create table if not exists trans(
        trans_id            int,
        account_id          int,
        trans_date          date,
        type                varchar(255),
        operation           varchar(255),
        amount              int,
        balance             int,
        k_symbol            varchar(255),
        bank                varchar(255),
        account             int
);
truncate table trans;

load data local infile 'C:\\Users\\james\\Desktop\\Wecloud_Data_Bootcamp\\bank_loan\\trans.asc'
into table trans
character set 'latin1'
fields terminated by ';'Enclosed by '"'
lines terminated by '\r\n'
ignore 1 lines
(trans_id,account_id,@trans_date,type, operation,amount,balance,k_symbol,bank,account)
SET trans_date = str_to_date(@trans_date, '%y%m%d');


/* foreign keys */
ALTER TABLE accounts ADD FOREIGN KEY (district_id) REFERENCES districts(district_id);
ALTER TABLE cards ADD FOREIGN KEY (disp_id) REFERENCES disps(disp_id);
ALTER TABLE clients ADD FOREIGN KEY (district_id) REFERENCES districts(district_id);
ALTER TABLE disps ADD FOREIGN KEY (account_id) REFERENCES accounts(account_id);
ALTER TABLE disps ADD FOREIGN KEY (client_id) REFERENCES clients(client_id);
ALTER TABLE loans ADD FOREIGN KEY (account_id) REFERENCES accounts(account_id);
ALTER TABLE orders ADD FOREIGN KEY (account_id) REFERENCES accounts(account_id);
ALTER TABLE trans ADD FOREIGN KEY (account_id) REFERENCES accounts(account_id);

select * from accounts;
select * from orders group by account_id;
select * from loans;
select * from cards;
select * from disps;
select * from clients;
select * from trans;
select * from districts;

select lo.account_id,
       c.type,
       d.type,
       o.amount,
       lo.payments,
       lo.amount
from loans as lo
left join disps as d on lo.account_id = d.account_id
left join cards c on d.disp_id = c.disp_id
left join orders o on lo.account_id = o.account_id
where lo.account_id is not null;

select lo.account_id,
       c.type,
       d.type,
       o.amount,
       lo.payments,
       lo.amount,
       t.amount,
       t.balance
from loans as lo
left join disps as d on lo.account_id = d.account_id
left join cards c on d.disp_id = c.disp_id
left join orders o on lo.account_id = o.account_id
right join trans t on lo.account_id = t.account_id
where lo.account_id is not null
group by lo.account_id;

select t.account_id,
       avg(t.amount) trans_amount,
       avg(t.balance) trans_balance,
       l.payments loan_payments,
       l.amount loan_amount,
       c.gender gender,
       o.amount order_amount
from trans t
left join loans l on t.account_id = l.account_id
left join disps d on t.account_id = d.account_id
left join clients c on d.client_id = c.client_id
inner join orders o on t.account_id = o.account_id
group by account_id
order by avg(balance) desc;

create table trans_agg(
select account_id, count(trans_id) as trans_num,
       sum(case when operation = 'VKLAD' then 1 else 0 end) as credit_in_cash,
       sum(case when operation = 'PREVOD Z UCTU' then 1 else 0 end) as collection_from_another_bank,
       sum(case when operation = 'PREVOD NA UCET' then 1 else 0 end) as remittance_to_another_bank,
       sum(case when operation = 'VYBER' then 1 else 0 end) as withdrawal_in_cash,
       sum(case when operation = 'VYBER KARTOU' then 1 else 0 end) as credit_card_withdrawal,
       avg(case when operation = 'VKLAD' then amount end) as credit_in_cash_amount,
       avg(case when operation = 'PREVOD Z UCTU' then amount end) as collection_from_another_bank_amount,
       avg(case when operation = 'PREVOD NA UCET' then amount end) as remittance_to_another_bank_amount,
       avg(case when operation = 'VYBER' then amount end) as withdrawal_in_cash_amount,
       avg(case when operation = 'VYBER KARTOU' then amount end) as credit_card_withdrawal_amount

from trans
group by account_id
);

select * from trans;
select * from trans_agg;