-- create and use database

create database shop;
use shop;

-- create tables

create table addresses(
    address_id int auto_increment primary key,
    country varchar(20) not null,
    city varchar(20) not null,
    street varchar(30) not null,
    house_number varchar(10),
    postal_code varchar(10) not null
);

create table customers(
    customer_id int auto_increment primary key,
    first_name varchar(20) not null,
    last_name varchar(20) not null,
    email varchar(50) not null,
    phone_number varchar(15),
    password_ varchar(100) not null,
    address_id int,
    foreign key (address_id) references addresses(address_id)
);

create table admins(
    admin_id int auto_increment primary key,
    first_name varchar(20) not null,
    last_name varchar(20) not null,
    email varchar(50) not null,
    phone_number varchar(15) not null,
    password_ varchar(100) not null,
    reference_code varchar(10)
);

create table orders_(
    order_id int auto_increment primary key,
    price float not null,
    order_date date not null,
    delivered boolean not null,
    address_id int not null,
    admin_id int not null,
    foreign key (address_id) references addresses(address_id),
    foreign key (admin_id) references admins(admin_id)
);

create table storages(
    storage_id int auto_increment primary key,
    country varchar(20) not null,
    city varchar(20) not null
);

create table products(
    product_id int auto_increment primary key,
    name_ varchar(20) not null,
    size varchar(5) not null,
    price float not null,
    brand varchar(20) not null,
    color varchar(10) not null,
    category varchar(10) not null,
    release_year int not null,
    gender varchar(6) not null,
    description_ varchar(500) not null,
    index idx_name (name_),
    index idx_size (size)
);

create table images(
    image_id int auto_increment primary key,
    image_ varbinary(8000) not null,
    product_id int not null,
    image_number int not null,
    foreign key (product_id) references products(product_id)
);

create table order_items(
    order_item_id int auto_increment primary key,
    price float not null,
    quantity int not null,
    order_id int,
    product_id int,
    foreign key (order_id) references orders_(order_id),
    foreign key (product_id) references products(product_id)
);

create table products_storages(
    name_ varchar(20) primary key,
    size varchar(5) not null,
    storage_id int,
    quantity int not null,
    foreign key (name_) references products(name_),
    foreign key (size) references products(size),
    foreign key (storage_id) references storages(storage_id)
);

-- add initial admin

insert into admins(first_name, last_name, email, phone_number, password_, reference_code)
values ('Initial', 'Admin', 'initial.admin@project.com', '+420776119548', 'password', 'ref111');

create database test;
use test;

create table user_(
    user_id int primary key,
    first_name varchar(20) not null,
    last_name varchar(20) not null,
    email varchar(50) not null,
    phone varchar(20) not null,
    country varchar(20) not null,
    city varchar(20) not null,
    street varchar(20) not null,
    house_number int not null,
    postal_code varchar(10) not null,
    password_ varchar(20) not null,
    admin_code int not null
);

create procedure store_data
    (first_name_ varchar(20), last_name_ varchar(20), email_ varchar(50),
    phone_ varchar(20), country_ varchar(20),
    city_ varchar(20), street_ varchar(20),
    house_number_ varchar(20), postal_code_ varchar(10),
    password__ varchar(20), admin_code_ varchar(20))
begin
    if ( select exists(select 1 from user_ where email = email_)) then
        select 'User exists!';
    else
        insert into user_
        (
            first_name, last_name, email, phone, country, city, street, house_number, postal_code, password_, admin_code
        )
        values
        (
            first_name_, last_name_, email_, phone_, country_, city_, street_, house_number_, postal_code_, password__, admin_code_
        );
    end if;
end;