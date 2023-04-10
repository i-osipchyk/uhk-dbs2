import jsonpickle
from flask import Flask, render_template, json, request, session, redirect
from flask_mysqldb import MySQL
from werkzeug.security import generate_password_hash, check_password_hash
import mysql.connector

mysql = MySQL()
app = Flask(__name__)

# MySQL configurations
app.config['MYSQL_DATABASE_USER'] = 'root'
app.config['MYSQL_DATABASE_PASSWORD'] = 'password'
app.config['MYSQL_DATABASE_DB'] = 'test'
app.config['MYSQL_DATABASE_HOST'] = 'localhost'
app.config['MYSQL_DATABASE_PORT'] = '3306'
app.config['MYSQL_DATABASE_AUTH_PLUGIN'] = '3306'
mysql.init_app(app)

app.secret_key = '228'


@app.route('/')
def show_sign_up():
    try:
        first_name = request.form['inputName']
        last_name = request.form['inputLastName']
        email = request.form['inputEmail']
        phone = request.form['inputPhoneNumber']
        country = request.form['inputCountry']
        city = request.form['inputCity']
        street = request.form['inputStreet']
        house_number = request.form['inputHouseNumber']
        postal_code = request.form['inputPostalCode']
        password = generate_password_hash(request.form['inputPassword'])
        admin_code = request.form['inputAdminCode']

        connection = mysql.connect()
        cursor = connection.cursor()
        cursor.callproc('store_data', (first_name, last_name, email, phone, country, city, street, house_number,
                                       postal_code, password, admin_code))
    except Exception as e:
        return render_template('error.html', error=e)

    return render_template('signup.html')


if __name__ == '__main__':
    app.run(host='0.0.0.0')
