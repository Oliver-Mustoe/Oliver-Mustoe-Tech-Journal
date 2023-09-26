from flask import Flask, render_template, request, redirect, url_for, session
import mariadb
import re, hashlib

app = Flask(__name__)

# Secret key
app.secret_key = '<SET_SECRET_KEY_HERE>'

# Database connection detail
db_config = {
    'host': '127.0.0.1',
    'port': 3306,
    'user': '<INSERT_A_USER>',
    'password': '<INSERT_A_PASSWORD>',
    'database': 'the_vault'
}

# Intialize MySQL
db_connection = mariadb.connect(**db_config)


@app.route('/', methods=['GET', 'POST'])
def login():
    # Check if "username" and "password" POST requests exist (user submitted form)
    if request.method == 'POST' and 'username' in request.form and 'password' in request.form:
        # Create variables for easy access
        username = request.form['username']
        password = request.form['password']
        # Check if account exists using MySQL
        cursor = db_connection.cursor()
        cursor.execute(f'SELECT * FROM users WHERE username = {username} AND password = {password}')
        # Fetch one record and return result
        account = cursor.fetchone()
        # Output a message if something goes wrong
        msg = ''
        # If account exists in users table in out database
        if account:
            # Create session data, we can access this data in other routes
            session['loggedin'] = True
            session['id'] = account['id']
            session['username'] = account['username']
            # Redirect to home page
            return 'Logged in successfully!'
        else:
            # Account doesnt exist or username/password incorrect
            msg = 'Incorrect username/password!'
    # Show the login form with message (if any)
    return render_template('index.html', msg=msg)

"""
Credits:
https://codeshack.io/login-system-python-flask-mysql/
https://hackernoon.com/getting-started-with-mariadb-using-docker-python-and-flask-pa1i3ya3
https://testdriven.io/blog/flask-sessions/
https://www.w3schools.com/python/gloss_python_function_arbitrary_keyword_arguments.asp
"""