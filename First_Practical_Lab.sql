create database Labor;
use Labor;

-- create table Country(
--     code varchar(10) primary key,
--     name varchar(100)
-- )

-- create table Region(
--     name varchar(100), 
--     id int IDENTITY(1, 1) primary key,
--     country_code varchar(10),
--     foreign key (country_code) references Country(code),
--     populatian bigint
-- )

-- create table Resource(
--     name varchar(100),
--     id int identity(1, 1) primary key
-- )

-- create table Property(
--     id int identity(1, 1) primary key,
--     resource_id int,
--     region_id int,
--     quantity int not null default 1
--     foreign key(resource_id) references dbo.Resource(id),
--     foreign key(region_id) references dbo.Region(id)
-- )

-- create table Reglementation(
--     name varchar(100) not null, 
--     text_body text not null,
--     resource_id int,
--     country_code varchar(10),
--     primary key(name, country_code), 
--     foreign key(resource_id) references dbo.Resource(id)
-- )

-- create table Bank(
--     name varchar(100) primary key,
--     residance_country_code varchar(10),
--     foreign key(residance_country_code) references dbo.Country(code)
-- )


-- create table BankAccount(
--     iban varchar(100) not null primary key,
--     balance bigint default 0,
--     bank_name varchar(100),
--     foreign key (bank_name) references dbo.Bank(name)
-- )


-- create table Company(
--     name varchar(100) not null primary key,
--     bankAcc_iban varchar(100),
--     residance_country_code varchar(10),
--     foreign key(residance_country_code) references dbo.Country(code)
-- )

-- create table Product(
--     name varchar(100) not null primary key,
--     company_name varchar(100),
--     price numeric(10, 2)
--     foreign key (company_name) references dbo.Company(name)
-- )


-- create table Client(
--     id int identity(1, 1) primary key,
--     name varchar(100) not null,
--     country_code varchar(10),
--     region_id int,
--     request_product varchar(100),
--     foreign key(request_product) references dbo.Product(name),
--     foreign key (country_code) references dbo.Country(code),
--     foreign key (region_id) references dbo.Region(id)
-- )

select * from Country


alter table dbo.Country
drop column name

alter table dbo.Country
add country_name varchar(100)


insert into dbo.Country(code, country_name)
values ('RO', 'Romania');

insert into dbo.Country
values('GE', 'Germany'), ('USA', 'United states of America'), ('ES', 'Spain'), ('FR', 'France'), ('UK', 'United Kingdom'),('IR', 'Irland')


select * from dbo.Country;select * from dbo.Country;

--Selects useful--
select * from dbo.Bank
union 
select * from dbo.Country;

select * from dbo.Resource;

select * from Region;

select * from BankAccount;

--End of select Queries--

insert into dbo.Bank values('BT', 'RO');
insert into Bank values('RF', 'GE');

insert into dbo.Resource values ('steel'), ('cold'), ('wood'), ('cauciuc'), ('plastic'), ('silver'), ('gold'), ('stone'), ('grains');

insert into Region values('Moldova', 'RO', 100000), ('Transilvania', 'RO', 200000), ('Oltenia', 'RO', 150000), ('Dresden', 'GE', 152345),
('Llyon', 'FR', 123060)


insert into BankAccount values('BT234EUGE2314563765', 0.00, 'BT');
insert into BankAccount values('RF043RON4AG54678234', 0.00, 'RF');


-- Labul 2 --
--foreign key that are violated thus giving back an error --
-- third point --
insert into BankAccount values('BRD4567RONTP5468792', 10.00, 'IRN');
insert into Bank values('BRD', 'AUR');

--fourth point--
--initial form of the db 
select bc.iban from BankAccount bc
where bc.balance > 0.00;

alter table BankAccount
alter column balance decimal(10, 2);

update BankAccount
set balance = 10.00
where bank_name like 'BT' and balance < 10.00;

update BankAccount
set balance = 12.25
where bank_name like 'RF';



update BankAccount
set balance = 0.00
where bank_name like 'BT';


drop table BankAccount;

create table dbo.BankAccount(
    iban varchar(100) not null primary key,
    balance decimal(18, 2) default 0.00,
    bank_name varchar(100),
    foreign key(bank_name) references dbo.Bank(name)
);

insert into Bank values ('DEL', 'RU'), ('NOW', 'RU')

insert into BankAccount values ('ceva', 0.00, 'DEL'), ('altceva', 12.00, 'NOW')

select * from BankAccount;

select * from Region;

--add and delete and change
delete from BankAccount
where balance between 11.00 and 13.00
select * from BankAccount;

update Region
set populatian = 200 
where populatian is not NULL and country_code like 'FR'

delete from BankAccount
where bank_name in ('DEL', 'NOW')

if not exists(select bc.bank_name from BankAccount bc
        where bc.bank_name like 'RF'
)
begin 
    insert into BankAccount values('RF043RON4AG54678234', 12.00, 'RF');
    
end

--inserting a null value into the Region table to test a not null query
insert into Country values ('RU', 'Russian')
insert into Region(name, country_code) values ('bashkortostan', 'RU');
insert into Region(name, country_code) values('Andaluzia', 'ES');

--Return the name of the country that have regions without people 
--Reason: for developing there industry that is dangerous normally for regions with people
-- NUll = 0 population

select c.country_name as country from Country c
where c.code in (select reg.country_code from Region reg
    where reg.populatian is null)


--connecting the region with the resources
select * from Region, Resource

insert into Property values(1, 1, 2), (3, 1, 10), (8,1, 7), (9, 1, 20), (1, 2, 10), (2, 2, 15), (8, 2, 20), (7, 2, 5), (6, 2, 12);

insert into Property values(2, 3, 5), (3, 3, 9), (8, 3, 11), (7, 3, 2), (1, 4, 16),(2, 4, 18),(4, 4, 6),(9, 4, 17),(6, 4, 6),(7, 4, 1);

select * from Property;

--Query for finding all the countries that have regions with precious metals
select res.id from Resource res
where res.name in ('silver', 'gold')
--Indicatie : return the name of the region

select distinct prop.region_id from Property prop
where prop.resource_id in (select res.id from Resource res
where res.name in ('silver', 'gold'))


select distinct reg.country_code as cc from Region reg
where reg.id in (select distinct prop.region_id from Property prop
where prop.resource_id in (select res.id from Resource res
where res.name in ('silver', 'gold')))


select c.country_name as CountryName from Country c
where c.code in (select distinct reg.country_code as cc from Region reg
where reg.id in (select distinct prop.region_id from Property prop
where prop.resource_id in (select res.id from Resource res
where res.name in ('silver', 'gold'))));


--Problem: find the total quantity of the resources of wood in a country
declare @country varchar(100), @resource varchar(100);
set @country = 'Romania'
set @resource = 'wood'
select reg.id from Region reg
where reg.country_code like (select c.code from Country c
where c.country_name like @country);

select c.code from Country c
where c.country_name like @country

use Labor;

--Problem: find the quantity of each region of a country
--Dsiplay the Regions which have the resource
declare @country1 varchar(100)
set @country1 = 'Romania'


--get the country code
select c.code as CountryCode, c.country_name as CountryName, r.name as Region, rs.name as Resource ,p.quantity as Quantity from Country c
inner join Region r on r.country_code = c.code and c.country_name like @country1 
inner join Property p on r.id = p.region_id 
inner join Resource rs on rs.id = p.resource_id


--Problem: return a table with all the region of a country
select c.code as CountryCode, c.country_name as CountryName, r.name as Region from Country c
inner join Region r on r.country_code = c.code and c.country_name like 'Romania'

--filter all the Region of a country that have a specified resource and display also the quantity
declare @resource1 varchar(100)
set @resource1 = 'steel'


select r.name as Region, rs.name as Resource, p.quantity as Quantity 
from (select * from Region r2 where r2.country_code like 'RO') as r
join Property p on p.region_id = r.id
join Resource rs on rs.id = p.resource_id
where rs.name like @resource1


select * from Company;

select * from Product;

select * from Region;

insert into Bank values('BRD', 'RO'), ('BCR', 'RO')

insert into Company values ('School_Around', 'RF043RON4AG54678234', 'RO'), ('Metal_Drill', 'BT213RON45D6537586731', 'RO')

insert into BankAccount values('BT213RON45D6537586731',0.00, 'BT'), ('BRD342RON41R63577234533', 0.00,'BRD');

insert into Client values('Accept_papier', 'RU', 6, 'notebooks'), ('Metal_SRL', 'RO', 1, 'metal_taps');

insert into Product(name, price) values('notebooks', 13.25), ('metal_taps', 121.21), ('plastic_toys', 43.76)

insert into Product(name, price) values('books', 20.15), ('coloring_books', 15.25)

insert into Product(name, price) values('math_books', 21.21), ('metal_swords', 57.12), ('metal_knives', 20.00), ('plastic_knives', 10.00);


--LIKE
update Product 
set company_name = 'School_Around'
where name like '%book%'

update Product 
set company_name = 'Metal_Drill'
where name like 'metal_%'

 


use Labor;

select * from Product;

insert into Region(name, country_code) values ('Hamburg', 'GE')

insert into Property values(3, 8, 21)

delete from Client
where id = 4

insert into Client values ('Kindergarted', 'GE', 4, 'coloring_books');

select * from Product;

--Problem: How many products made from a specific company if there are also clients for it
--in case the company wants to see if there are products unselled on the market
declare @comp varchar(100)
set @comp = 'School_Around'

select c2.name as Company, COUNT(p.name) as Products, COUNT(cl.id) as Clients from Product p
join (select * from Company c where c.name like @comp) as c2 on c2.name = p.company_name
join Client cl on cl.request_product = p.name
group by c2.name;

--Comparison with an OUTER JOIN to see the number of total products on the market 
--to make a comparison between how much it prouduce and how much it sells

select c.name as Company, count(cl.name) as Clients, count(p.name)-1 as Product from Product p 
left join Client cl on cl.request_product = p.name
join Company c on c.name = p.company_name
group by c.name
having c.name like 'School_Around'

--find the most expansive product of a company
select c.name as Company, p.name as Product, p.price as Price from Company c
join Product p on p.company_name = c.name 
where c.name like 'Metal_Drill' and p.price = (
    --Select only the maximal price product 
    select max(p2.price) from Product p2 
    where p2.company_name = 'Metal_Drill'
)

select c.name as Company, p.name as Product, p.price as Price from Company c
join Product p on p.company_name = c.name 
where c.name like 'School_Around' and p.price = (
    --Select only the maximal price product 
    select max(p2.price) from Product p2 
    where p2.company_name = 'School_Around'
)


--The same concept as above only that we are searching for a product that has a client also 
select c.name as Company, p.name as Product, cl.name as Client, cl.country_code as OriginCountry ,p.price as Price from Company c
join Product p on p.company_name = c.name 
join Client cl on cl.request_product = p.name
where c.name like 'School_Around' and p.price >= all (
    --Select only the maximal price product 
    select max(p2.price) from Product p2
    join Client cl2 on cl2.request_product = p2.name 
    group by p2.name, p2.company_name
    having p2.company_name = 'School_Around'
)

--Ordering the products of a company after the price
select * from Product p
where p.company_name = 'Metal_Drill'
order by p.price desc 

--Display the quantity of wood resources of two countries of import (Romania and Germany)
select * from Region reg 
join (select * from Country where code like 'RO') as c on c.code = reg.country_code
join Property p on p.region_id = reg.id
where p.resource_id in (select res.id from Resource res where res.name = 'wood')
UNION
select * from Region reg 
join (select * from Country where code like 'GE') as c on c.code = reg.country_code
join Property p on p.region_id = reg.id
where p.resource_id in (select res.id from Resource res where res.name = 'wood')

--display all the bank account from Banks from different Countries with the balance different from 0
select comp.name as Company, c.country_name as Country, b.name as Bank, bc.iban as Conto, bc.balance as Balance from BankAccount bc 
join Bank b on b.name = bc.bank_name
join Country c on c.code = b.residance_country_code
join Company comp on comp.bankAcc_iban = bc.iban
where b.residance_country_code like 'RO' and bc.balance > 0.00 and comp.name like 'School_Around'
union 
select comp.name as Company, c.country_name as Country, b.name as Bank, bc.iban as Conto, bc.balance as Balance from BankAccount bc 
join Bank b on b.name = bc.bank_name
join Country c on c.code = b.residance_country_code
join Company comp on comp.bankAcc_iban = bc.iban
where b.residance_country_code = 'GE' and bc.balance > 0.00 and comp.name like 'School_Around'

-- get all Resources, but one, with theire quantities in a set of Countries(partners)
-- the country set is made from the non Parteners 
declare @countries table(value varchar(100))
declare @resource2 varchar(100)

insert into @countries values ('Germany'), ('Romania'), ('Russia')
set @resource2 = 'wood'

select c.country_name as Country, r.name as Region, res.name as Resource, p.quantity as Quantity  from Property p 
join (select * from Resource res1 where res1.name not like @resource2) as res on res.id = p.resource_id
join (select * from Region r1 where r1.country_code in 
(select c2.code from Country c2 where c2.country_name  not in ( select * from @countries))) as r on r.id = p.id
join Country c on c.code = r.country_code


--How many different resources has a country by region


select r.name as Region, count(p.id)as NumberOfResources from Region r
join (select * from Country c where c.code = 'RO') as c on c.code = r.country_code
join Property p on p.region_id = r.id
join Resource res on res.id = p.resource_id
group by r.name, c.code


--return only 5 products where the buget is fixed on 10, 20, 30
declare @fixed_bugets table(value numeric(5, 2));  
insert into @fixed_bugets values (10.00), (20.00), (30.00)

select top 5 * from Product 
where price = any (select * from @fixed_bugets)

--get all the unpopulated regions of a country 
select * from Region r 
where r.country_code like 'GE'
except 
select * from Region r 
where  r.populatian is not null and r.country_code like 'GE'


--get all products, but those that are less then 20.00 of a company
select * from Product p 
where p.company_name like 'School_Around' 
EXCEPT
select * from Product p 
where p.price < 20.00 and p.company_name like 'School_Around'



--insert with where--
select * from BankAccount;

insert into BankAccount values('RF0429RON5F357484574412', 0.00, 'RF')


--intersect query
select * from Property;

--Return the accounts that have the balance different 0.00 with the name 'BT'

select * from BankAccount
where balance != 0.00
intersect 
select * from BankAccount
where bank_name like 'BT'

--display the regions from germany with wood
select * from Region r 
join Property p on r.id = p.region_id
join Resource rs on rs.id = p.resource_id
where r.country_code like 'GE'
intersect 
select * from Region r 
join Property p on p.region_id = r.id
join  Resource rs on rs.id = p.resource_id
where rs.name like 'wood'