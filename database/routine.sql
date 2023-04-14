use shop;

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