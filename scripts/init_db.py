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
    
    # Table: videos
    # Stores information about monitored videos
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS videos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            video_id TEXT UNIQUE NOT NULL,
            title TEXT NOT NULL,
            url TEXT NOT NULL,
            thumbnail_url TEXT,
            description TEXT,
            published_at TIMESTAMP,
            detected_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            notified BOOLEAN NOT NULL DEFAULT 0,
            notified_at TIMESTAMP,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    # Table: alert_logs
    # Stores history of alerts sent
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS alert_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            video_id INTEGER NOT NULL,
            channel_id TEXT NOT NULL,
            message_id TEXT,
            status TEXT NOT NULL,
            error_message TEXT,
            sent_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (video_id) REFERENCES videos (id)
        )
    """)
    
    # Table: scheduler_runs
    # Tracks scheduler execution history
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS scheduler_runs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            job_name TEXT NOT NULL,
            status TEXT NOT NULL,
            started_at TIMESTAMP NOT NULL,
            completed_at TIMESTAMP,
            duration_seconds REAL,
            videos_found INTEGER DEFAULT 0,
            alerts_sent INTEGER DEFAULT 0,
            error_message TEXT,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    # Create indexes for better query performance
    cursor.execute("""
        CREATE INDEX IF NOT EXISTS idx_videos_video_id 
        ON videos(video_id)
    """)
    
    cursor.execute("""
        CREATE INDEX IF NOT EXISTS idx_videos_notified 
        ON videos(notified)
    """)
    
    cursor.execute("""
        CREATE INDEX IF NOT EXISTS idx_videos_detected_at 
        ON videos(detected_at DESC)
    """)
    
    cursor.execute("""
        CREATE INDEX IF NOT EXISTS idx_alert_logs_video_id 
        ON alert_logs(video_id)
    """)
    
    cursor.execute("""
        CREATE INDEX IF NOT EXISTS idx_scheduler_runs_job_name 
        ON scheduler_runs(job_name, started_at DESC)
    """)
    
    conn.commit()
    print("✓ Database tables created/verified successfully")


def verify_tables(conn):
    """Verify that all expected tables exist."""
    cursor = conn.cursor()
    
    expected_tables = ["videos", "alert_logs", "scheduler_runs"]
    
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
