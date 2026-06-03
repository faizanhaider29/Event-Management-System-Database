from flask import Flask, render_template, session, redirect, url_for, g
import os
from db import init_db
from seed import seed_database

app = Flask(__name__)
app.secret_key = 'super_secret_key_for_event_management'

# Initialize database on startup
with app.app_context():
    init_db()
    seed_database()

# Import blueprints (to be created)
from routes.auth import auth_bp
from routes.events import events_bp
from routes.user import user_bp
from routes.admin import admin_bp

# Register blueprints
app.register_blueprint(auth_bp, url_prefix='/auth')
app.register_blueprint(events_bp, url_prefix='/events')
app.register_blueprint(user_bp, url_prefix='/user')
app.register_blueprint(admin_bp, url_prefix='/admin')

@app.before_request
def load_logged_in_user():
    g.user_id = session.get('user_id')
    g.user_name = session.get('user_name')
    g.user_role = session.get('user_role')

@app.route('/')
def index():
    # Fetch upcoming events for home page
    from db import get_db_connection
    conn = get_db_connection()
    events = []
    if conn:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT e.*, c.name as category_name FROM events e LEFT JOIN categories c ON e.category_id = c.id WHERE e.status = 'upcoming' ORDER BY e.event_date ASC LIMIT 6")
        events = cursor.fetchall()
        cursor.close()
        conn.close()
    return render_template('index.html', events=events)

if __name__ == '__main__':
    app.run(debug=True, port=5000)
