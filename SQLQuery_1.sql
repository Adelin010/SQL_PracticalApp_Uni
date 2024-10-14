create database Labor;
use Labor;

create table Country(
    code varchar(10) primary key,
    name varchar(100)
)

create table Region(
    name varchar(100), 
    id int IDENTITY(1, 1) primary key,
    country_code varchar(10),
    foreign key (country_code) references Country(code),
    populatian bigint
)

create table Resource(
    name varchar(100),
    id int identity(1, 1) primary key
)

create table Property(
    id int identity(1, 1) primary key,
    resource_id int,
    region_id int,
    quantity int not null default 1
    foreign key(resource_id) references dbo.Resource(id),
    foreign key(region_id) references dbo.Region(id)
)

create table Reglementation(
    name varchar(100) not null, 
    text_body text not null,
    resource_id int,
    country_code varchar(10),
    primary key(name, country_code), 
    foreign key(resource_id) references dbo.Resource(id)
)

create table Bank(
    name varchar(100) primary key,
    residance_country_code varchar(10),
    foreign key(residance_country_code) references dbo.Country(code)
)


create table BankAccount(
    iban varchar(100) not null primary key,
    balance bigint default 0,
    bank_name varchar(100),
    foreign key (bank_name) references dbo.Bank(name)
)


create table Company(
    name varchar(100) not null primary key,
    bankAcc_iban varchar(100),
    residance_country_code varchar(10),
    foreign key(residance_country_code) references dbo.Country(code)
)

create table Product(
    name varchar(100) not null primary key,
    company_name varchar(100),
    price numeric(10, 2)
    foreign key (company_name) references dbo.Company(name)
)


create table Client(
    id int identity(1, 1) primary key,
    name varchar(100) not null,
    country_code varchar(10),
    region_id int,
    request_product varchar(100),
    foreign key(request_product) references dbo.Product(name),
    foreign key (country_code) references dbo.Country(code),
    foreign key (region_id) references dbo.Region(id)
)

select * from Country


alter table dbo.Country
drop column name

alter table dbo.Country
add country_name varchar(100)


insert into dbo.Country(code, country_name)
values ('RO', 'Romania');

insert into dbo.Country
values('GE', 'Germany'), ('USA', 'United states of America'), ('ES', 'Spain'), ('FR', 'France'), ('UK', 'United Kingdom'),('IR', 'Irland')


select * from dbo.Country;