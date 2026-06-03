import random
import datetime
import mysql.connector
from dotenv import load_dotenv
import os

load_dotenv()

db_config = {
    "host": os.getenv("MYSQL_HOST", "localhost"),
    "user": os.getenv("MYSQL_USER", "root"),
    "password": os.getenv("MYSQL_PASSWORD", ""),
    "database": os.getenv("MYSQL_DATABASE", "event_management")
}

def generate_date():
    start = datetime.datetime(2025, 1, 1)
    end = datetime.datetime(2026, 12, 31)
    return start + datetime.timedelta(days=random.randint(0, 700))

def generate_time():
    return f"{random.randint(1, 12):02d}:{random.randint(0, 59):02d} {'AM' if random.random() > 0.5 else 'PM'}"

def import_data():
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()

        cursor.execute("SELECT id FROM categories")
        valid_cats = [row[0] for row in cursor.fetchall()]
        if not valid_cats:
            valid_cats = [1]
            
        cursor.execute("SELECT id FROM organizers")
        valid_orgs = [row[0] for row in cursor.fetchall()]
        if not valid_orgs:
            valid_orgs = [1]
            
        cursor.execute("SELECT id FROM users")
        valid_users = [row[0] for row in cursor.fetchall()]
        if not valid_users:
            valid_users = [1]

        def safe_cat(cid):
            return cid if cid in valid_cats else random.choice(valid_cats)
        def safe_org(oid):
            return oid if oid in valid_orgs else random.choice(valid_orgs)
        def safe_usr(uid):
            return uid if uid in valid_users else random.choice(valid_users)

        def generate_event(id):
            names = ["Business Summit", "Startup Mixer", "Health Science", "Gaming Expo", "Food Carnival", "Music Festival", "Tech Conference", "AI Workshop", "Sports Tournament", "Fashion Show"]
            statuses = ["upcoming", "complete", "cancelled"]
            return (
                id,
                random.choice(valid_cats),
                random.choice(valid_orgs),
                random.choice(names),
                generate_date().strftime("%Y-%m-%d"),
                datetime.datetime.strptime(generate_time(), "%I:%M %p").strftime("%H:%M:%S"),
                f"Venue {random.randint(1, 100)}",
                random.randint(50, 500),
                random.randint(0, 500),
                random.choice(statuses),
                "Sample description for event.",
                generate_date().strftime("%Y-%m-%d")
            )

        events = [
            (1, safe_cat(18), safe_org(41), "Business Summit", "2026-02-03", "23:11:00", "Canton", 468, 98, "upcoming", "Suspendisse", "2026-02-09"),
            (2, safe_cat(6), safe_org(23), "Startup Mixer", "2025-08-09", "22:23:00", "Seseng", 76, 365, "complete", "Etiam vel", "2025-08-09"),
            (3, safe_cat(2), safe_org(19), "Health Science", "2026-04-03", "10:23:00", "Zengtian", 488, 274, "complete", "Mauris en", "2026-04-03"),
            (4, safe_cat(4), safe_org(30), "Gaming Expo", "2025-08-07", "03:22:00", "Shiniujian", 449, 67, "cancelled", "Integer ac", "2025-08-08"),
            (5, safe_cat(17), safe_org(7), "Food Carnival", "2025-10-10", "16:04:00", "Wenquan", 401, 353, "cancelled", "Sed sagitt", "2025-10-10"),
            (6, safe_cat(20), safe_org(3), "Health Science", "2025-11-11", "07:38:00", "Carolina", 388, 310, "upcoming", "Quisque", "2025-11-11"),
            (7, safe_cat(6), safe_org(24), "Food Carnival", "2025-12-12", "10:48:00", "La Banda", 437, 465, "cancelled", "Fusce", "2025-12-12"),
            (8, safe_cat(20), safe_org(48), "Tech Conference", "2026-01-08", "18:54:00", "Ulety", 446, 106, "cancelled", "Nullam", "2026-01-08"),
            (9, safe_cat(3), safe_org(39), "Health Science", "2025-07-07", "14:13:00", "Concepcion", 492, 139, "cancelled", "Aenean", "2025-07-07"),
            (10, safe_cat(19), safe_org(2), "AI Workshop", "2025-07-06", "02:24:00", "Laocheng", 106, 239, "upcoming", "Cras non", "2025-07-06"),
            (11, safe_cat(5), safe_org(29), "Health Science", "2025-05-05", "06:35:00", "Guapore", 336, 435, "upcoming", "In sagittis", "2025-05-05"),
            (12, safe_cat(6), safe_org(26), "Music Festival", "2025-04-04", "00:40:00", "Azenhas", 426, 21, "complete", "Pellentes", "2025-04-04"),
            (13, safe_cat(10), safe_org(6), "Business Summit", "2025-03-03", "11:44:00", "Novonuku", 275, 78, "complete", "Cras mi", "2025-03-03"),
            (14, safe_cat(19), safe_org(50), "Business Summit", "2025-02-02", "14:35:00", "Mullovka", 165, 176, "upcoming", "Maecena", "2025-06-08"),
            (15, safe_cat(20), safe_org(42), "Music Festival", "2025-01-01", "06:19:00", "Cileguh", 420, 372, "complete", "Maecena", "2025-01-01"),
            (16, safe_cat(5), safe_org(13), "Gaming Expo", "2025-09-09", "08:20:00", "Denver", 361, 233, "cancelled", "Quisque", "2025-09-09"),
            (17, safe_cat(17), safe_org(25), "Music Festival", "2025-06-05", "23:21:00", "Youxi", 275, 8, "complete", "Cras non", "2025-06-05"),
            (18, safe_cat(14), safe_org(11), "Health Science", "2025-10-20", "20:14:00", "Tongcha", 379, 227, "complete", "Curabitur", "2025-10-20"),
            (19, safe_cat(7), safe_org(35), "Startup Mixer", "2025-11-21", "01:05:00", "Daykitin", 216, 468, "upcoming", "Fusce con", "2025-11-21"),
            (20, safe_cat(9), safe_org(21), "Startup Mixer", "2025-08-02", "04:55:00", "La Banda", 476, 30, "upcoming", "In quis", "2025-08-02")
        ]

        # Generate the remaining 80 events
        for i in range(21, 101):
            events.append(generate_event(i))

        # Insert events
        valid_events = []
        for e in events:
            # Check if event exists
            cursor.execute("SELECT id FROM events WHERE id = %s", (e[0],))
            if cursor.fetchone():
                valid_events.append(e[0])
                continue
            cursor.execute(
                "INSERT INTO events (id, category_id, organizer_id, title, event_date, event_time, location, total_seats, available_seats, status, description, created_at) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
                e
            )
            valid_events.append(e[0])
            
        def safe_evt(eid):
            return eid if eid in valid_events else random.choice(valid_events)

        def generate_feedback(id):
            return (
                id,
                random.choice(valid_users),
                random.choice(valid_events),
                random.randint(1, 5),
                "Sample comment.",
                generate_date().strftime("%Y-%m-%d")
            )

        # Hardcoded first 20 feedbacks from the image
        feedbacks = [
            (1, safe_usr(15), safe_evt(87), 4, "Pellentesque", "2025-01-01"),
            (2, safe_usr(14), safe_evt(4), 2, "Fusce pos", "2025-02-02"),
            (3, safe_usr(72), safe_evt(30), 1, "Nulla just", "2025-03-03"),
            (4, safe_usr(91), safe_evt(18), 3, "Nulla tem", "2025-04-04"),
            (5, safe_usr(7), safe_evt(37), 1, "In eleifen", "2025-05-05"),
            (6, safe_usr(17), safe_evt(15), 5, "Aenean ar", "2025-06-06"),
            (7, safe_usr(6), safe_evt(50), 3, "Aliquam s", "2025-07-07"),
            (8, safe_usr(36), safe_evt(63), 2, "Integer pe", "2025-08-08"),
            (9, safe_usr(39), safe_evt(9), 1, "Fusce con", "2025-09-09"),
            (10, safe_usr(87), safe_evt(79), 3, "Sed ante", "2025-08-09"),
            (11, safe_usr(29), safe_evt(79), 4, "Aenean le", "2025-10-10"),
            (12, safe_usr(19), safe_evt(51), 3, "Quisque k", "2025-06-05"),
            (13, safe_usr(30), safe_evt(54), 4, "Cum sociis", "2025-11-11"),
            (14, safe_usr(67), safe_evt(94), 5, "Morbi a ip", "2025-12-12"),
            (15, safe_usr(91), safe_evt(23), 3, "Fusce con", "2026-01-01"),
            (16, safe_usr(85), safe_evt(5), 4, "Maecenas", "2026-02-02"),
            (17, safe_usr(42), safe_evt(77), 5, "Nullam or", "2026-03-03"),
            (18, safe_usr(80), safe_evt(29), 1, "Cras mi pe", "2026-04-04"),
            (19, safe_usr(27), safe_evt(22), 4, "Donec ut", "2026-05-05"),
            (20, safe_usr(84), safe_evt(60), 1, "Fusce lacu", "2026-06-06")
        ]

        # Generate the remaining 80 feedbacks
        for i in range(21, 101):
            feedbacks.append(generate_feedback(i))

        # Insert feedbacks
        for f in feedbacks:
            # Check if feedback exists
            cursor.execute("SELECT id FROM feedback WHERE id = %s", (f[0],))
            if cursor.fetchone():
                continue
            cursor.execute(
                "INSERT INTO feedback (id, user_id, event_id, rating, comment, created_at) VALUES (%s, %s, %s, %s, %s, %s)",
                f
            )

        conn.commit()
        print(f"Successfully imported events and feedbacks into the database.")

    except Exception as e:
        print(f"Error importing data: {e}")
    finally:
        if 'cursor' in locals() and cursor:
            cursor.close()
        if 'conn' in locals() and conn:
            conn.close()

if __name__ == '__main__':
    import_data()
