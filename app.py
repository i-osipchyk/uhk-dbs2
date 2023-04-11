import jsonpickle
from flask import Flask, render_template, json, request, session, redirect
from flask_mysqldb import MySQL
from werkzeug.security import generate_password_hash, check_password_hash
import mysql.connector

# mysql = MySQL()
app = Flask(__name__)

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


@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':

        first_name = request.form['inputName']
        last_name = request.form['inputLastName']
        email = request.form['inputEmail']
        phone_number = request.form['inputPhoneNumber']
        password = request.form['inputPassword']
        reference_code = request.form['inputAdminCode']

        connection = mysql.connector.connect(
            user='root',
            password='password',
            host='database',
            port='3306',
            database='shop',
            auth_plugin='mysql_native_password'
        )
        cursor = connection.cursor()

        cursor.execute(f'INSERT INTO admins(first_name, last_name, email, phone_number, password_, reference_code) VALUES ("{first_name}", "{last_name}", "{email}", "{phone_number}", "{password}", "{reference_code}");')
        connection.commit()
        cursor.close()
        connection.close()
    return render_template('signup.html')


@app.route('/data')
def display():
    config = {
        'user': 'root',
        'password': 'password',
        'host': 'localhost',
        'port': '3306',
        'database': 'shop',
        'auth_plugin': 'mysql_native_password'
    }
    connection = mysql.connector.connect(
            user='root',
            password='password',
            host='database',
            port='3306',
            database='shop',
            auth_plugin='mysql_native_password'
        )

    cursor = connection.cursor()
    cursor.execute('SELECT first_name, last_name FROM admins')
    results = [{first_name: last_name} for (first_name, last_name) in cursor]
    cursor.close()
    connection.close()

    return render_template('error.html', error=results)


if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
