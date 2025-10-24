## Objective

Enable administrators to automatically detect newly posted videos on a single specified external page and send structured notifications to a designated Telegram channel, improving timely awareness of new content.

## Project Goal

Achieve 99% accuracy in detecting and notifying about new videos within 10 minutes of their appearance on the monitored page, using a single active crawl schedule.

## User Journey

### Admin User Journey

1. Admin accesses the system dashboard.
2. Admin configures the single external video page URL to monitor via system variables (.env).
3. Admin creates one active crawl schedule for the monitored URL; only one schedule can be active at a time.
4. Admin can view and delete previous schedules as history, but cannot create multiple active schedules.
5. At each scheduled interval, the system crawls the specified page.
6. The system compares detected videos with the database of previously found videos to identify new content.
7. For each new video, the system extracts the title, URL, thumbnail, and brief description (if available).
8. The system sends a fixed-format notification containing this information to the Telegram channel specified in system variables.
9. The system logs each notification and detected new video, maintaining logs separately for each schedule.
10. Admin reviews logs in the dashboard, filtering/searching by schedule and notification history.

## Features 

### In Scope
- Single Active Crawl Schedule Management
- System Variable URL Configuration (Single URL)
- New Video Detection (Database Comparison)
- Telegram Notification (Fixed Format)
- Notification and Detection Logging (Per Schedule)
- Admin Dashboard for Log Review
- Schedule History (Read, Delete)

### Out of Scope
- Multiple Active Schedules  
- Manual URL Entry in Dashboard  
- Customizable Notification Format  
- Real-time (instant) crawling  
- Multi-channel Telegram selection via UI
