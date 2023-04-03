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


# def test_connection():  # put application's code here
#     config = {
#         'user': 'root',
#         'password': 'password',
#         'host': 'localhost',
#         'port': '3306',
#         'database': 'shop',
#         'auth_plugin': 'mysql_native_password'
#     }
#
#     connection = mysql.connector.connect(
#         user='root',
#         password='password',
#         host='database',
#         port='3306',
#         database='shop',
#         auth_plugin='mysql_native_password'
#     )
#
#     cursor = connection.cursor()
#     cursor.execute('SELECT first_name, last_name FROM admins')
#     results = [{first_name: last_name} for (first_name, last_name) in cursor]
#     cursor.close()
#     connection.close()
#
#     return jsonpickle.encode(results)

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
    try:
        _name = request.form['inputName']
        _email = request.form['inputEmail']
        _password = request.form['inputPassword']

        # validate the received values
        if _name and _email and _password:

            # All Good, let's call MySQL

            conn = mysql.connect()
            cursor = conn.cursor()
            _hashed_password = generate_password_hash(_password)
            cursor.callproc('sp_createUser', (_name, _email, _hashed_password))
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
