import os
import csv
from datetime import datetime, timedelta

import mysql.connector
from dotenv import load_dotenv
from werkzeug.security import generate_password_hash

load_dotenv()

db_config = {
    "host": os.getenv("MYSQL_HOST", "localhost"),
    "user": os.getenv("MYSQL_USER", "root"),
    "password": os.getenv("MYSQL_PASSWORD", ""),
    "database": os.getenv("MYSQL_DATABASE", "event_management")
}


def _fetch_one(cursor, query, params=()):
    cursor.execute(query, params)
    rows = cursor.fetchall()
    return rows[0] if rows else None


def _ensure_user(cursor, name, email, password_hash, role):
    row = _fetch_one(cursor, "SELECT id FROM users WHERE email = %s", (email,))
    if row:
        return row[0]

    cursor.execute(
        "INSERT INTO users (name, email, password_hash, role) VALUES (%s, %s, %s, %s)",
        (name, email, password_hash, role)
    )
    return cursor.lastrowid


def _ensure_organizer(cursor, user_id, company_name, contact_info):
    row = _fetch_one(cursor, "SELECT id FROM organizers WHERE user_id = %s", (user_id,))
    if row:
        return row[0]

    cursor.execute(
        "INSERT INTO organizers (user_id, company_name, contact_info) VALUES (%s, %s, %s)",
        (user_id, company_name, contact_info)
    )
    return cursor.lastrowid


def _ensure_category(cursor, name, description):
    row = _fetch_one(cursor, "SELECT id FROM categories WHERE name = %s", (name,))
    if row:
        return row[0]

    cursor.execute(
        "INSERT INTO categories (name, description) VALUES (%s, %s)",
        (name, description)
    )
    return cursor.lastrowid


def _ensure_event(cursor, event):
    row = _fetch_one(cursor, "SELECT id FROM events WHERE title = %s AND event_date = %s", (event["title"], event["event_date"]))
    if row:
        return row[0]

    cursor.execute(
        '''
            INSERT INTO events (
                title, description, event_date, event_time, location,
                total_seats, available_seats, category_id, organizer_id, status
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        ''', (
            event["title"],
            event["description"],
            event["event_date"],
            event["event_time"],
            event["location"],
            event["total_seats"],
            event["available_seats"],
            event["category_id"],
            event["organizer_id"],
            event.get("status", "upcoming")
        )
    )
    return cursor.lastrowid


def _ensure_booking(cursor, user_id, event_id, status="booked"):
    row = _fetch_one(cursor, "SELECT id FROM bookings WHERE user_id = %s AND event_id = %s", (user_id, event_id))
    if row:
        return row[0]

    cursor.execute(
        "INSERT INTO bookings (user_id, event_id, status) VALUES (%s, %s, %s)",
        (user_id, event_id, status)
    )
    return cursor.lastrowid


def _ensure_feedback(cursor, user_id, event_id, rating, comment):
    row = _fetch_one(cursor, "SELECT id FROM feedback WHERE user_id = %s AND event_id = %s", (user_id, event_id))
    if row:
        return row[0]

    cursor.execute(
        "INSERT INTO feedback (user_id, event_id, rating, comment) VALUES (%s, %s, %s, %s)",
        (user_id, event_id, rating, comment)
    )
    return cursor.lastrowid


def seed_database():
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()

        category_ids = {}
        for name, description in [
            ("Education", "Workshops, seminars, and learning sessions"),
            ("Technology", "Tech conferences, hackathons, and meetups"),
            ("Business", "Networking events, business seminars"),
            ("Entertainment", "Concerts, parties, and movies"),
            ("Community", "Local community gatherings and nonprofit events")
        ]:
            category_ids[name] = _ensure_category(cursor, name, description)

        default_password = generate_password_hash("password", method="pbkdf2:sha256")
        demo_users = [
            ("Demo Admin", "admin@example.com", generate_password_hash("admin123", method="pbkdf2:sha256"), "admin"),
            ("Demo Organizer", "organizer@example.com", default_password, "organizer"),
            ("Ava Johnson", "ava@example.com", default_password, "user"),
            ("Noah Smith", "noah@example.com", default_password, "user"),
            ("Mia Patel", "mia@example.com", default_password, "user")
        ]

        user_ids = {}
        for name, email, password_hash, role in demo_users:
            user_ids[email] = _ensure_user(cursor, name, email, password_hash, role)

        organizer_ids = {
            "Tech Events Inc.": _ensure_organizer(cursor, user_ids["organizer@example.com"], "Tech Events Inc.", "contact@techevents.com"),
            "Summit Works": _ensure_organizer(cursor, user_ids["admin@example.com"], "Summit Works", "ops@summitworks.com")
        }

        today = datetime.now()
        events = [
            {
                "title": "Global AI Summit 2026",
                "description": "Join the brightest minds in artificial intelligence for a 3-day summit featuring keynotes, workshops, and networking.",
                "event_date": (today + timedelta(days=15)).strftime("%Y-%m-%d"),
                "event_time": "09:00:00",
                "location": "Silicon Valley Convention Center",
                "total_seats": 500,
                "available_seats": 420,
                "category_id": category_ids["Technology"],
                "organizer_id": organizer_ids["Tech Events Inc."]
            },
            {
                "title": "Startup Founder Mixer",
                "description": "An exclusive networking event for early-stage startup founders to meet investors and industry mentors.",
                "event_date": (today + timedelta(days=5)).strftime("%Y-%m-%d"),
                "event_time": "18:30:00",
                "location": "Downtown Innovation Hub",
                "total_seats": 100,
                "available_seats": 15,
                "category_id": category_ids["Business"],
                "organizer_id": organizer_ids["Summit Works"]
            },
            {
                "title": "Summer Music Festival",
                "description": "A full day of live music performances from top artists, featuring local food vendors and interactive art installations.",
                "event_date": (today + timedelta(days=45)).strftime("%Y-%m-%d"),
                "event_time": "12:00:00",
                "location": "Grand City Park",
                "total_seats": 5000,
                "available_seats": 1200,
                "category_id": category_ids["Entertainment"],
                "organizer_id": organizer_ids["Tech Events Inc."]
            },
            {
                "title": "Web3 Developer Bootcamp",
                "description": "An intensive hands-on bootcamp covering blockchain development, smart contracts, and decentralized applications.",
                "event_date": (today + timedelta(days=20)).strftime("%Y-%m-%d"),
                "event_time": "10:00:00",
                "location": "Tech Academy Campus",
                "total_seats": 50,
                "available_seats": 5,
                "category_id": category_ids["Technology"],
                "organizer_id": organizer_ids["Tech Events Inc."]
            },
            {
                "title": "Community Wellness Fair",
                "description": "A local wellness event with free health screenings, family activities, and nonprofit booths.",
                "event_date": (today + timedelta(days=30)).strftime("%Y-%m-%d"),
                "event_time": "08:30:00",
                "location": "Riverside Community Center",
                "total_seats": 250,
                "available_seats": 90,
                "category_id": category_ids["Community"],
                "organizer_id": organizer_ids["Summit Works"]
            },
            {
                "title": "Foundations of Data Analytics",
                "description": "A practical seminar for beginners covering dashboards, KPIs, and data storytelling.",
                "event_date": (today + timedelta(days=12)).strftime("%Y-%m-%d"),
                "event_time": "14:00:00",
                "location": "Downtown Learning Lab",
                "total_seats": 80,
                "available_seats": 32,
                "category_id": category_ids["Education"],
                "organizer_id": organizer_ids["Tech Events Inc."]
            }
        ]

        event_ids = {}
        for event in events:
            event_ids[event["title"]] = _ensure_event(cursor, event)

        for user_email, event_title in [
            ("ava@example.com", "Global AI Summit 2026"),
            ("noah@example.com", "Startup Founder Mixer"),
            ("mia@example.com", "Summer Music Festival"),
            ("ava@example.com", "Community Wellness Fair"),
            ("noah@example.com", "Foundations of Data Analytics")
        ]:
            _ensure_booking(cursor, user_ids[user_email], event_ids[event_title])

        for user_email, event_title, rating, comment in [
            ("ava@example.com", "Global AI Summit 2026", 5, "Strong speaker lineup and well organized sessions."),
            ("noah@example.com", "Startup Founder Mixer", 4, "Great networking value and easy check-in."),
            ("mia@example.com", "Summer Music Festival", 5, "Excellent atmosphere and very smooth event flow."),
            ("ava@example.com", "Foundations of Data Analytics", 4, "Very practical for beginners.")
        ]:
            _ensure_feedback(cursor, user_ids[user_email], event_ids[event_title], rating, comment)

        conn.commit()
        print("Successfully seeded the database with demo users, organizers, categories, events, bookings, and feedback.")

    except Exception as e:
        print(f"Error seeding database: {e}")
    finally:
        if 'cursor' in locals() and cursor:
            cursor.close()
        if 'conn' in locals() and conn:
            conn.close()


def import_users_from_csv(file_path):
    """Import users from a CSV into the users table.
    Expects columns: name,email,password,role,created_at (others ignored).
    Maps role 'customer' to 'user'. Skips users that already exist by email.
    """
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()

        with open(file_path, newline='', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                email = (row.get('email') or '').strip()
                if not email:
                    continue

                role = (row.get('role') or '').strip().lower()
                if role == 'customer':
                    role = 'user'
                if role not in ('admin', 'user', 'organizer'):
                    role = 'user'

                # skip existing
                cursor.execute("SELECT id FROM users WHERE email = %s", (email,))
                if cursor.fetchone():
                    continue

                name = (row.get('name') or '').strip() or email.split('@')[0]
                password = (row.get('password') or '').strip() or 'password'
                password_hash = generate_password_hash(password, method='pbkdf2:sha256')

                # preserve user id from CSV if provided
                user_id_raw = (row.get('user_id') or '').strip()
                try:
                    user_id = int(user_id_raw) if user_id_raw else None
                except Exception:
                    user_id = None

                created_at_raw = (row.get('created_at') or '').strip()
                created_at = None
                if created_at_raw:
                    # try common formats
                    for fmt in ("%m/%d/%Y", "%Y-%m-%d", "%Y/%m/%d"):
                        try:
                            created_at = datetime.strptime(created_at_raw, fmt)
                            break
                        except Exception:
                            created_at = None

                if user_id:
                    # insert with explicit id if provided and not exists
                    if created_at:
                        cursor.execute(
                            "INSERT INTO users (id, name, email, password_hash, role, created_at) VALUES (%s, %s, %s, %s, %s, %s)",
                            (user_id, name, email, password_hash, role, created_at)
                        )
                    else:
                        cursor.execute(
                            "INSERT INTO users (id, name, email, password_hash, role) VALUES (%s, %s, %s, %s, %s)",
                            (user_id, name, email, password_hash, role)
                        )
                else:
                    if created_at:
                        cursor.execute(
                            "INSERT INTO users (name, email, password_hash, role, created_at) VALUES (%s, %s, %s, %s, %s)",
                            (name, email, password_hash, role, created_at)
                        )
                    else:
                        cursor.execute(
                            "INSERT INTO users (name, email, password_hash, role) VALUES (%s, %s, %s, %s)",
                            (name, email, password_hash, role)
                        )

        conn.commit()
        print(f"Imported users from CSV: {file_path}")

    except Exception as e:
        print(f"Error importing users from CSV: {e}")
    finally:
        if 'cursor' in locals() and cursor:
            cursor.close()
        if 'conn' in locals() and conn:
            conn.close()


def import_categories_from_csv(file_path):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        with open(file_path, newline='', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                cid = row.get('category_id') or row.get('id')
                name = (row.get('category_name') or row.get('name') or '').strip()
                desc = (row.get('description') or '').strip()
                if not name:
                    continue

                try:
                    cid_val = int(cid) if cid else None
                except Exception:
                    cid_val = None

                # skip if exists by id or name
                if cid_val:
                    cursor.execute("SELECT id FROM categories WHERE id = %s", (cid_val,))
                    if cursor.fetchone():
                        continue

                cursor.execute("SELECT id FROM categories WHERE name = %s", (name,))
                if cursor.fetchone():
                    continue

                if cid_val:
                    cursor.execute("INSERT INTO categories (id, name, description) VALUES (%s, %s, %s)", (cid_val, name, desc))
                else:
                    cursor.execute("INSERT INTO categories (name, description) VALUES (%s, %s)", (name, desc))

        conn.commit()
        print(f"Imported categories from CSV: {file_path}")
    except Exception as e:
        print(f"Error importing categories from CSV: {e}")
    finally:
        if 'cursor' in locals() and cursor:
            cursor.close()
        if 'conn' in locals() and conn:
            conn.close()


def import_organizers_from_csv(file_path):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        with open(file_path, newline='', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                oid = row.get('organizer_id') or row.get('id')
                name = (row.get('organizer_name') or row.get('name') or '').strip()
                email = (row.get('email') or '').strip()
                phone = (row.get('phone') or '').strip()
                org = (row.get('organization') or row.get('company') or '').strip()
                if not name:
                    continue

                try:
                    oid_val = int(oid) if oid else None
                except Exception:
                    oid_val = None

                # find or create user for this organizer by email
                user_id = None
                if email:
                    cursor.execute("SELECT id FROM users WHERE email = %s", (email,))
                    r = cursor.fetchone()
                    if r:
                        user_id = r[0]
                if not user_id:
                    # create a user for organizer
                    pwd = generate_password_hash('password', method='pbkdf2:sha256')
                    cursor.execute("INSERT INTO users (name, email, password_hash, role) VALUES (%s, %s, %s, %s)", (name, email or f"{name.replace(' ','').lower()}@example.com", pwd, 'organizer'))
                    user_id = cursor.lastrowid

                # skip if organizer id exists
                if oid_val:
                    cursor.execute("SELECT id FROM organizers WHERE id = %s", (oid_val,))
                    if cursor.fetchone():
                        continue

                # skip if organizer for this user exists
                cursor.execute("SELECT id FROM organizers WHERE user_id = %s", (user_id,))
                if cursor.fetchone():
                    continue

                if oid_val:
                    cursor.execute("INSERT INTO organizers (id, user_id, company_name, contact_info) VALUES (%s, %s, %s, %s)", (oid_val, user_id, org or name, phone))
                else:
                    cursor.execute("INSERT INTO organizers (user_id, company_name, contact_info) VALUES (%s, %s, %s)", (user_id, org or name, phone))

        conn.commit()
        print(f"Imported organizers from CSV: {file_path}")
    except Exception as e:
        print(f"Error importing organizers from CSV: {e}")
    finally:
        if 'cursor' in locals() and cursor:
            cursor.close()
        if 'conn' in locals() and conn:
            conn.close()


def import_events_from_csv(file_path):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        with open(file_path, newline='', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                eid = row.get('event_id') or row.get('id')
                title = (row.get('event_name') or row.get('title') or '').strip()
                category_id = row.get('category_id')
                organizer_id = row.get('organizer_id')
                event_date_raw = (row.get('event_date') or '').strip()
                event_time_raw = (row.get('event_time') or '').strip()
                location = (row.get('venue') or row.get('location') or '').strip()
                total_seats = row.get('total_seats') or row.get('seats') or 0
                available_seats = row.get('available_seats') or 0
                status = (row.get('status') or 'upcoming').strip()
                description = (row.get('description') or '').strip()

                if not title:
                    continue

                try:
                    eid_val = int(eid) if eid else None
                except Exception:
                    eid_val = None

                # parse date
                event_date = None
                for fmt in ("%m/%d/%Y", "%Y-%m-%d", "%d/%m/%Y"):
                    try:
                        event_date = datetime.strptime(event_date_raw, fmt).date()
                        break
                    except Exception:
                        event_date = None

                # parse time if possible
                event_time = None
                for tfmt in ("%I:%M %p", "%H:%M:%S", "%H:%M"):
                    try:
                        if event_time_raw:
                            event_time = datetime.strptime(event_time_raw, tfmt).time()
                            break
                    except Exception:
                        event_time = None

                try:
                    total_seats_val = int(total_seats)
                except Exception:
                    total_seats_val = 0
                try:
                    available_seats_val = int(available_seats)
                except Exception:
                    available_seats_val = 0

                # skip if exists by id
                if eid_val:
                    cursor.execute("SELECT id FROM events WHERE id = %s", (eid_val,))
                    if cursor.fetchone():
                        continue

                if eid_val:
                    cursor.execute(
                        "INSERT INTO events (id, title, description, event_date, event_time, location, total_seats, available_seats, category_id, organizer_id, status) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
                        (eid_val, title, description, event_date, event_time, location, total_seats_val, available_seats_val, category_id or None, organizer_id or None, status)
                    )
                else:
                    cursor.execute(
                        "INSERT INTO events (title, description, event_date, event_time, location, total_seats, available_seats, category_id, organizer_id, status) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
                        (title, description, event_date, event_time, location, total_seats_val, available_seats_val, category_id or None, organizer_id or None, status)
                    )

        conn.commit()
        print(f"Imported events from CSV: {file_path}")
    except Exception as e:
        print(f"Error importing events from CSV: {e}")
    finally:
        if 'cursor' in locals() and cursor:
            cursor.close()
        if 'conn' in locals() and conn:
            conn.close()


def import_bookings_from_csv(file_path):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        with open(file_path, newline='', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                bid = row.get('booking_id') or row.get('id')
                user_id = row.get('user_id')
                event_id = row.get('event_id')
                status_raw = (row.get('booking_status') or row.get('status') or '').strip().lower()
                booking_date_raw = (row.get('booking_date') or '').strip()

                if not user_id or not event_id:
                    continue

                try:
                    bid_val = int(bid) if bid else None
                except Exception:
                    bid_val = None

                # map booking status
                if status_raw == 'cancelled':
                    status = 'cancelled'
                else:
                    status = 'booked'

                booking_date = None
                if booking_date_raw:
                    for fmt in ("%m/%d/%Y", "%Y-%m-%d", "%Y/%m/%d", "%m/%d/%Y %H:%M:%S"):
                        try:
                            booking_date = datetime.strptime(booking_date_raw, fmt)
                            break
                        except Exception:
                            booking_date = None

                # skip if exists by id
                if bid_val:
                    cursor.execute("SELECT id FROM bookings WHERE id = %s", (bid_val,))
                    if cursor.fetchone():
                        continue

                if bid_val:
                    if booking_date:
                        cursor.execute("INSERT INTO bookings (id, user_id, event_id, booking_date, status) VALUES (%s, %s, %s, %s, %s)", (bid_val, user_id, event_id, booking_date, status))
                    else:
                        cursor.execute("INSERT INTO bookings (id, user_id, event_id, status) VALUES (%s, %s, %s, %s)", (bid_val, user_id, event_id, status))
                else:
                    if booking_date:
                        cursor.execute("INSERT INTO bookings (user_id, event_id, booking_date, status) VALUES (%s, %s, %s, %s)", (user_id, event_id, booking_date, status))
                    else:
                        cursor.execute("INSERT INTO bookings (user_id, event_id, status) VALUES (%s, %s, %s)", (user_id, event_id, status))

        conn.commit()
        print(f"Imported bookings from CSV: {file_path}")
    except Exception as e:
        print(f"Error importing bookings from CSV: {e}")
    finally:
        if 'cursor' in locals() and cursor:
            cursor.close()
        if 'conn' in locals() and conn:
            conn.close()


def import_feedback_from_csv(file_path):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        with open(file_path, newline='', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                fid = row.get('feedback_id') or row.get('id')
                user_id = row.get('user_id')
                event_id = row.get('event_id')
                rating = row.get('rating')
                comment = (row.get('comment') or '').strip()
                submitted_at_raw = (row.get('submitted_at') or row.get('created_at') or '').strip()

                if not user_id or not event_id:
                    continue

                try:
                    fid_val = int(fid) if fid else None
                except Exception:
                    fid_val = None

                created_at = None
                if submitted_at_raw:
                    for fmt in ("%m/%d/%Y", "%Y-%m-%d", "%Y/%m/%d"):
                        try:
                            created_at = datetime.strptime(submitted_at_raw, fmt)
                            break
                        except Exception:
                            created_at = None

                # skip if exists
                if fid_val:
                    cursor.execute("SELECT id FROM feedback WHERE id = %s", (fid_val,))
                    if cursor.fetchone():
                        continue

                if fid_val:
                    if created_at:
                        cursor.execute("INSERT INTO feedback (id, user_id, event_id, rating, comment, created_at) VALUES (%s, %s, %s, %s, %s, %s)", (fid_val, user_id, event_id, rating, comment, created_at))
                    else:
                        cursor.execute("INSERT INTO feedback (id, user_id, event_id, rating, comment) VALUES (%s, %s, %s, %s, %s)", (fid_val, user_id, event_id, rating, comment))
                else:
                    if created_at:
                        cursor.execute("INSERT INTO feedback (user_id, event_id, rating, comment, created_at) VALUES (%s, %s, %s, %s, %s)", (user_id, event_id, rating, comment, created_at))
                    else:
                        cursor.execute("INSERT INTO feedback (user_id, event_id, rating, comment) VALUES (%s, %s, %s, %s)", (user_id, event_id, rating, comment))

        conn.commit()
        print(f"Imported feedback from CSV: {file_path}")
    except Exception as e:
        print(f"Error importing feedback from CSV: {e}")
    finally:
        if 'cursor' in locals() and cursor:
            cursor.close()
        if 'conn' in locals() and conn:
            conn.close()


if __name__ == '__main__':
    # If a CSV exists in data/Users_Data.csv, import it first, then run demo seeding.
    csv_path = os.path.join(os.path.dirname(__file__), 'data', 'Users_Data.csv')
    if os.path.exists(csv_path):
        import_users_from_csv(csv_path)

    seed_database()
