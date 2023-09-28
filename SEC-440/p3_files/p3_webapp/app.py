from flask import Flask, render_template, request, redirect, url_for, session
import mysql.connector as database
from socket import gethostname
import re, hashlib

app = Flask(__name__)

# Secret key
app.secret_key = 'SALT'

# Database connection detail
db_config = {
    'host': '10.0.6.10',
    'port': 3306,
    'user': 'USERNAME',
    'password': 'PASSWORD',
    'database': 'the_vault'
}

@app.route('/', methods=['GET', 'POST'])
def login():
    # Output a message if something goes wrong
    msg = ''
    host = gethostname()
    # Check if "username" and "password" POST requests exist (user submitted form)
    if request.method == 'POST' and 'username' in request.form and 'password' in request.form:
        # Create variables for easy access
        username = request.form['username']
        password = request.form['password']
        # Get the password hash
        password_hash = password+app.secret_key
        password_hashed = hashlib.sha3_512(password_hash.encode())
        final_password = password_hashed.hexdigest()
        # Intialize MySQL
        db_connection = database.connect(**db_config)
        # Check if account exists using MySQL
        cursor = db_connection.cursor()
        cursor.execute('SELECT id,username FROM users WHERE username = %(user)s AND password = %(pass)s', {'user': username, 'pass': final_password})
        # Fetch one record and return result
        account = cursor.fetchone()
        # If account exists in users table in out database
        if account:
            # Create session data
            session['loggedin'] = True
            session['id'] = account[0]
            session['username'] = account[1]
            # Redirect to home page
            return f"Logged in {account[0]}:'{username}' successfully!"
        else:
            # Account doesnt exist or username/password incorrect
            msg = 'Incorrect username/password!'
    # Show the login form with message (if any)
    return render_template('index.html', msg=msg, host=host)

@app.route('/register', methods=['GET', 'POST'])
def register():
    msg = ''
    if request.method == 'POST' and 'username' in request.form and 'password' in request.form:
        # Create variables for easy access
        username = request.form['username']
        password = request.form['password']

        # Intialize MySQL
        db_connection = database.connect(**db_config)
        # Connect to database, see if account name already exists
        cursor = db_connection.cursor()
        cursor.execute("SELECT username FROM users WHERE username = %(user)s AND password = %(pass)s", {'user': username, 'pass': password})
        account = cursor.fetchone()

        if account:
            msg = 'Your account already exists!'
        elif not re.match(r'[A-Za-z0-9]',username):
           msg = 'Username must only be characters and numbers!' 
        elif not username or not password:
           msg = "Missing data from the forum: please fill it out!"
        else:
            password_hash = password+app.secret_key
            password_hashed = hashlib.sha3_512(password_hash.encode())
            final_password = password_hashed.hexdigest()

            cursor.execute("INSERT INTO users VALUES (NULL, %(user)s, %(hashpass)s)",{'user': username, 'hashpass': final_password})
            db_connection.commit()
            msg = 'Successfully registered!' 
    elif request.method == 'POST':
        msg = "Missing data from the forum: please fill it out!"
    return render_template('register.html', msg=msg)
"""
Credits:
https://codeshack.io/login-system-python-flask-mysql/
https://hackernoon.com/getting-started-with-mariadb-using-docker-python-and-flask-pa1i3ya3
https://testdriven.io/blog/flask-sessions/
https://www.w3schools.com/python/gloss_python_function_arbitrary_keyword_arguments.asp
"""
