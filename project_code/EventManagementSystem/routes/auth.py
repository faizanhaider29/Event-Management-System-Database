from flask import Blueprint, render_template, request, redirect, url_for, flash, session, g
from werkzeug.security import generate_password_hash, check_password_hash
from db import get_db_connection

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        name = request.form.get('name')
        email = request.form.get('email')
        password = request.form.get('password')
        role = request.form.get('role', 'user') # default to user if not provided

        conn = get_db_connection()
        if not conn:
            flash("Database error.", "danger")
            return redirect(url_for('auth.register'))

        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT id FROM users WHERE email = %s", (email,))
        existing_user = cursor.fetchone()

        if existing_user:
            flash("Email address already exists", "warning")
            cursor.close()
            conn.close()
            return redirect(url_for('auth.register'))

        hashed_pwd = generate_password_hash(password, method='pbkdf2:sha256')
        try:
            cursor.execute("INSERT INTO users (name, email, password_hash, role) VALUES (%s, %s, %s, %s)",
                           (name, email, hashed_pwd, role))
            conn.commit()
            
            # If the user registers as an organizer, we also add them to the organizers table
            if role == 'organizer':
                user_id = cursor.lastrowid
                company_name = request.form.get('company_name', '')
                contact_info = request.form.get('contact_info', '')
                cursor.execute("INSERT INTO organizers (user_id, company_name, contact_info) VALUES (%s, %s, %s)",
                               (user_id, company_name, contact_info))
                conn.commit()

            flash("Registration successful. Please login.", "success")
            cursor.close()
            conn.close()
            return redirect(url_for('auth.login'))
        except Exception as e:
            conn.rollback()
            flash(f"Error: {e}", "danger")
            cursor.close()
            conn.close()
            return redirect(url_for('auth.register'))

    return render_template('auth/register.html')

@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form.get('email')
        password = request.form.get('password')

        conn = get_db_connection()
        if not conn:
            flash("Database error.", "danger")
            return redirect(url_for('auth.login'))
            
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
        user = cursor.fetchone()
        cursor.close()
        conn.close()

        if user and check_password_hash(user['password_hash'], password):
            session['user_id'] = user['id']
            session['user_name'] = user['name']
            session['user_role'] = user['role']
            flash(f"Welcome back, {user['name']}!", "success")
            return redirect(url_for('index'))
        else:
            flash("Invalid email or password", "danger")
            return redirect(url_for('auth.login'))

    return render_template('auth/login.html')

@auth_bp.route('/logout')
def logout():
    session.clear()
    flash("You have been logged out.", "info")
    return redirect(url_for('index'))
