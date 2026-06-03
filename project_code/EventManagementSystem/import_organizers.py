import os
import csv
import mysql.connector
from werkzeug.security import generate_password_hash
from dotenv import load_dotenv

load_dotenv()

db_config = {
    "host": os.getenv("MYSQL_HOST", "localhost"),
    "user": os.getenv("MYSQL_USER", "root"),
    "password": os.getenv("MYSQL_PASSWORD", ""),
    "database": os.getenv("MYSQL_DATABASE", "event_management")
}

def import_organizers():
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()

        file_path = 'data/Organizer_Data.csv'
        with open(file_path, newline='', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            count = 0
            for row in reader:
                name = (row.get('organizer_name') or row.get('name') or '').strip()
                email = (row.get('email') or '').strip()
                phone = (row.get('phone') or '').strip()
                org = (row.get('organization') or row.get('company') or '').strip()
                if not name:
                    continue

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
                    cursor.execute("INSERT INTO users (name, email, password_hash, role) VALUES (%s, %s, %s, %s)", 
                                   (name, email or f"{name.replace(' ','').lower()}@example.com", pwd, 'organizer'))
                    user_id = cursor.lastrowid

                # skip if organizer for this user exists
                cursor.execute("SELECT id FROM organizers WHERE user_id = %s", (user_id,))
                if cursor.fetchone():
                    continue

                # Ignore explicit ID from CSV, use auto-increment
                cursor.execute("INSERT INTO organizers (user_id, company_name, contact_info) VALUES (%s, %s, %s)", 
                               (user_id, org or name, phone))
                count += 1

        conn.commit()
        print(f"Imported {count} organizers from CSV: {file_path}")

    except Exception as e:
        print(f"Error importing organizers from CSV: {e}")
    finally:
        if 'cursor' in locals() and cursor:
            cursor.close()
        if 'conn' in locals() and conn:
            conn.close()

if __name__ == '__main__':
    import_organizers()
