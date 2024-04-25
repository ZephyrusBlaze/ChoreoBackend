from flask import Flask, jsonify, g
import sqlite3

app = Flask(__name__)

# Function to connect to the database
def get_db():
    if 'db' not in g:
        g.db = sqlite3.connect('db.sqlite3')
        g.db.row_factory = sqlite3.Row
    return g.db

# Function to close the database connection
def close_db(e=None):
    db = g.pop('db', None)
    if db is not None:
        db.close()

# Create or connect to the SQLite database
with app.app_context():
    db = get_db()
    cursor = db.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL,
            task TEXT NOT NULL,
            deadline TEXT NOT NULL
        )
    ''')
    db.commit()

# Sample data to populate the database
sample_data = [
    ('john@example.com', 'Task 1', '2024-05-01'),
    ('john@example.com', 'Task 2', '2024-05-05'),
    ('jane@example.com', 'Task 3', '2024-04-30'),
    ('jane@example.com', 'Task 4', '2024-05-10')
]

# Insert sample data into the database
with app.app_context():
    db = get_db()
    cursor = db.cursor()
    cursor.executemany('INSERT INTO tasks (email, task, deadline) VALUES (?, ?, ?)', sample_data)
    db.commit()

@app.route('/get_mail')
def get_mail():
    db = get_db()
    cursor = db.cursor()
    cursor.execute('SELECT DISTINCT email FROM tasks')
    emails = [row[0] for row in cursor.fetchall()]
    return jsonify(emails)

@app.route('/get_tasks/<email>')
def get_tasks(email):
    db = get_db()
    cursor = db.cursor()
    cursor.execute('SELECT task, deadline FROM tasks WHERE email = ?', (email,))
    tasks = [{'task': row[0], 'deadline': row[1]} for row in cursor.fetchall()]
    return jsonify(tasks)

@app.route('/get_all_info')
def get_all_info():
    db = get_db()
    cursor = db.cursor()
    cursor.execute('SELECT email, task, deadline FROM tasks')
    all_info = [{'email': row[0], 'task': row[1], 'deadline': row[2]} for row in cursor.fetchall()]
    return jsonify(all_info)

# Register close_db to run when the app context is popped
app.teardown_appcontext(close_db)

if __name__ == '__main__':
    app.run()
