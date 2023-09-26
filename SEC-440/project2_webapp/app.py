from flask import Flask, render_template, request, redirect, url_for, session
import mysql.connector as database
import re, hashlib

app = Flask(__name__)

# Secret key
app.secret_key = '<SET_SECRET_KEY_HERE>'

# Database connection detail
db_config = {
    'host': '10.0.6.10',
    'port': 3306,
    'user': '<INSERT_USERNAME"',
    'password': '<INSERT_PASSWORD',
    'database': 'the_vault'
}

# Intialize MySQL
db_connection = database.connect(**db_config)


@app.route('/', methods=['GET', 'POST'])
def login():
    # Output a message if something goes wrong
    msg = ''
    # Check if "username" and "password" POST requests exist (user submitted form)
    if request.method == 'POST' and 'username' in request.form and 'password' in request.form:
        # Create variables for easy access
        username = request.form['username']
        password = request.form['password']
        # Check if account exists using MySQL
        cursor = db_connection.cursor()
        query = 'SELECT * FROM users WHERE username = %(user)s AND password = %(pass)s'
        query_params = {'user': username, 'pass': password}
        cursor.execute(query,query_params)
        # Fetch one record and return result
        account = cursor.fetchone()
        # If account exists in users table in out database
        if account:
            # Create session data
            session['loggedin'] = True
            session['id'] = account[0]
            session['username'] = account[1]
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