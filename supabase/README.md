# Supabase Setup for Introgy App

This directory contains the database schema and setup instructions for the Introgy app's Supabase backend.

## Database Schema

The `schema.sql` file contains all the necessary SQL commands to set up the database schema for the Introgy app, including:

- Tables for user profiles, social battery data, connections, wellbeing data, journal entries, social events, premium subscriptions, and AI tips
- Row Level Security (RLS) policies to ensure data privacy
- Triggers for maintaining updated timestamps
- Functions for handling new user signups

## Setup Instructions

### 1. Access the Supabase SQL Editor

1. Log in to your Supabase dashboard at [https://app.supabase.io](https://app.supabase.io)
2. Select your project (gnvlzzqtmxrfvkdydxet)
3. Navigate to the SQL Editor in the left sidebar

### 2. Run the Schema SQL

1. Copy the contents of `schema.sql` or upload the file directly
2. Execute the SQL commands to create all necessary tables and policies

### 3. Configure Authentication

1. In the Supabase dashboard, go to Authentication > Settings
2. Enable the providers you want to use (Email, Google, etc.)
3. For Google authentication:
   - Set up OAuth credentials in the Google Cloud Console
   - Add your Supabase URL as an authorized redirect URI: `https://gnvlzzqtmxrfvkdydxet.supabase.co/auth/v1/callback`
   - Configure the client ID and secret in Supabase

### 4. Test the Connection

After setting up the schema and authentication, you can test the connection using the Flutter app. The app is already configured to connect to your Supabase project using the credentials in the `.env` file.

## Table Structure

### Profiles
Stores user profile information including premium status.

### Social Battery
Tracks user's social energy levels over time.

### Connections
Manages user's social connections and relationships.

### Wellbeing Data
Records user's wellbeing metrics and mood data.

### Journal Entries
Stores user's journal entries for reflection.

### Social Events
Tracks upcoming and past social events.

### Premium Subscriptions
Manages user's premium subscription details.

### AI Tips
Stores AI-generated tips and advice for users.

## Security

The database is configured with Row Level Security (RLS) policies to ensure that users can only access their own data. Each table has policies that restrict access based on the user's ID.

## Maintenance

To make changes to the schema:
1. Update the `schema.sql` file
2. Run the updated SQL in the Supabase SQL Editor
3. Test the changes in the app

Remember to back up your data before making significant schema changes.
