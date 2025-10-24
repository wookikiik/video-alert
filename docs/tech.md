### Technical Summary

Implement an automated video monitoring and notification system, architected as four distinct modules—**crawl_schedules**, **execute_crawl_schedules**, **video_records**, and **notification_logs**—to enable admin users to configure and manage a single monitored video page URL and Telegram channel via environment variables (read-only in the UI), manage a single active crawl schedule, detect new videos, send structured Telegram notifications, and review all detection and notification events via an admin dashboard.  
The **execute_crawl_schedules** module records each crawl attempt and its outcome in a dedicated execution history table for monitoring, debugging, and audit purposes.  
This extends the existing FastAPI backend and NextJS (React, Typescript, shadcn/ui) frontend, with SQLite3 for persistent storage.  
The video page URL and Telegram channel ID are managed exclusively via environment variables and are only displayed (read-only) in the admin dashboard; no update or validation logic is provided in the backend or frontend.

### System Design

#### **Backend (FastAPI)**

- **crawl_schedules**
    - Provides CRUD endpoints for schedule objects.
    - Manages schedule state (active/history) and enforces single active schedule constraint.
    - Integrates with APScheduler for job lifecycle management (start, update, cancel).
    - Exposes schedule history for read/delete actions.
    - Validates schedule intervals and surfaces errors for invalid inputs.

- **execute_crawl_schedules**
    - Orchestrates scheduled crawling at defined intervals.
    - Reads the monitored video page URL and Telegram channel ID from environment variables at job start.
    - Executes extraction logic:
        - Attempts static HTML parsing with BeautifulSoup.
        - Falls back to Playwright for dynamic content if needed.
    - Records each crawl attempt and its outcome in `crawl_execution_logs` (start/end time, status, error details).
    - Handles error logging for extraction failures and page structure changes.
    - Triggers downstream actions: video detection, deduplication, and notification.
    - Cancels pending jobs if the active schedule is deleted.

- **video_records**
    - Stores detected video metadata (title, URL, thumbnail, description, detected_at, schedule_id).
    - Deduplicates videos by comparing extracted data with existing records.
    - Associates each video with its crawl schedule.
    - Handles edge cases: skips notification if video is removed before notification; logs extraction errors.

- **notification_logs**
    - Tracks notification attempts for each video (status, error details, sent_at).
    - Integrates with Telegram via direct HTTP API (python-telegram-bot or requests).
    - Implements retry logic for transient failures and logs all attempts.
    - Ensures idempotency: prevents duplicate notifications for the same video.
    - Supports log review and manual retention actions (delete/archive).

- **Security**
    - Restricts all admin dashboard and schedule/log management endpoints to authenticated admin users.
    - Prevents unauthorized access to schedule and log management features.

- **Testing**
    - Applies existing unit and integration test patterns for FastAPI.
    - Tests full flows: schedule CRUD, crawling/extraction, video detection, notification, and log management.
    - Includes regression tests for edge cases: invalid inputs, extraction failures, notification retries, duplicate detection, and manual log deletion.

#### **Frontend (NextJS, shadcn/ui)**

- **crawl_schedules**
    - Admin dashboard UI for creating, updating, viewing, and deleting crawl schedules.
    - Clearly indicates active schedule and displays schedule history.
    - Validates interval inputs and restricts multiple active schedules.
    - Uses custom React components with shadcn/ui, following established form and state management patterns.

- **System Variables Display**
    - UI displays the current monitored video page URL and Telegram channel ID (read-only).
    - No editing or update functionality is provided.
    - Shows validation hints and notes that changes require environment variable updates at the server level.

- **video_records & notification_logs**
    - Logs viewer UI for detected videos and notification events.
    - Searchable and filterable by schedule, status, title, and date range.
    - Displays detailed log entries, error details, and supports manual delete/archive actions.
    - Provides clear feedback for edge cases (missing log data, no results found).

- **crawl_execution_logs**
    - UI for viewing crawl execution history (start/end time, status, error details) per schedule.
    - Filterable and searchable by schedule and status.

- **Security**
    - Restricts dashboard and schedule/log management UI to authenticated admin users.
    - Handles loading, disabled, and confirmation states for all destructive actions.

- **Testing**
    - Applies existing unit, integration, and E2E test patterns for NextJS.
    - Validates all admin flows, error handling, and edge cases.

### Data Model / Schema Changes

| Table                   | Column         | Type        | Description                                   |
|-------------------------|---------------|-------------|-----------------------------------------------|
| `crawl_schedules`       | `id`          | UUID (PK)   | Unique identifier for each schedule           |
|                         | `url`         | TEXT        | Monitored video page URL                      |
|                         | `interval`    | INTEGER     | Crawl interval in minutes                     |
|                         | `is_active`   | BOOLEAN     | Indicates if schedule is currently active     |
|                         | `created_at`  | DATETIME    | Schedule creation timestamp                   |
|-------------------------|---------------|-------------|-----------------------------------------------|
| `video_records`         | `id`          | UUID (PK)   | Unique identifier for each detected video     |
|                         | `title`       | TEXT        | Video title                                   |
|                         | `url`         | TEXT        | Video URL                                     |
|                         | `thumbnail`   | TEXT        | Thumbnail URL                                 |
|                         | `description` | TEXT        | Brief description (nullable)                  |
|                         | `detected_at` | DATETIME    | Timestamp of detection                        |
|                         | `schedule_id` | UUID (FK)   | Associated crawl schedule                     |
|-------------------------|---------------|-------------|-----------------------------------------------|
| `notification_logs`     | `id`          | UUID (PK)   | Unique identifier for each notification event |
|                         | `video_id`    | UUID (FK)   | Reference to detected video                   |
|                         | `schedule_id` | UUID (FK)   | Reference to crawl schedule                   |
|                         | `status`      | TEXT        | Notification status (sent, failed, retried)   |
|                         | `error_details`| TEXT       | Error message if notification failed (nullable)|
|                         | `sent_at`     | DATETIME    | Timestamp of notification attempt             |
|-------------------------|---------------|-------------|-----------------------------------------------|
| `crawl_execution_logs`  | `id`          | UUID (PK)   | Unique identifier for each crawl execution    |
|                         | `schedule_id` | UUID (FK)   | Reference to crawl_schedules                  |
|                         | `started_at`  | DATETIME    | Execution start timestamp                     |
|                         | `finished_at` | DATETIME    | Execution end timestamp                       |
|                         | `status`      | TEXT        | Execution status (success, failed, error)     |
|                         | `error_details`| TEXT       | Error message if execution failed (nullable)  |
