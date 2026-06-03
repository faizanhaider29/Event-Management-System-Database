import os
import csv
from datetime import datetime
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

def import_users():
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()

        file_path = 'data/Users_Data.csv'
        with open(file_path, newline='', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            count = 0
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
                
                # We will NOT use the user_id from the CSV, letting MySQL auto-increment it
                # phone is not in the schema: 
                # CREATE TABLE IF NOT EXISTS users (
                #     id INT AUTO_INCREMENT PRIMARY KEY,
                #     name VARCHAR(100) NOT NULL,
                #     email VARCHAR(100) UNIQUE NOT NULL,
                #     password_hash VARCHAR(255) NOT NULL,
                #     role ENUM('admin', 'user', 'organizer') DEFAULT 'user',
                #     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                # );

                created_at_raw = (row.get('created_at') or '').strip()
                created_at = None
                if created_at_raw:
                    for fmt in ("%m/%d/%Y", "%Y-%m-%d", "%Y/%m/%d"):
                        try:
                            created_at = datetime.strptime(created_at_raw, fmt)
                            break
                        except Exception:
                            created_at = None

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
                count += 1

        conn.commit()
        print(f"Imported {count} users from CSV: {file_path}")

    except Exception as e:
        print(f"Error importing users from CSV: {e}")
    finally:
        if 'cursor' in locals() and cursor:
            cursor.close()
        if 'conn' in locals() and conn:
            conn.close()

if __name__ == '__main__':
    import_users()
