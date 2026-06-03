from flask import Blueprint, render_template, request, flash, redirect, url_for, session, g
from db import get_db_connection
from functools import wraps

user_bp = Blueprint('user', __name__)

def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            flash("Please log in first.", "warning")
            return redirect(url_for('auth.login'))
        return f(*args, **kwargs)
    return decorated_function

@user_bp.route('/dashboard')
@login_required
def dashboard():
    conn = get_db_connection()
    bookings = []
    if conn:
        cursor = conn.cursor(dictionary=True)
        cursor.execute('''
            SELECT b.*, e.title, e.event_date, e.event_time, e.location
            FROM bookings b
            JOIN events e ON b.event_id = e.id
            WHERE b.user_id = %s
            ORDER BY b.booking_date DESC
        ''', (session['user_id'],))
        bookings = cursor.fetchall()
        cursor.close()
        conn.close()

    return render_template('user/dashboard.html', bookings=bookings)

@user_bp.route('/book/<int:event_id>', methods=['POST'])
@login_required
def book_event(event_id):
    conn = get_db_connection()
    if conn:
        try:
            cursor = conn.cursor(dictionary=True)
            # Check availability
            cursor.execute("SELECT available_seats FROM events WHERE id = %s", (event_id,))
            event = cursor.fetchone()
            
            if event and event['available_seats'] > 0:
                # Check if already booked
                cursor.execute("SELECT id FROM bookings WHERE user_id = %s AND event_id = %s AND status = 'booked'", 
                               (session['user_id'], event_id))
                existing_booking = cursor.fetchone()

                if existing_booking:
                    flash("You have already booked this event.", "warning")
                else:
                    # Proceed with booking
                    cursor.execute("INSERT INTO bookings (user_id, event_id) VALUES (%s, %s)", 
                                   (session['user_id'], event_id))
                    # Decrease available seats
                    cursor.execute("UPDATE events SET available_seats = available_seats - 1 WHERE id = %s", (event_id,))
                    conn.commit()
                    flash("Event booked successfully!", "success")
            else:
                flash("Sorry, no seats available for this event.", "danger")
            cursor.close()
        except Exception as e:
            conn.rollback()
            flash(f"An error occurred: {e}", "danger")
        finally:
            conn.close()

    return redirect(url_for('events.detail', event_id=event_id))

@user_bp.route('/cancel_booking/<int:booking_id>', methods=['POST'])
@login_required
def cancel_booking(booking_id):
    conn = get_db_connection()
    if conn:
        try:
            cursor = conn.cursor(dictionary=True)
            # Ensure the booking belongs to the user and is currently booked
            cursor.execute("SELECT event_id FROM bookings WHERE id = %s AND user_id = %s AND status = 'booked'", 
                           (booking_id, session['user_id']))
            booking = cursor.fetchone()

            if booking:
                # Update booking status
                cursor.execute("UPDATE bookings SET status = 'cancelled' WHERE id = %s", (booking_id,))
                # Increase available seats
                cursor.execute("UPDATE events SET available_seats = available_seats + 1 WHERE id = %s", (booking['event_id'],))
                conn.commit()
                flash("Booking cancelled successfully.", "info")
            else:
                flash("Invalid booking or already cancelled.", "warning")
            cursor.close()
        except Exception as e:
            conn.rollback()
            flash(f"An error occurred: {e}", "danger")
        finally:
            conn.close()

    return redirect(url_for('user.dashboard'))

@user_bp.route('/feedback/<int:event_id>', methods=['POST'])
@login_required
def submit_feedback(event_id):
    rating = request.form.get('rating')
    comment = request.form.get('comment')
    
    conn = get_db_connection()
    if conn:
        try:
            cursor = conn.cursor()
            cursor.execute("INSERT INTO feedback (user_id, event_id, rating, comment) VALUES (%s, %s, %s, %s)",
                           (session['user_id'], event_id, rating, comment))
            conn.commit()
            flash("Thank you for your feedback!", "success")
            cursor.close()
        except Exception as e:
            conn.rollback()
            flash(f"Could not submit feedback: {e}", "danger")
        finally:
            conn.close()

    return redirect(url_for('events.detail', event_id=event_id))
