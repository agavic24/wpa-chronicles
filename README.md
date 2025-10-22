# Chronicles - D&D Campaign Management System

## Overview

This project is a comprehensive D&D campaign management system built on Snowflake. It uses AI to generate narrative summaries and extract structured metadata from campaign session transcripts, creating a rich, searchable database of campaign history.

## Project Components

### 1. Database Schema
- **SCENE_NARRATIVE**: Player-facing story summaries with narrative text, key moments, and memorable quotes
- **SCENE_METADATA**: Structured campaign tracking data including NPCs, plot threads, locations, items, and more
- **FINAL_MESSAGES**: Raw session message data

### 2. AI Processing Pipeline
The `generate_scene_summaries.sql` file contains stored procedures that:
- Use Snowflake Cortex AI (Claude 4 Sonnet) to generate rich narrative summaries
- Extract structured metadata from session transcripts
- Maintain campaign continuity by referencing prior scenes
- Process scenes individually or in batch

### 3. Scene Metadata Editor (Streamlit App)

A Streamlit application for viewing and editing campaign scene metadata.

#### Features
- **Scene Selection**: Dropdown menu to browse all available scenes
- **Interactive Editor**: View and edit metadata fields using Streamlit's data editor widget
- **Read-Only Fields**: SCENE_NUM and UPDATED_AT are protected from editing
- **Wide Layout**: Optimized for viewing the extensive metadata fields
- **Real-time Refresh**: Ability to reload data from the database

#### App Files
- `scene_metadata_editor.py`: Main Streamlit application
- `snowflake.yml`: Streamlit app configuration for Snowflake deployment
- `environment.yml`: Python dependencies (streamlit, snowflake-snowpark-python, pandas)

#### Deployment
Deploy the app to Snowflake using the Snowflake CLI:

```bash
snow streamlit deploy
```

The app will be deployed as `scene_metadata_editor` in the `WPA.DATA` schema.

#### Usage
1. Select a scene number from the sidebar dropdown
2. View all metadata fields in the data editor
3. Edit any field except SCENE_NUM and UPDATED_AT
4. Click "Save Changes" to persist updates (future implementation)
5. Click "Refresh Data" to reload from the database

## Database Tables

### SCENE_METADATA Fields
- **Basic Info**: SCENE_NUM, SCENE_TITLE, SCENE_TYPE
- **Locations & Characters**: ALL_LOCATIONS, PARTY_MEMBERS_ACTIVE, NPCS_ENCOUNTERED, ENEMIES_FACED
- **Plot Tracking**: PLOT_THREADS_NEW, PLOT_THREADS_ADVANCED, PLOT_THREADS_RESOLVED, FORESHADOWING
- **Relationships**: NPC_RELATIONSHIPS_CHANGED, PROMISES_MADE, FACTION_STANDING_CHANGES
- **World State**: LOCATIONS_DISCOVERED, LOCATIONS_ALTERED, POWER_SHIFTS, TIME_SENSITIVE_EVENTS
- **Combat**: COMBAT_TACTICS_EFFECTIVE, COMBAT_TACTICS_FAILED, ENEMY_INTEL_REVEALED
- **Loot**: ITEMS_ACQUIRED
- **Unresolved**: OPEN_QUESTIONS, UNFINISHED_BUSINESS, NEXT_SCENE_HOOKS
- **Meta**: CRITICAL_ROLLS, CHARACTER_DEVELOPMENT_MOMENTS, CREATIVE_SOLUTIONS
- **Timestamps**: UPDATED_AT

## SQL Scripts

- `generate_scene_summaries.sql`: AI-powered scene processing stored procedures
- `create_final_table.sql`: Final messages table creation
- `create_stg_table.sql`: Staging table setup
- `ai_processing.sql`: AI processing utilities
- `clean-up_stg.sql`: Data cleanup procedures
- `export_narrative_and_metadata.sql`: Export utilities
- `create_thread_ddl.sql`: Thread table definitions

## Data Directory

The `DATA/` directory contains:
- Session transcripts (t1.json through t20.json)
- Scene metadata CSV files
- Campaign narrative exports

## Future Enhancements

- Implement save functionality in the Streamlit app to write changes back to the database
- Add data validation for array and JSON fields
- Implement search and filter capabilities across scenes
- Add visualizations for plot threads and NPC relationships
- Export functionality for campaign summaries

## Prerequisites

- Snowflake account with Cortex AI enabled
- Snowflake CLI installed for Streamlit deployment
- Access to WPA database and DATA schema
- Appropriate permissions for table creation and Streamlit deployment
