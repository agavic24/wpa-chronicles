"""
Scene Metadata Editor - Streamlit Application
==============================================
A Streamlit app for viewing and editing D&D campaign scene metadata.
Allows users to select a scene and modify its metadata fields while 
preserving SCENE_NUM and UPDATED_AT as read-only.
"""

import streamlit as st
from snowflake.snowpark.context import get_active_session
import pandas as pd

# Initialize Snowflake session
session = get_active_session()

# Set page configuration
st.set_page_config(
    page_title="Scene Metadata Editor",
    page_icon="🎲",
    layout="wide"
)

# App title and description
st.title("🎲 D&D Scene Metadata Editor")
st.markdown("View and edit campaign scene metadata from the SCENE_METADATA table.")

# Query all scene metadata from the database
@st.cache_data
def load_scene_numbers():
    """Load all available scene numbers from the database."""
    query = "SELECT SCENE_NUM FROM WPA.DATA.SCENE_METADATA ORDER BY SCENE_NUM"
    df = session.sql(query).to_pandas()
    return df['SCENE_NUM'].tolist()

@st.cache_data
def load_scene_data(scene_num):
    """Load all data for a specific scene."""
    query = f"""
        SELECT 
            SCENE_NUM,
            SCENE_TITLE,
            SCENE_TYPE,
            ALL_LOCATIONS,
            PARTY_MEMBERS_ACTIVE,
            NPCS_ENCOUNTERED,
            ENEMIES_FACED,
            PLOT_THREADS_NEW,
            PLOT_THREADS_ADVANCED,
            PLOT_THREADS_RESOLVED,
            FORESHADOWING,
            NPC_RELATIONSHIPS_CHANGED,
            PROMISES_MADE,
            FACTION_STANDING_CHANGES,
            LOCATIONS_DISCOVERED,
            LOCATIONS_ALTERED,
            POWER_SHIFTS,
            TIME_SENSITIVE_EVENTS,
            COMBAT_TACTICS_EFFECTIVE,
            COMBAT_TACTICS_FAILED,
            ENEMY_INTEL_REVEALED,
            ITEMS_ACQUIRED,
            OPEN_QUESTIONS,
            UNFINISHED_BUSINESS,
            NEXT_SCENE_HOOKS,
            CRITICAL_ROLLS,
            CHARACTER_DEVELOPMENT_MOMENTS,
            CREATIVE_SOLUTIONS,
            UPDATED_AT
        FROM WPA.DATA.SCENE_METADATA
        WHERE SCENE_NUM = {scene_num}
    """
    df = session.sql(query).to_pandas()
    return df

# Load scene numbers for dropdown
try:
    scene_numbers = load_scene_numbers()
    
    if not scene_numbers:
        st.warning("No scenes found in the SCENE_METADATA table.")
        st.stop()
    
    # Dropdown to select scene number
    st.sidebar.header("Scene Selection")
    selected_scene = st.sidebar.selectbox(
        "Select Scene Number:",
        options=scene_numbers,
        index=0
    )
    
    # Display scene count
    st.sidebar.info(f"Total Scenes: {len(scene_numbers)}")
    
    # Load selected scene data
    scene_data = load_scene_data(selected_scene)
    
    if scene_data.empty:
        st.error(f"No data found for Scene {selected_scene}")
        st.stop()
    
    # Display scene header
    st.header(f"Scene {selected_scene}")
    if scene_data['SCENE_TITLE'].iloc[0]:
        st.subheader(scene_data['SCENE_TITLE'].iloc[0])
    
    # Define column configuration for the data editor
    # SCENE_NUM and UPDATED_AT are disabled (read-only)
    column_config = {
        "SCENE_NUM": st.column_config.NumberColumn(
            "Scene Number",
            disabled=True,
            help="Scene number (read-only)"
        ),
        "UPDATED_AT": st.column_config.DatetimeColumn(
            "Last Updated",
            disabled=True,
            help="Last update timestamp (read-only)",
            format="YYYY-MM-DD HH:mm:ss"
        ),
        "SCENE_TITLE": st.column_config.TextColumn(
            "Scene Title",
            help="The title of this scene"
        ),
        "SCENE_TYPE": st.column_config.TextColumn(
            "Scene Type",
            help="Type of scene (e.g., Combat, Social, Exploration)"
        ),
        "ALL_LOCATIONS": st.column_config.TextColumn(
            "All Locations",
            help="Array of locations visited"
        ),
        "PARTY_MEMBERS_ACTIVE": st.column_config.TextColumn(
            "Party Members Active",
            help="Array of active party members"
        ),
        "NPCS_ENCOUNTERED": st.column_config.TextColumn(
            "NPCs Encountered",
            help="JSON array of NPC encounters"
        ),
        "ENEMIES_FACED": st.column_config.TextColumn(
            "Enemies Faced",
            help="JSON array of enemies encountered"
        ),
        "PLOT_THREADS_NEW": st.column_config.TextColumn(
            "New Plot Threads",
            help="Array of new plot threads introduced"
        ),
        "PLOT_THREADS_ADVANCED": st.column_config.TextColumn(
            "Plot Threads Advanced",
            help="Array of plot threads that progressed"
        ),
        "PLOT_THREADS_RESOLVED": st.column_config.TextColumn(
            "Plot Threads Resolved",
            help="Array of plot threads completed"
        ),
        "FORESHADOWING": st.column_config.TextColumn(
            "Foreshadowing",
            help="Array of hints about future events"
        ),
        "NPC_RELATIONSHIPS_CHANGED": st.column_config.TextColumn(
            "NPC Relationships Changed",
            help="JSON array of relationship changes"
        ),
        "PROMISES_MADE": st.column_config.TextColumn(
            "Promises Made",
            help="Array of promises made"
        ),
        "FACTION_STANDING_CHANGES": st.column_config.TextColumn(
            "Faction Standing Changes",
            help="JSON array of faction reputation changes"
        ),
        "LOCATIONS_DISCOVERED": st.column_config.TextColumn(
            "Locations Discovered",
            help="Array of new locations found"
        ),
        "LOCATIONS_ALTERED": st.column_config.TextColumn(
            "Locations Altered",
            help="Array of locations that changed"
        ),
        "POWER_SHIFTS": st.column_config.TextColumn(
            "Power Shifts",
            help="Array of political/magical power changes"
        ),
        "TIME_SENSITIVE_EVENTS": st.column_config.TextColumn(
            "Time Sensitive Events",
            help="Array of deadlines or countdowns"
        ),
        "COMBAT_TACTICS_EFFECTIVE": st.column_config.TextColumn(
            "Effective Combat Tactics",
            help="Array of tactics that worked well"
        ),
        "COMBAT_TACTICS_FAILED": st.column_config.TextColumn(
            "Failed Combat Tactics",
            help="Array of tactics that didn't work"
        ),
        "ENEMY_INTEL_REVEALED": st.column_config.TextColumn(
            "Enemy Intel Revealed",
            help="JSON object with enemy information"
        ),
        "ITEMS_ACQUIRED": st.column_config.TextColumn(
            "Items Acquired",
            help="JSON array of items obtained"
        ),
        "OPEN_QUESTIONS": st.column_config.TextColumn(
            "Open Questions",
            help="Array of unanswered mysteries"
        ),
        "UNFINISHED_BUSINESS": st.column_config.TextColumn(
            "Unfinished Business",
            help="Array of incomplete tasks"
        ),
        "NEXT_SCENE_HOOKS": st.column_config.TextColumn(
            "Next Scene Hooks",
            help="Array of story hooks for future scenes"
        ),
        "CRITICAL_ROLLS": st.column_config.TextColumn(
            "Critical Rolls",
            help="JSON array of critical roll moments"
        ),
        "CHARACTER_DEVELOPMENT_MOMENTS": st.column_config.TextColumn(
            "Character Development Moments",
            help="Array of character growth moments"
        ),
        "CREATIVE_SOLUTIONS": st.column_config.TextColumn(
            "Creative Solutions",
            help="Array of clever player solutions"
        )
    }
    
    # Display the data editor with disabled fields
    st.markdown("### Edit Scene Metadata")
    
    # Create a separate data_editor widget for each editable column
    # Each widget shows one editable column with SCENE_NUM as a hidden index
    edited_data = scene_data.copy()
    
    # Define the editable columns (excluding SCENE_NUM and UPDATED_AT)
    editable_columns = [
        "SCENE_TITLE",
        "SCENE_TYPE",
        "ALL_LOCATIONS",
        "PARTY_MEMBERS_ACTIVE",
        "NPCS_ENCOUNTERED",
        "ENEMIES_FACED",
        "PLOT_THREADS_NEW",
        "PLOT_THREADS_ADVANCED",
        "PLOT_THREADS_RESOLVED",
        "FORESHADOWING",
        "NPC_RELATIONSHIPS_CHANGED",
        "PROMISES_MADE",
        "FACTION_STANDING_CHANGES",
        "LOCATIONS_DISCOVERED",
        "LOCATIONS_ALTERED",
        "POWER_SHIFTS",
        "TIME_SENSITIVE_EVENTS",
        "COMBAT_TACTICS_EFFECTIVE",
        "COMBAT_TACTICS_FAILED",
        "ENEMY_INTEL_REVEALED",
        "ITEMS_ACQUIRED",
        "OPEN_QUESTIONS",
        "UNFINISHED_BUSINESS",
        "NEXT_SCENE_HOOKS",
        "CRITICAL_ROLLS",
        "CHARACTER_DEVELOPMENT_MOMENTS",
        "CREATIVE_SOLUTIONS"
    ]
    
    # Display each editable column in its own data_editor widget
    # Each widget shows the editable column with SCENE_NUM as a hidden index
    for col in editable_columns:
        if col in scene_data.columns:
            # Create a dataframe with SCENE_NUM and the editable column
            col_df = scene_data[["SCENE_NUM", col]].copy()
            # Set SCENE_NUM as the index (position 0)
            col_df = col_df.set_index("SCENE_NUM")
            
            # Create column config for the editable column
            col_config = {
                col: column_config[col] if col in column_config else {}
            }
            
            # Display the data editor with SCENE_NUM as hidden index
            edited_col = st.data_editor(
                col_df,
                column_config=col_config,
                use_container_width=True,
                num_rows="fixed",
                hide_index=True,  # Hide the index (SCENE_NUM)
                key=f"editor_{selected_scene}_{col}"
            )
            
            # Update the edited_data with changes from the editable column
            edited_data[col] = edited_col[col].values
    
    if st.button("🔄 Refresh Data"):
        st.cache_data.clear()
        st.rerun()
    
    # Display data summary in sidebar
    st.sidebar.markdown("---")
    st.sidebar.header("Scene Summary")
    st.sidebar.write(f"**Scene Type:** {scene_data['SCENE_TYPE'].iloc[0] or 'N/A'}")
    st.sidebar.write(f"**Last Updated:** {scene_data['UPDATED_AT'].iloc[0]}")
    
except Exception as e:
    st.error(f"Error loading data: {str(e)}")
    st.exception(e)

