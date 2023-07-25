import jsonpickle
from flask import Flask, render_template, json, request, session, redirect, url_for
from flask_mysqldb import MySQL
from werkzeug.security import generate_password_hash, check_password_hash
import mysql.connector

# was not used:
    # mysql = MySQL()

# was not used:
    # # MySQL configurations
    # app.config['MYSQL_USER'] = 'root'
    # app.config['MYSQL_PASSWORD'] = 'password'
    # app.config['MYSQL_DB'] = 'shop'
    # app.config['MYSQL_HOST'] = 'localhost'
    # app.config['MYSQL_PORT'] = 3306
    # # app.config['MYSQL_AUTH_PLUGIN'] = '3306'
    # # app.config['MYSQL_UNIX_SOCKET'] = '/var/run/mysqld/mysqld.sock'
    # mysql.init_app(app)
    #
    # app.secret_key = '228'



# inside route function:

    # connection = mysql.connector.connect(
    #     user='root',
    #     password='password',
    #     host='database',
    #     port='3306',
    #     database='shop',
    #     auth_plugin='mysql_native_password'
    # )
    # cursor = connection.cursor()

    # cursor.execute(f'select admin_registration("{first_name}", "{last_name}", "{email}", "{phone_number}", "{password}", '
    #                f'"{reference_code}");')
    # data = cursor.fetchall()
    # connection.commit()
    # cursor.close()
    # connection.close()


# inside route function:

    # was not used:

        # config = {
        #     'user': 'root',
        #     'password': 'password',
        #     'host': 'localhost',
        #     'port': '3306',
        #     'database': 'shop',
        #     'auth_plugin': 'mysql_native_password'
        # }

    # was used:

        # connection = mysql.connector.connect(
        #     user='root',
        #     password='password',
        #     host='database',
        #     port='3306',
        #     database='shop',
        #     auth_plugin='mysql_native_password'
        # )

        # cursor = connection.cursor()
        # cursor.execute('SELECT first_name, last_name FROM admins;')
        # results = [{first_name: last_name} for (first_name, last_name) in cursor]
        # cursor.close()
        # connection.close()