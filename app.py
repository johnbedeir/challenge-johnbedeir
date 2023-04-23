from flask import Flask, render_template
from flask_mysqldb import MySQL
import os

app = Flask(__name__)

# Get the environment variables or fall back to the current defaults
MYSQL_HOST = os.environ.get('MYSQL_HOST', 'mysqldb')
MYSQL_USER = os.environ.get('MYSQL_USER', 'root')
MYSQL_PASSWORD = os.environ.get('MYSQL_PASSWORD', 'secret')
MYSQL_DB = os.environ.get('MYSQL_DB', 'myapp_db')

# Configure MySQL connection
app.config['MYSQL_HOST'] = MYSQL_HOST
app.config['MYSQL_USER'] = MYSQL_USER
app.config['MYSQL_PASSWORD'] = MYSQL_PASSWORD
app.config['MYSQL_DB'] = MYSQL_DB

mysql = MySQL(app)

@app.route('/')
def index():
    # Fetch items from the database
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM items")
    items = cur.fetchall()
    cur.close()

    return render_template('index.html', items=items)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
