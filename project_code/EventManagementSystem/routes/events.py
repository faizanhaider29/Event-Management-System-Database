from flask import Blueprint, render_template, request, flash, redirect, url_for, session
from db import get_db_connection

events_bp = Blueprint('events', __name__)

@events_bp.route('/')
def list_events():
    conn = get_db_connection()
    events = []
    categories = []
    if conn:
        cursor = conn.cursor(dictionary=True)
        # Fetch categories for filtering
        cursor.execute("SELECT * FROM categories")
        categories = cursor.fetchall()

        # Handle search and filter
        search = request.args.get('search', '')
        category = request.args.get('category', '')

        query = "SELECT e.*, c.name as category_name FROM events e LEFT JOIN categories c ON e.category_id = c.id WHERE e.status != 'cancelled'"
        params = []

        if search:
            query += " AND (e.title LIKE %s OR e.description LIKE %s)"
            params.extend([f"%{search}%", f"%{search}%"])
        if category:
            query += " AND e.category_id = %s"
            params.append(category)

        query += " ORDER BY e.event_date ASC"
        
        cursor.execute(query, tuple(params))
        events = cursor.fetchall()
        cursor.close()
        conn.close()

    return render_template('events/list.html', events=events, categories=categories)

@events_bp.route('/<int:event_id>')
def detail(event_id):
    conn = get_db_connection()
    event = None
    feedback = []
    if conn:
        cursor = conn.cursor(dictionary=True)
        # Fetch event details
        cursor.execute('''
            SELECT e.*, c.name as category_name, o.company_name as organizer_name
            FROM events e 
            LEFT JOIN categories c ON e.category_id = c.id
            LEFT JOIN organizers o ON e.organizer_id = o.id
            WHERE e.id = %s
        ''', (event_id,))
        event = cursor.fetchone()

        if event:
            # Fetch feedback
            cursor.execute('''
                SELECT f.*, u.name as user_name 
                FROM feedback f 
                JOIN users u ON f.user_id = u.id 
                WHERE f.event_id = %s
                ORDER BY f.created_at DESC
            ''', (event_id,))
            feedback = cursor.fetchall()
            
        cursor.close()
        conn.close()

    user_booking = None
    if event and 'user_id' in session:
        conn = get_db_connection()
        if conn:
            cursor = conn.cursor(dictionary=True)
            cursor.execute("SELECT id, status FROM bookings WHERE user_id = %s AND event_id = %s AND status = 'booked'", (session['user_id'], event_id))
            user_booking = cursor.fetchone()
            cursor.close()
            conn.close()

    if not event:
        flash("Event not found.", "warning")
        return redirect(url_for('events.list_events'))

    return render_template('events/detail.html', event=event, feedback=feedback, user_booking=user_booking)
