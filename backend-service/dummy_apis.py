from flask import Flask, jsonify
import sqlite3

app = Flask(__name__)

# Create or connect to the SQLite database
conn = sqlite3.connect('db.sqlite3')
cursor = conn.cursor()

# Create a table to store emails and tasks if it doesn't exist
cursor.execute('''
    CREATE TABLE IF NOT EXISTS tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        task TEXT NOT NULL,
        deadline TEXT NOT NULL
    )
''')

# Sample data to populate the database
sample_data = [
    ('john@example.com', 'Task 1', '2024-05-01'),
    ('john@example.com', 'Task 2', '2024-05-05'),
    ('jane@example.com', 'Task 3', '2024-04-30'),
    ('jane@example.com', 'Task 4', '2024-05-10')
]

# Insert sample data into the database
cursor.executemany('INSERT INTO tasks (email, task, deadline) VALUES (?, ?, ?)', sample_data)
conn.commit()

@app.route('/get_mail')
def get_mail():
    cursor.execute('SELECT DISTINCT email FROM tasks')
    emails = [row[0] for row in cursor.fetchall()]
    return jsonify(emails)

@app.route('/get_tasks/<email>')
def get_tasks(email):
    cursor.execute('SELECT task, deadline FROM tasks WHERE email = ?', (email,))
    tasks = [{'task': row[0], 'deadline': row[1]} for row in cursor.fetchall()]
    return jsonify(tasks)

@app.route('/get_all_info')
def get_all_info():
    cursor.execute('SELECT email, task, deadline FROM tasks')
    all_info = [{'email': row[0], 'task': row[1], 'deadline': row[2]} for row in cursor.fetchall()]
    return jsonify(all_info)

if __name__ == '__main__':
    app.run(debug=True)
  
