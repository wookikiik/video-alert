#!/usr/bin/env python3
"""
Database Initialization Script

This script initializes the SQLite database and creates required tables.
It is safe to run multiple times (idempotent) - it will not drop existing data.

Usage:
    python scripts/init_db.py

The DATABASE_URL is read from the backend/.env file, or defaults to sqlite:///./dev.db
"""

import sys
import os
from pathlib import Path

# Add backend directory to Python path
SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent
BACKEND_DIR = REPO_ROOT / "backend"
sys.path.insert(0, str(BACKEND_DIR))

# Load environment variables from backend/.env if it exists
ENV_FILE = BACKEND_DIR / ".env"
if ENV_FILE.exists():
    from dotenv import load_dotenv
    load_dotenv(ENV_FILE)
    print(f"✓ Loaded environment from: {ENV_FILE}")
else:
    print(f"⚠ No .env file found at: {ENV_FILE}")
    print(f"  Using default DATABASE_URL: sqlite:///./dev.db")

import sqlite3
from datetime import datetime


def get_database_path():
    """Extract database path from DATABASE_URL environment variable."""
    database_url = os.getenv("DATABASE_URL", "sqlite:///./dev.db")
    
    if not database_url.startswith("sqlite:///"):
        print(f"✗ ERROR: Only SQLite databases are supported")
        print(f"  Got: {database_url}")
        sys.exit(1)
    
    # Remove 'sqlite:///' prefix and resolve path
    db_path = database_url.replace("sqlite:///", "")
    
    # If path is relative (starts with ./), make it relative to backend dir
    if db_path.startswith("./"):
        db_path = BACKEND_DIR / db_path[2:]
    else:
        db_path = Path(db_path)
    
    return db_path


def create_tables(conn):
    """Create database tables if they don't exist."""
    cursor = conn.cursor()
    
    # Table: crawl_schedules
    # Stores crawl schedule configuration
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS crawl_schedules (
            id TEXT PRIMARY KEY,
            url TEXT NOT NULL,
            interval INTEGER NOT NULL,
            is_active BOOLEAN NOT NULL DEFAULT 0,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    # Table: video_records
    # Stores detected video metadata
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS video_records (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            url TEXT NOT NULL,
            thumbnail TEXT,
            description TEXT,
            detected_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            schedule_id TEXT NOT NULL,
            FOREIGN KEY (schedule_id) REFERENCES crawl_schedules (id)
        )
    """)
    
    # Table: notification_logs
    # Tracks notification attempts for each video
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS notification_logs (
            id TEXT PRIMARY KEY,
            video_id TEXT NOT NULL,
            schedule_id TEXT NOT NULL,
            status TEXT NOT NULL,
            error_details TEXT,
            sent_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (video_id) REFERENCES video_records (id),
            FOREIGN KEY (schedule_id) REFERENCES crawl_schedules (id)
        )
    """)
    
    # Table: crawl_execution_logs
    # Records each crawl attempt and its outcome
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS crawl_execution_logs (
            id TEXT PRIMARY KEY,
            schedule_id TEXT NOT NULL,
            started_at TIMESTAMP NOT NULL,
            finished_at TIMESTAMP,
            status TEXT NOT NULL,
            error_details TEXT,
            FOREIGN KEY (schedule_id) REFERENCES crawl_schedules (id)
        )
    """)
    
    # Create indexes for better query performance
    cursor.execute("""
        CREATE INDEX IF NOT EXISTS idx_crawl_schedules_is_active 
        ON crawl_schedules(is_active)
    """)
    
    cursor.execute("""
        CREATE INDEX IF NOT EXISTS idx_video_records_schedule_id 
        ON video_records(schedule_id)
    """)
    
    cursor.execute("""
        CREATE INDEX IF NOT EXISTS idx_video_records_detected_at 
        ON video_records(detected_at DESC)
    """)
    
    cursor.execute("""
        CREATE INDEX IF NOT EXISTS idx_notification_logs_video_id 
        ON notification_logs(video_id)
    """)
    
    cursor.execute("""
        CREATE INDEX IF NOT EXISTS idx_notification_logs_schedule_id 
        ON notification_logs(schedule_id)
    """)
    
    cursor.execute("""
        CREATE INDEX IF NOT EXISTS idx_crawl_execution_logs_schedule_id 
        ON crawl_execution_logs(schedule_id, started_at DESC)
    """)
    
    conn.commit()
    print("✓ Database tables created/verified successfully")


def verify_tables(conn):
    """Verify that all expected tables exist."""
    cursor = conn.cursor()
    
    expected_tables = ["crawl_schedules", "video_records", "notification_logs", "crawl_execution_logs"]
    
    cursor.execute("""
        SELECT name FROM sqlite_master 
        WHERE type='table' AND name NOT LIKE 'sqlite_%'
        ORDER BY name
    """)
    
    existing_tables = [row[0] for row in cursor.fetchall()]
    
    print("\n✓ Database tables:")
    for table in existing_tables:
        status = "✓" if table in expected_tables else "•"
        print(f"  {status} {table}")
    
    # Count rows in each table
    print("\n✓ Table row counts:")
    for table in existing_tables:
        cursor.execute(f"SELECT COUNT(*) FROM {table}")
        count = cursor.fetchone()[0]
        print(f"  • {table}: {count} rows")
    
    missing_tables = set(expected_tables) - set(existing_tables)
    if missing_tables:
        print(f"\n✗ WARNING: Missing expected tables: {', '.join(missing_tables)}")
        return False
    
    return True


def main():
    """Main function to initialize the database."""
    print("=" * 60)
    print("Video Alert - Database Initialization")
    print("=" * 60)
    print()
    
    # Get database path
    db_path = get_database_path()
    print(f"Database path: {db_path}")
    
    # Create parent directory if it doesn't exist
    db_path.parent.mkdir(parents=True, exist_ok=True)
    
    # Check if database file already exists
    db_exists = db_path.exists()
    if db_exists:
        print(f"✓ Database file exists: {db_path}")
        print("  Updating schema if needed (existing data will be preserved)...")
    else:
        print(f"• Creating new database: {db_path}")
    
    try:
        # Connect to database
        conn = sqlite3.connect(db_path)
        print(f"✓ Connected to database")
        
        # Create tables
        create_tables(conn)
        
        # Verify tables
        if verify_tables(conn):
            print("\n" + "=" * 60)
            print("✓ Database initialization completed successfully!")
            print("=" * 60)
            print()
            print("Next steps:")
            print("  1. Start the FastAPI server:")
            print("     cd backend && uvicorn app.main:app --reload")
            print("  2. Or use the development helper script:")
            print("     ./scripts/dev_backend.sh")
            print()
        else:
            print("\n✗ Database initialization completed with warnings")
            sys.exit(1)
        
    except sqlite3.Error as e:
        print(f"\n✗ Database error: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"\n✗ Unexpected error: {e}")
        sys.exit(1)
    finally:
        if 'conn' in locals():
            conn.close()


if __name__ == "__main__":
    main()
