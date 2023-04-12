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

use shop;

-- procedure for finding old address or inserting a new one

create procedure find_or_insert_address(
  in country_ varchar(20),
  in city_ varchar(20),
  in street_ varchar(30),
  in house_number_ varchar(10),
  in postal_code_ varchar(10),
  out result_id int
)
begin
  declare address_id_ int;

  -- check if address already exists
  select address_id into address_id_ from addresses where country = country_ and city = city_ and street = street_ and house_number = house_number_ and postal_code = postal_code_;

  if address_id_ is null then
    -- if address does not exist, insert a new row and get the generated id
    insert into addresses (country, city, street, house_number, postal_code) VALUES (country_, city_, street_, house_number_, postal_code_);
    set result_id = LAST_INSERT_ID();
  else
    -- if address already exists, return its id
    set result_id = address_id_;
  end if;
end;

-- procedure for customer registration

create procedure customer_registration(
    in first_name_ varchar(20),
    in last_name_ varchar(20),
    in email_ varchar(50),
    in phone_number_ varchar(15),
    in password__ varchar(1000),
    in country_ varchar(20),
    in city_ varchar(20),
    in street_ varchar(30),
    in house_number_ varchar(10),
    in postal_code_ varchar(10),
    out customer_registered int
)
begin
    declare customer_exists int;
    -- check if customer exists
    select customer_id into customer_exists from customers where email = email_;

    -- if does not exist
    if customer_exists is null then
        -- insert address and get its id
        call find_or_insert_address(country_, city_, street_, house_number_, postal_code_);
        select @result_id;
        -- create new customer
        insert into customers(first_name, last_name, email, phone_number, password_, address_id)
            values ( first_name_, last_name_, email_, phone_number_, password__, @result_id);
        set customer_registered = 1;
    else
        set customer_exists = 0;
    end if;
end;

-- procedure for admin registration

create procedure admin_registration(
    in first_name_ varchar(20),
    in last_name_ varchar(20),
    in email_ varchar(50),
    in phone_number_ varchar(15),
    in password__ varchar(100),
    in reference_code_ varchar(10),
    out admin_registered varchar(30)
)
begin
    declare admin_exists int;
    declare reference_code_exists varchar(10);

    -- check if admin exists
    select admin_id into admin_exists from admins where email = email_;

    -- if does not exists
    if admin_exists is null then
        -- check if reference code is valid
        select reference_code into reference_code_exists from admins where reference_code = reference_code_;

        -- if valid
        if reference_code_exists is not null then
            -- register admin
            insert into admins(first_name, last_name, email, phone_number, password_)
                values (first_name_, last_name_, email_, phone_number_, password__);
            set admin_registered = 'Admin registered';
        else
            set admin_registered = 'Invalid reference code';
        end if;
    else
        set admin_registered = 'Admin already exists';
    end if;
end;