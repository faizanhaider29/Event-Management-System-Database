import mysql.connector
from mysql.connector import pooling
from pathlib import Path
import os

from dotenv import load_dotenv

load_dotenv()

db_config = {
    "host": os.getenv("MYSQL_HOST", "localhost"),
    "user": os.getenv("MYSQL_USER", "root"),
    "password": os.getenv("MYSQL_PASSWORD", ""),
    "database": os.getenv("MYSQL_DATABASE", "event_management"),
    "autocommit": True,
}

connection_pool = None


def _create_connection_pool():
    global connection_pool

    if connection_pool is not None:
        return connection_pool

    try:
        connection_pool = mysql.connector.pooling.MySQLConnectionPool(
            pool_name="mypool",
            pool_size=5,
            pool_reset_session=True,
            **db_config
        )
    except mysql.connector.Error as err:
        print(f"Error setting up connection pool: {err}")
        print("Set MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, and MYSQL_DATABASE in your environment or .env file.")
        connection_pool = None

    return connection_pool

def get_db_connection():
    pool = _create_connection_pool()
    if pool:
        try:
            return pool.get_connection()
        except mysql.connector.Error as err:
            print(f"Error getting connection from pool: {err}")
            return None
    return None

def init_db():
    # Helper function to initialize database from schema.sql
    try:
        # Connect without database first
        setup_config = db_config.copy()
        del setup_config['database']
        
        conn = mysql.connector.connect(**setup_config)
        cursor = conn.cursor()
        
        schema_path = Path(__file__).with_name('schema.sql')
        with open(schema_path, 'r', encoding='utf-8') as f:
            sql_script = f.read()
            
        # Execute each statement
        for statement in sql_script.split(';'):
            if statement.strip():
                cursor.execute(statement)
                
        conn.commit()
        cursor.close()
        conn.close()
        print("Database initialized successfully.")
    except Exception as e:
        print(f"Database initialization error: {e}")
