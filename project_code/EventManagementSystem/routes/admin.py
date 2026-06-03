from flask import Blueprint, render_template, request, flash, redirect, url_for, session
from db import get_db_connection
from functools import wraps

admin_bp = Blueprint('admin', __name__)

def admin_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session or session.get('user_role') not in ['admin', 'organizer']:
            flash("You do not have permission to access this page.", "danger")
            return redirect(url_for('index'))
        return f(*args, **kwargs)
    return decorated_function

@admin_bp.route('/dashboard')
@admin_required
def dashboard():
    conn = get_db_connection()
    stats = {}
    events = []
    if conn:
        cursor = conn.cursor(dictionary=True)
        # Fetch simple stats
        cursor.execute("SELECT COUNT(*) as total FROM users")
        stats['users'] = cursor.fetchone()['total']
        
        if session.get('user_role') == 'admin':
            cursor.execute("SELECT COUNT(*) as total FROM events")
            stats['events'] = cursor.fetchone()['total']
            
            cursor.execute("SELECT COUNT(*) as total FROM bookings")
            stats['bookings'] = cursor.fetchone()['total']
            
            # Fetch all events
            cursor.execute('''
                SELECT e.*, c.name as category_name, o.company_name 
                FROM events e 
                LEFT JOIN categories c ON e.category_id = c.id
                LEFT JOIN organizers o ON e.organizer_id = o.id
                ORDER BY e.created_at DESC LIMIT 10
            ''')
            events = cursor.fetchall()
        else: # organizer
            # Fetch stats for organizer
            cursor.execute("SELECT id FROM organizers WHERE user_id = %s", (session['user_id'],))
            org = cursor.fetchone()
            if org:
                cursor.execute("SELECT COUNT(*) as total FROM events WHERE organizer_id = %s", (org['id'],))
                stats['events'] = cursor.fetchone()['total']
                
                # Fetch only organizer's events
                cursor.execute('''
                    SELECT e.*, c.name as category_name 
                    FROM events e 
                    LEFT JOIN categories c ON e.category_id = c.id
                    WHERE e.organizer_id = %s
                    ORDER BY e.created_at DESC
                ''', (org['id'],))
                events = cursor.fetchall()
            else:
                stats['events'] = 0

        cursor.close()
        conn.close()

    return render_template('admin/dashboard.html', stats=stats, events=events)


@admin_bp.route('/data')
@admin_required
def data_overview():
    conn = get_db_connection()
    tables = {
        'users': [],
        'categories': [],
        'organizers': [],
        'events': [],
        'bookings': [],
        'feedback': []
    }

    if conn:
        cursor = conn.cursor(dictionary=True)

        cursor.execute('SELECT * FROM users ORDER BY id DESC')
        tables['users'] = cursor.fetchall()

        cursor.execute('SELECT * FROM categories ORDER BY id DESC')
        tables['categories'] = cursor.fetchall()

        cursor.execute('''
            SELECT o.*, u.name as user_name, u.email as user_email
            FROM organizers o
            JOIN users u ON o.user_id = u.id
            ORDER BY o.id DESC
        ''')
        tables['organizers'] = cursor.fetchall()

        cursor.execute('''
            SELECT e.*, c.name as category_name, o.company_name
            FROM events e
            LEFT JOIN categories c ON e.category_id = c.id
            LEFT JOIN organizers o ON e.organizer_id = o.id
            ORDER BY e.created_at DESC
        ''')
        tables['events'] = cursor.fetchall()

        cursor.execute('''
            SELECT b.*, u.name as user_name, e.title as event_title
            FROM bookings b
            JOIN users u ON b.user_id = u.id
            JOIN events e ON b.event_id = e.id
            ORDER BY b.booking_date DESC
        ''')
        tables['bookings'] = cursor.fetchall()

        cursor.execute('''
            SELECT f.*, u.name as user_name, e.title as event_title
            FROM feedback f
            JOIN users u ON f.user_id = u.id
            JOIN events e ON f.event_id = e.id
            ORDER BY f.created_at DESC
        ''')
        tables['feedback'] = cursor.fetchall()

        cursor.close()
        conn.close()

    return render_template('admin/data_overview.html', tables=tables)

@admin_bp.route('/event/create', methods=['GET', 'POST'])
@admin_required
def create_event():
    conn = get_db_connection()
    if request.method == 'POST':
        title = request.form.get('title')
        description = request.form.get('description')
        event_date = request.form.get('event_date')
        event_time = request.form.get('event_time')
        location = request.form.get('location')
        total_seats = int(request.form.get('total_seats'))
        category_id = request.form.get('category_id') or None
        
        if conn:
            try:
                cursor = conn.cursor(dictionary=True)
                
                # Get organizer ID
                organizer_id = None
                if session.get('user_role') == 'organizer':
                    cursor.execute("SELECT id FROM organizers WHERE user_id = %s", (session['user_id'],))
                    org = cursor.fetchone()
                    if org:
                        organizer_id = org['id']
                elif session.get('user_role') == 'admin':
                    organizer_id = request.form.get('organizer_id') or None

                cursor.execute('''
                    INSERT INTO events (title, description, event_date, event_time, location, total_seats, available_seats, category_id, organizer_id)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                ''', (title, description, event_date, event_time, location, total_seats, total_seats, category_id, organizer_id))
                conn.commit()
                flash("Event created successfully!", "success")
                cursor.close()
                return redirect(url_for('admin.dashboard'))
            except Exception as e:
                conn.rollback()
                flash(f"Error creating event: {e}", "danger")
            finally:
                if 'cursor' in locals() and cursor:
                    cursor.close()

    # GET request - fetch categories and organizers for dropdowns
    categories = []
    organizers = []
    if conn:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM categories")
        categories = cursor.fetchall()
        
        if session.get('user_role') == 'admin':
            cursor.execute("SELECT o.*, u.name as user_name FROM organizers o JOIN users u ON o.user_id = u.id")
            organizers = cursor.fetchall()
            
        cursor.close()
        conn.close()

    return render_template('admin/create_event.html', categories=categories, organizers=organizers)
