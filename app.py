import jsonpickle
from flask import Flask, render_template, json, request, session, redirect, url_for
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
def register_admin():
    if request.method == 'POST':
        first_name = request.form['inputName']
        last_name = request.form['inputLastName']
        email = request.form['inputEmail']
        phone_number = request.form['inputPhoneNumber']
        password = generate_password_hash(request.form['inputPassword'])
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

        cursor.execute(f'select admin_registration("{first_name}", "{last_name}", "{email}", "{phone_number}", "{password}", '
                       f'"{reference_code}");')
        data = cursor.fetchall()
        connection.commit()
        cursor.close()
        connection.close()
        return render_template('error.html', error=data)

    return render_template('signup.html')


@app.route('/validate_login')
def validate_login(message):
    return render_template('error.html', error=message)


@app.route('/display_data')
def display_data():
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
    cursor.execute('SELECT first_name, last_name FROM admins;')
    results = [{first_name: last_name} for (first_name, last_name) in cursor]
    cursor.close()
    connection.close()

    return render_template('error.html', error=results)


if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True, port=5000)
