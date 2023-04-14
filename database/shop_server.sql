# create and use database

create database shop;
use shop;

# create tables

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
    password_ varchar(1000) not null,
    address_id int,
    foreign key (address_id) references addresses(address_id)
);

create table admins(
    admin_id int auto_increment primary key,
    first_name varchar(20) not null,
    last_name varchar(20) not null,
    email varchar(50) not null,
    phone_number varchar(15) not null,
    password_ varchar(1000) not null,
    reference_code varchar(10)
);

create table orders_(
    order_id int auto_increment primary key,
    price float default 0,
    order_date date,
    delivered boolean not null default false,
    customer_id int not null,
    address_id int not null,
    foreign key (customer_id) references customers(customer_id),
    foreign key (address_id) references addresses(address_id)
);

create table storages(
    storage_id int auto_increment primary key,
    country varchar(20) not null,
    city varchar(20) not null
);

create table products(
    product_id int auto_increment primary key,
    name_ varchar(20) not null,
    price float not null,
    brand varchar(20) not null,
    color_1 varchar(10) not null,
    color_2 varchar(10),
    color_3 varchar(10),
    category varchar(10) not null,
    release_year int not null,
    gender varchar(6) not null,
    description_ varchar(500) not null,
    index idx_name (name_)
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
    product_id int primary key,
    size float,
    storage_id int,
    quantity int not null,
    foreign key (product_id) references products(product_id),
    foreign key (storage_id) references storages(storage_id)
);

# add initial admin

insert into admins(first_name, last_name, email, phone_number, password_, reference_code)
values ('Initial', 'Admin', 'initial.admin@project.com', '+420776119548', 'password', 'ref111');
