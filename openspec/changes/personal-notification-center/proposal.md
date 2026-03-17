# Proposal: personal-notification-center

## Why
Currently, parents and students do not have a centralized place in the application to view their notifications. While we have tools to generate multi-channel notifications (like email/WhatsApp), an in-app inbox or notification center gives users a persistent and easily accessible history of their important financial alerts, reminders, and system updates.

## What Changes
- Create an in-app "Notification Center" or inbox for users (primarily parents).
- Implement a backend data model to store individual user notifications (read/unread status, message content, timestamp).
- Build endpoints to fetch a user's notifications and mark them as read.
- Add a notification bell/inbox UI component in the parent dashboard.

## Capabilities
- parent-notification-inbox: Allows parents to view a history of their notifications within the app and mark them as read.

## Impact
- **Database/Storage**: New `Notification` entity/store.
- **Backend**: New module/controller for fetching and updating personal notifications.
- **Frontend**: UI updates to the parent dashboard (notification bell, dropdown/page for displaying the messages).
