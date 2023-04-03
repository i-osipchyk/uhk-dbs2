import jsonpickle
from flask import Flask
import mysql.connector

app = Flask(__name__)


@app.route('/')
def test_connection():  # put application's code here
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

    return jsonpickle.encode(results)




if __name__ == '__main__':
    app.run(host='0.0.0.0')