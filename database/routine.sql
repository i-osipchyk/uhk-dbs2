use shop;

##### CONFIGURATIONS #####

SET GLOBAL log_bin_trust_function_creators = 1;

##### FUNCTIONS #####

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

create function add_new_product(
    name__ varchar(20),
    price_ float,
    brand_ varchar(20),
    color_1_ varchar(10),
    color_2_ varchar(10),
    color_3_ varchar(10),
    category_ varchar(10),
    release_year_ int,
    gender_ varchar(6),
    description__ varchar(500)
) returns varchar(30) deterministic
begin
    declare existing_product_id int;
    # check if product with given name, colors and gender exists
    select product_id into existing_product_id from products
    where name_ = name__ and
          color_1 = color_1_ and
          color_2 = color_2_ and
          color_3 = color_3_;

    # if product does not exist
    if existing_product_id is null then
        # insert into products
        insert into products(name_, price, brand, color_1, color_2, color_3, category, release_year, gender, description_)
        values (name__, price_, brand_, color_1_, color_2_, color_3_, category_, release_year_, gender_, description__);
        # return the result of the operation
        return 'Product added successfully';
    else
        # return the result of the operation
        return 'Product already exists';
    end if;
end;

# function for adding new storage

create function add_storage(
    country_ varchar(20),
    city_ varchar(20)
) returns varchar(30) deterministic
begin
    # insert into storages
    insert into storages(country, city) values (country_, city_);
    # return the result of the operation
    return 'Storage added successfully';
end;

# create function for adding products to storage

create function add_product_to_storage(
    name__ varchar(20),
    color_1_ varchar(10),
    color_2_ varchar(10),
    color_3_ varchar(10),
    gender_ varchar(6),
    size_ float,
    storage_city_ varchar(20),
    quantity_ int
) returns varchar(50) deterministic
begin
    declare product_id_ int;
    declare storage_id_ int;

    # check if product with given name, colors and gender exists in products table
    select product_id into product_id_ from products
    where name_ = name__ and color_1 = color_1_ and color_2 = color_2_ and color_3 = color_3_ and gender = gender_;

    # if does not exist
    if product_id_ is null then
        # return the result of the operation
        return 'There is no such a product';
    else
        # select id of one storage in given city
        select storage_id into storage_id_ from storages
        where city = storage_city_
        limit 1;

        # insert into product_storages
        insert into products_storages
        values (product_id_, size_, storage_id_, quantity_);
        # return the result of the operation
        return concat(name__, ' added to storage in ', storage_city_);
    end if;
end;

# function for creating order

create function add_order(
    customer_id_ int,
    address_id_ int
) returns varchar(50) deterministic
begin
    # insert into orders_
    insert into orders_(customer_id, address_id) values (customer_id_, address_id_);
    # return the result of the operation
    return last_insert_id();
end;

# function for adding product to order_items

create function add_product_to_order_items(
    order_id_ int,
    product_id_ int,
    quantity_ int
) returns varchar(50) deterministic
begin
    declare item_price_ float;
    # set item_price equal to quantity * product.price
    set item_price_ = quantity_ * (select price from products where product_id = product_id_);

    # create order_items
    insert into order_items(price, quantity, order_id, product_id)
    values (item_price_, quantity_, order_id_, product_id_);

    # update order price
    update orders_
    set price = price + item_price_
    where order_id = order_id_;
    # return the result of the operation
    return 'Item successfully added to the order';
end;

# function for updating order_item

create function update_price_and_quantity(
    product_id_ int,
    order_id_ int,
    quantity_ int
) returns varchar(50) deterministic
begin
    # update quantity and price in order_items
    update order_items
    set quantity = quantity + quantity_, price = quantity * (select price from products where product_id = product_id_)
    where product_id = product_id_ and order_id = order_id_;

    # update price in orders_
    update orders_
    set price = price + quantity_ * (select price from products where product_id = product_id_)
    where order_id = order_id_;
    # return the result of the operation
    return 'Order and order_item are updated successfully';
end;

# function for checking the availability of product in the country

create function check_availability(
    product_id_ int,
    address_id_ int,
    quantity_ int
) returns int
begin
    declare country_ varchar(20);
    declare max_quantity int;

    # select the country of the customer
    select country into country_ from addresses
    where address_id = address_id_;

    # set the maximum quantity
    set max_quantity = (
        select max(quantity)
        from products_storages ps
        join storages s ON ps.storage_id = s.storage_id
        where s.country = country_
        and ps.product_id = product_id_
    );

    # if null return false
    if max_quantity is null then
        return 0;
    end if;

    # if less return 1, else return 0
    if quantity_ <= max_quantity then
        return -1;
    else
        return max_quantity;
    end if;
end;

# function for adding product to order

create function add_product_to_order(
    product_id_ int,
    quantity_ int,
    customer_id_ int,
    address_id_ int
) returns varchar(100) deterministic
begin
    declare order_id_ int;
    declare product_in_order int;
    declare in_stock int;

    # check if order exists
    select order_id into order_id_ from orders_
    where customer_id = customer_id_;

    # check if product is available in customer's country
    set in_stock = check_availability(product_id_, address_id_, quantity_);
    if in_stock = 0 then
        return 'Max quantity is null';
    elseif in_stock = -1 then
        # create order if does not exist
    if order_id_ is null then
        # add order and select its id
        set order_id_ = add_order(customer_id_, address_id_);

        # add product to order items
        set @add_product_to_order_return_ = add_product_to_order_items(order_id_, product_id_, quantity_);
        # return the result
        return concat('Item with id ', product_id_, ' is successfully added to the order number ', order_id_);
    else
        # select id of existing order
        select order_id into order_id_ from orders_
        where customer_id = customer_id_;

        # check if item is in order_items
        select product_id into product_in_order from order_items
        where order_id = order_id_ and product_id = product_id_;

        # if product is in order_items
        if product_in_order is not null then
            # update quantity and price
            set @update_order_item_return = update_price_and_quantity(product_id_, order_id_, quantity_);
            # return the result
            return concat('Quantity of product with id ', product_id_, ' is successfully increased for order number ', order_id_);
        else
            # add product to order items
            set @add_product_to_order_return = add_product_to_order_items(order_id_, product_id_, quantity_);
            # return the result
            return concat('Item with id ', product_id_, ' is successfully added to the order number ', order_id_);
        end if;
    end if;
    else
        return concat('There are only ', in_stock, ' items in stock');
    end if;
end;

# function for login

create function customer_login(
    email_ varchar(50),
    password_log varchar(1000)
) returns varchar(100) deterministic
begin
    declare email__ varchar(50);
    declare password_ex varchar(1000);

    select email into email__ from customers where email = email_;

    if email__ is null then
        return 'Account with following email was not found';
    else
        select password_ into password_ex from customers where email = email_;
        if password_ex = password_log then
            return 'Successfully logged in';
        else
            return 'Incorrect password';
        end if;
    end if;
end;

# function for admin login

create function admin_login(
    email_ varchar(50),
    password_log varchar(1000)
) returns varchar(100) deterministic
begin
    declare email__ varchar(50);
    declare password_ex varchar(1000);

    select email into email__ from admins where email = email_;

    if email__ is null then
        return 'Account with following email was not found';
    else
        select password_ into password_ex from admins where email = email_;
        if password_ex = password_log then
            return 'Successfully logged in';
        else
            return 'Incorrect password';
        end if;
    end if;
end;

# function for changing address

create function change_address(
    customer_id_ int,
    country_ varchar(20),
    city_ varchar(20),
    street_ varchar(30),
    house_number_ varchar(10),
    postal_code_ varchar(10)
) returns varchar(100) deterministic
begin
    # get id of the address
    set @result_id = find_or_insert_address(country_, city_, street_, house_number_, postal_code_);

    # update the address in customers table
    update customers
    set address_id = @result_id
    where customer_id = customer_id_;

    return 'Address was changed';
end;

# function for deleting product

create function delete_product(
    product_id_ int
) returns varchar(100) deterministic
begin
    # variable to check if product exists
    declare product_exists int;

    # check if product exists
    select product_id into product_exists from products where product_id = product_id_;

    # if does not exist
    if product_exists is null then
        return 'Product with this id does not exist';
    else
        # delete images of the product
        delete from images
        where product_id = product_id_;

        # delete product
        delete from products
        where product_id = product_id_;

        return 'Product was deleted successfully';
    end if;
end;

##### TESTING CALLS #####

# select customer_registration('Ivan', 'Osipchyk', 'mail@example.com', '+420123456789', 'password', 'Germany', 'Munich', 'Hansastrase', '41', '81373');
#
# select add_new_product('Air Jordan 1', 129.99, 'Nike/Jordan', 'red', 'white', 'black', 'lifestyle', 2022, 'male', 'Return of iconic model');
#
# select add_new_product('Air Force 1', 119.99, 'Nike', 'white', 'white', 'white', 'lifestyle', 2020, 'female', 'Classic model that suits anyone');
#
# select add_storage('Germany', 'Dresden');
#
# select add_product_to_storage('Air Jordan 1', 'red', 'white', 'black', 'male', 10.5, 'Dresden', 100);
#
# select check_availability(1, 1, 100);
#
# select add_product_to_order(2, 1, 1, 1);

