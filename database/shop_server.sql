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
    price float not null,
    order_date date not null,
    delivered boolean not null,
    customer_id int not null,
    address_id int not null,
    admin_id int not null,
    foreign key (customer_id) references customers(customer_id),
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
    size_ varchar(5) not null,
    price float not null,
    brand varchar(20) not null,
    color varchar(10) not null,
    category varchar(10) not null,
    release_year int not null,
    gender varchar(6) not null,
    description_ varchar(500) not null,
    index idx_name (name_),
    index idx_size (size_)
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
    storage_id int,
    quantity int not null,
    foreign key (product_id) references products(product_id),
    foreign key (storage_id) references storages(storage_id)
);

# add initial admin

insert into admins(first_name, last_name, email, phone_number, password_, reference_code)
values ('Initial', 'Admin', 'initial.admin@project.com', '+420776119548', 'password', 'ref111');

# function for finding old address or inserting a new one

create function find_or_insert_address(
  country_ varchar(20),
  city_ varchar(20),
  street_ varchar(30),
  house_number_ varchar(10),
  postal_code_ varchar(10)
) returns int deterministic
begin
  declare address_id_ int;

  # check if address already exists
  select address_id into address_id_ from addresses where country = country_ and city = city_ and street = street_ and house_number = house_number_ and postal_code = postal_code_;

  if address_id_ is null then
    # if address does not exist, insert a new row and get the generated id
    insert into addresses (country, city, street, house_number, postal_code) VALUES (country_, city_, street_, house_number_, postal_code_);
    return LAST_INSERT_ID();
  else
    # if address already exists, return its id
    return address_id_;
  end if;
end;

# function for customer registration

create function customer_registration(
    first_name_ varchar(20),
    last_name_ varchar(20),
    email_ varchar(50),
    phone_number_ varchar(15),
    password__ varchar(1000),
    country_ varchar(20),
    city_ varchar(20),
    street_ varchar(30),
    house_number_ varchar(10),
    postal_code_ varchar(10)
) returns varchar(30) deterministic
begin
    declare email_exists int;
    declare phone_number_exists int;
    # check if customer exists
    select customer_id into email_exists from customers where email = email_;

    # if does not exist
    if email_exists is null then
        select customer_id into phone_number_exists from customers where phone_number = phone_number_;

        # if does not exist
        if phone_number_exists is null then
            # insert address and get its id
            set @result_id = find_or_insert_address(country_, city_, street_, house_number_, postal_code_);
            # create new customer
            insert into customers(first_name, last_name, email, phone_number, password_, address_id)
                values (first_name_, last_name_, email_, phone_number_, password__, @result_id);
            return 'Customer registered';
        else
            return 'Phone number is already in use';
        end if;
    else
        return 'Email already in use';
    end if;
end;

# function for admin registration

create function admin_registration(
    first_name_ varchar(20),
    last_name_ varchar(20),
    email_ varchar(50),
    phone_number_ varchar(15),
    password__ varchar(1000),
    reference_code_ varchar(10)
) returns varchar(30) deterministic
begin
    declare admin_exists int;
    declare reference_code_exists varchar(10);

    # check if admin exists
    select admin_id into admin_exists from admins where email = email_;

    # if does not exists
    if admin_exists is null then
        # check if reference code is valid
        select reference_code into reference_code_exists from admins where reference_code = reference_code_;

        # if valid
        if reference_code_exists is not null then
            # register admin
            insert into admins(first_name, last_name, email, phone_number, password_)
                values (first_name_, last_name_, email_, phone_number_, password__);
            return 'Admin registered';
        else
            return 'Invalid reference code';
        end if;
    else
        return 'Admin already exists';
    end if;
end;