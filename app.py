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
app.config['MYSQL_DATABASE_DB'] = 'shop'
app.config['MYSQL_DATABASE_HOST'] = 'localhost'
app.config['MYSQL_DATABASE_PORT'] = '3306'
app.config['MYSQL_DATABASE_AUTH_PLUGIN'] = '3306'
mysql.init_app(app)

app.secret_key = '228'


@app.route('/')
def main():
    return render_template('index.html')


@app.route('/signup')
def show_sign_up():
    return render_template('signup.html')


@app.route('/signin')
def show_sign_in():
    return render_template('signin.html')


@app.route('/api/validateLogin', methods=['POST'])
def validate_login():
    try:
        _username = request.form['inputEmail']
        _password = request.form['inputPassword']
        connection = mysql.connect()
        cursor = connection.cursor()
        cursor.callproc('sp_validateLogin', (_username,))
        data = cursor.fetchall()
        if len(data) > 0:
            if check_password_hash(str(data[0][3]), _password):
                session['user'] = data[0][0]
                return redirect('/userHome')
            else:
                return render_template('error.html', error='Wrong Email address or Password')
        else:
            return render_template('error.html', error='Wrong Email address or Password')
    except Exception as e:
        return render_template('error.html', error=str(e))


@app.route('/api/signup', methods=['POST'])
def sign_up():
    conn = mysql.connect()
    cursor = conn.cursor()
    try:
        country = request.form['inputCountry']
        city = request.form['inputCity']
        street = request.form['inputStreet']
        house_number = request.form['inputHouseNumber']
        postal_code = request.form['inputPostalCode']

        first_name = request.form['inputFirstName']
        last_name = request.form['inputLastName']
        email = request.form['inputEmail']
        phone_number = request.form['inputPhoneNumber']
        password_ = request.form['inputPassword']

        # validate the received values
        if country and city and street and house_number and postal_code and first_name and last_name and email and phone_number and password_:

            # All Good, let's call MySQL

            _hashed_password = generate_password_hash(password_)

            cursor.callproc('sp_create_customer', (
                country, city, street, house_number, postal_code, first_name, last_name, email, phone_number,
                _hashed_password))
            data = cursor.fetchall()

            if len(data) == 0:
                conn.commit()
                return json.dumps({'message': 'User created successfully !'})
            else:
                return json.dumps({'error': str(data[0])})
        else:
            return json.dumps({'html': '<span>Enter the required fields</span>'})

    except Exception as e:
        return json.dumps({'error': str(e)})
    finally:
        cursor.close()
        conn.close()


@app.route('/userhome')
def user_home():
    if session.get('user'):
        return render_template('userhome.html')
    else:
        return render_template('error.html', error='Unauthorized Access')


@app.route('/logout')
def logout():
    session.pop('user', None)
    return redirect('/')


if __name__ == '__main__':
    app.run(host='0.0.0.0')
