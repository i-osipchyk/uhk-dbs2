# uhk-dbs2
Group project for the subject Database Systems 2

How to run MySQL server and connect to it:
    1. Download and setup Docker and MySQL
    2. Disconnect MySQL server
    3. Go to /backend
    4. Run 'docker-compose build'
    5. Run 'docker-compose up'
    6. Open database management environment(DataGrip preffered) and connect with these credentials:
        - host: localhost
        - port: 3306
        - username: root
        - password: password
    7. To fetch the data use 'localhost:5000'