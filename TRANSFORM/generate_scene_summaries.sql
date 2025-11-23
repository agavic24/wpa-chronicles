USE ROLE SYSADMIN;
USE SCHEMA WPA.DATA;

-- ============================================================================
-- SCENE SUMMARY GENERATION PROCEDURE
-- ============================================================================
-- This procedure uses TWO separate AI_COMPLETE calls to generate:
-- 1. NARRATIVE: Engaging story summaries using narrative text from last 3 scenes
--               and key moments from all prior scenes
-- 2. METADATA: Structured campaign data using key moments and metadata from 
--              all prior scenes
-- ============================================================================

-- Create SCENE_NARRATIVE table for player-facing stories
CREATE OR REPLACE TABLE SCENE_NARRATIVE (
    SCENE_NUM INTEGER PRIMARY KEY,
    SCENE_TITLE VARCHAR,
    SCENE_TYPE VARCHAR,
    PRIMARY_LOCATION VARCHAR,
    NARRATIVE_TEXT VARCHAR(16777216), -- Long text for rich narrative
    KEY_MOMENTS VARCHAR(16777216),    -- Highlights and memorable moments
    MEMORABLE_QUOTES VARCHAR(16777216), -- Direct quotes from SCENE
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Create SCENE_METADATA table for campaign arc tracking
--CREATE TABLE IF NOT EXISTS SCENE_METADATA (
CREATE OR REPLACE TABLE SCENE_METADATA (
    SCENE_NUM INTEGER PRIMARY KEY,
    SCENE_TITLE VARCHAR,
    SCENE_TYPE VARCHAR,
    
    -- Location & Character Data
    ALL_LOCATIONS ARRAY,
    PARTY_MEMBERS_ACTIVE ARRAY,
    NPCS_ENCOUNTERED VARIANT, -- [{name, role, disposition, info}]
    ENEMIES_FACED VARIANT,     -- [{type, tactics, outcome}]
    
    -- Plot Thread Tracking
    PLOT_THREADS_NEW ARRAY,
    PLOT_THREADS_ADVANCED ARRAY,
    PLOT_THREADS_RESOLVED ARRAY,
    FORESHADOWING ARRAY,
    
    -- Relationships & Reputation
    NPC_RELATIONSHIPS_CHANGED VARIANT, -- [{npc, change, reason}]
    PROMISES_MADE ARRAY,
    FACTION_STANDING_CHANGES VARIANT,
    
    -- World State
    LOCATIONS_DISCOVERED ARRAY,
    LOCATIONS_ALTERED ARRAY,
    POWER_SHIFTS ARRAY,
    TIME_SENSITIVE_EVENTS ARRAY,
    
    -- Tactical Intelligence
    COMBAT_TACTICS_EFFECTIVE ARRAY,
    COMBAT_TACTICS_FAILED ARRAY,
    ENEMY_INTEL_REVEALED VARIANT,
    
    -- Loot & Progression
    ITEMS_ACQUIRED VARIANT,
    
    -- Unresolved Items
    OPEN_QUESTIONS ARRAY,
    UNFINISHED_BUSINESS ARRAY,
    NEXT_SCENE_HOOKS ARRAY,
    
    -- Meta Information
    CRITICAL_ROLLS VARIANT,
    CHARACTER_DEVELOPMENT_MOMENTS ARRAY,
    CREATIVE_SOLUTIONS ARRAY,
    
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Update SCENE_METADATA table to rename CREATED_AT to UPDATED_AT
ALTER TABLE WPA.DATA.SCENE_METADATA RENAME COLUMN CREATED_AT TO UPDATED_AT;



-- ============================================================================
-- Stored Procedure: Generate Scene Summary
-- ============================================================================
-- Parameters:
--   SCENE_num_param: The scene number to process
--   JUST_NARRATIVE_IND: Optional boolean (default FALSE). When TRUE:
--                       - Skips Step 5B (AI_COMPLETE for METADATA)
--                       - Skips Step 7 (database delete/insert for SCENE_METADATA)
-- ============================================================================
DROP PROCEDURE IF EXISTS generate_scene_summary(INTEGER, BOOLEAN);
DROP PROCEDURE IF EXISTS generate_scene_summary(INTEGER);

CREATE OR REPLACE PROCEDURE generate_scene_summary(
    SCENE_num_param INTEGER,
    JUST_NARRATIVE_IND BOOLEAN DEFAULT FALSE
)
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
DECLARE
    -- Variables for current SCENE
    current_SCENE_count INTEGER;
    current_SCENE_title VARCHAR;
    current_SCENE_type VARCHAR;
    current_location VARCHAR;
    SCENE_messages VARCHAR;
    
    -- Variables for building narrative context (for narrative generation)
    narrative_context_rs RESULTSET;
    narrative_context_text VARCHAR DEFAULT '';
    n_scene_num INTEGER;
    n_scene_title VARCHAR;
    n_narrative_text VARCHAR;
    n_key_moments VARCHAR;
    narrative_scene_count INTEGER DEFAULT 0;
    
    -- Variables for building metadata context (for metadata generation)
    metadata_context_rs RESULTSET;
    metadata_context_text VARCHAR DEFAULT '';
    scene_block VARCHAR;
    m_scene_num INTEGER;
    m_scene_title VARCHAR;
    m_scene_type VARCHAR;
    m_key_moments VARCHAR;
    m_all_locations ARRAY;
    m_party_members_active ARRAY;
    m_npcs_encountered VARIANT;
    m_enemies_faced VARIANT;
    m_plot_threads_new ARRAY;
    m_plot_threads_advanced ARRAY;
    m_plot_threads_resolved ARRAY;
    m_foreshadowing ARRAY;
    m_npc_relationships_changed VARIANT;
    m_promises_made ARRAY;
    m_faction_standing_changes VARIANT;
    m_locations_discovered ARRAY;
    m_locations_altered ARRAY;
    m_power_shifts ARRAY;
    m_time_sensitive_events ARRAY;
    m_combat_tactics_effective ARRAY;
    m_combat_tactics_failed ARRAY;
    m_enemy_intel_revealed VARIANT;
    m_items_acquired VARIANT;
    m_open_questions ARRAY;
    m_unfinished_business ARRAY;
    m_next_scene_hooks ARRAY;
    m_critical_rolls VARIANT;
    m_character_development_moments ARRAY;
    m_creative_solutions ARRAY;
    
    -- AI processing variables
    narrative_prompt VARCHAR;
    metadata_prompt VARCHAR;
    narrative_ai_response VARIANT;
    metadata_ai_response VARIANT;
    narrative_ai_raw_response VARCHAR;
    metadata_ai_raw_response VARCHAR;
    
BEGIN
    -- ========================================================================
    -- STEP 1: Validate SCENE exists
    -- ========================================================================
    SELECT COUNT(*) INTO :current_SCENE_count
    FROM FINAL_MESSAGES
    WHERE SESSION_NUM = :SCENE_num_param;
    
    IF (:current_SCENE_count = 0) THEN
        RETURN 'ERROR: SCENE ' || :SCENE_num_param || ' not found in FINAL_MESSAGES';
    END IF;
    
    -- ========================================================================
    -- STEP 2: Get current SCENE data
    -- ========================================================================
    BEGIN
        SELECT 
            MAX(SESSION_TITLE),
            MAX(SESSION_TYPE),
            MAX(LOCATION_NAME)
        INTO :current_SCENE_title, :current_SCENE_type, :current_location
        FROM FINAL_MESSAGES
        WHERE SESSION_NUM = :SCENE_num_param;
        
        IF (:current_SCENE_title IS NULL) THEN
            RETURN 'ERROR: Could not retrieve scene data for SCENE ' || :SCENE_num_param;
        END IF;
        
        -- Aggregate all messages for this SCENE
        SELECT LISTAGG(
            CASE 
                WHEN CHARACTER_NAME = 'Dungeon Master' THEN 
                    '🎭 DM: ' || MESSAGE
                ELSE 
                    '🗣️ ' || CHARACTER_NAME || ': ' || MESSAGE
            END,
            '\n'
        ) WITHIN GROUP (ORDER BY THREAD_MSG_NUM)
        INTO :SCENE_messages
        FROM FINAL_MESSAGES
        WHERE SESSION_NUM = :SCENE_num_param;
        
        IF (:SCENE_messages IS NULL OR :SCENE_messages = '') THEN
            RETURN 'ERROR: No messages found for SCENE ' || :SCENE_num_param;
        END IF;
    EXCEPTION
        WHEN OTHER THEN
            RETURN 'ERROR: Failed to retrieve scene data for SCENE ' || :SCENE_num_param || ': ' || SQLERRM;
    END;
    
    -- ========================================================================
    -- STEP 3A: Build NARRATIVE context (for narrative generation)
    -- ========================================================================
    -- Get narrative text from last 3 scenes + key moments from ALL scenes
    
    BEGIN
        -- Get ALL prior scenes' key moments (oldest to newest)
        narrative_context_rs := (
            SELECT 
                SCENE_NUM,
                SCENE_TITLE,
                KEY_MOMENTS
            FROM SCENE_NARRATIVE
            WHERE SCENE_NUM < :SCENE_num_param
            ORDER BY SCENE_NUM ASC
        );
        
        narrative_context_text := '## KEY MOMENTS FROM ALL PRIOR SCENES:\n';
        
        FOR record IN narrative_context_rs DO
            n_scene_num := record.SCENE_NUM;
            n_scene_title := record.SCENE_TITLE;
            n_key_moments := record.KEY_MOMENTS;
            
            IF (n_key_moments IS NOT NULL AND n_key_moments != '' AND n_key_moments != '[]' AND n_key_moments != 'null') THEN
                narrative_context_text := narrative_context_text || 
                    '\nScene ' || n_scene_num || ' (' || COALESCE(n_scene_title, 'Untitled') || '):\n' ||
                    n_key_moments || '\n';
            END IF;
        END FOR;
        
        -- Now get NARRATIVE TEXT from last 3 scenes (newest to oldest for context building)
        narrative_context_rs := (
            SELECT 
                SCENE_NUM,
                SCENE_TITLE,
                NARRATIVE_TEXT
            FROM SCENE_NARRATIVE
            WHERE SCENE_NUM < :SCENE_num_param
            ORDER BY SCENE_NUM DESC
            LIMIT 3
        );
        
        narrative_context_text := narrative_context_text || '\n\n## NARRATIVE TEXT FROM LAST 3 SCENES:\n';
        
        FOR record IN narrative_context_rs DO
            n_scene_num := record.SCENE_NUM;
            n_scene_title := record.SCENE_TITLE;
            n_narrative_text := record.NARRATIVE_TEXT;
            
            IF (n_narrative_text IS NOT NULL AND n_narrative_text != '' AND n_narrative_text != 'null') THEN
                narrative_context_text := narrative_context_text || 
                    '\n--- Scene ' || n_scene_num || ': ' || COALESCE(n_scene_title, 'Untitled') || ' ---\n' ||
                    n_narrative_text || '\n';
            END IF;
        END FOR;
        
        IF (narrative_context_text = '## KEY MOMENTS FROM ALL PRIOR SCENES:\n\n\n## NARRATIVE TEXT FROM LAST 3 SCENES:\n' 
            OR narrative_context_text IS NULL) THEN
            narrative_context_text := 'This is the first SCENE - no prior narrative history available.';
        END IF;
    END;
    
    -- ========================================================================
    -- STEP 3B: Build METADATA context (for metadata generation)
    -- ========================================================================
    -- Get key moments from ALL scenes + metadata from ALL scenes
    
    BEGIN
        -- First get all key moments from SCENE_NARRATIVE
        narrative_context_rs := (
            SELECT 
                SCENE_NUM,
                SCENE_TITLE,
                KEY_MOMENTS
            FROM SCENE_NARRATIVE
            WHERE SCENE_NUM < :SCENE_num_param
            ORDER BY SCENE_NUM ASC
        );
        
        metadata_context_text := '## KEY MOMENTS FROM ALL PRIOR SCENES:\n';
        
        FOR record IN narrative_context_rs DO
            n_scene_num := record.SCENE_NUM;
            n_scene_title := record.SCENE_TITLE;
            n_key_moments := record.KEY_MOMENTS;
            
            IF (n_key_moments IS NOT NULL AND n_key_moments != '' AND n_key_moments != '[]' AND n_key_moments != 'null') THEN
                metadata_context_text := metadata_context_text || 
                    '\nScene ' || n_scene_num || ' (' || COALESCE(n_scene_title, 'Untitled') || '):\n' ||
                    n_key_moments || '\n';
            END IF;
        END FOR;
        
        -- Now get all metadata from SCENE_METADATA
        metadata_context_rs := (
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
                CREATIVE_SOLUTIONS
            FROM SCENE_METADATA
            WHERE SCENE_NUM < :SCENE_num_param
            ORDER BY SCENE_NUM ASC
        );
        
        metadata_context_text := metadata_context_text || '\n\n## METADATA FROM ALL PRIOR SCENES:\n';
        
        FOR record IN metadata_context_rs DO
            m_scene_num := record.SCENE_NUM;
            m_scene_title := record.SCENE_TITLE;
            m_scene_type := record.SCENE_TYPE;
            m_all_locations := record.ALL_LOCATIONS;
            m_party_members_active := record.PARTY_MEMBERS_ACTIVE;
            m_npcs_encountered := record.NPCS_ENCOUNTERED;
            m_enemies_faced := record.ENEMIES_FACED;
            m_plot_threads_new := record.PLOT_THREADS_NEW;
            m_plot_threads_advanced := record.PLOT_THREADS_ADVANCED;
            m_plot_threads_resolved := record.PLOT_THREADS_RESOLVED;
            m_foreshadowing := record.FORESHADOWING;
            m_npc_relationships_changed := record.NPC_RELATIONSHIPS_CHANGED;
            m_promises_made := record.PROMISES_MADE;
            m_faction_standing_changes := record.FACTION_STANDING_CHANGES;
            m_locations_discovered := record.LOCATIONS_DISCOVERED;
            m_locations_altered := record.LOCATIONS_ALTERED;
            m_power_shifts := record.POWER_SHIFTS;
            m_time_sensitive_events := record.TIME_SENSITIVE_EVENTS;
            m_combat_tactics_effective := record.COMBAT_TACTICS_EFFECTIVE;
            m_combat_tactics_failed := record.COMBAT_TACTICS_FAILED;
            m_enemy_intel_revealed := record.ENEMY_INTEL_REVEALED;
            m_items_acquired := record.ITEMS_ACQUIRED;
            m_open_questions := record.OPEN_QUESTIONS;
            m_unfinished_business := record.UNFINISHED_BUSINESS;
            m_next_scene_hooks := record.NEXT_SCENE_HOOKS;
            m_critical_rolls := record.CRITICAL_ROLLS;
            m_character_development_moments := record.CHARACTER_DEVELOPMENT_MOMENTS;
            m_creative_solutions := record.CREATIVE_SOLUTIONS;
            
            -- Start building this scene's metadata block
            scene_block := '\n--- SCENE ' || m_scene_num || ': ' || COALESCE(m_scene_title, 'Untitled') || 
                          ' (' || COALESCE(m_scene_type, 'Unknown') || ') ---\n';
            
            -- Add each metadata field only if it has a value
            IF (m_all_locations IS NOT NULL AND ARRAY_SIZE(m_all_locations) > 0) THEN
                scene_block := scene_block || 'Locations: ' || ARRAY_TO_STRING(m_all_locations, ', ') || '\n';
            END IF;
            
            IF (m_party_members_active IS NOT NULL AND ARRAY_SIZE(m_party_members_active) > 0) THEN
                scene_block := scene_block || 'Party Active: ' || ARRAY_TO_STRING(m_party_members_active, ', ') || '\n';
            END IF;
            
            IF (m_npcs_encountered IS NOT NULL AND m_npcs_encountered::VARCHAR != '[]' AND m_npcs_encountered::VARCHAR != 'null') THEN
                scene_block := scene_block || 'NPCs Encountered: ' || m_npcs_encountered::VARCHAR || '\n';
            END IF;
            
            IF (m_enemies_faced IS NOT NULL AND m_enemies_faced::VARCHAR != '[]' AND m_enemies_faced::VARCHAR != 'null') THEN
                scene_block := scene_block || 'Enemies Faced: ' || m_enemies_faced::VARCHAR || '\n';
            END IF;
            
            IF (m_plot_threads_new IS NOT NULL AND ARRAY_SIZE(m_plot_threads_new) > 0) THEN
                scene_block := scene_block || 'New Plot Threads: ' || ARRAY_TO_STRING(m_plot_threads_new, '; ') || '\n';
            END IF;
            
            IF (m_plot_threads_advanced IS NOT NULL AND ARRAY_SIZE(m_plot_threads_advanced) > 0) THEN
                scene_block := scene_block || 'Plot Threads Advanced: ' || ARRAY_TO_STRING(m_plot_threads_advanced, '; ') || '\n';
            END IF;
            
            IF (m_plot_threads_resolved IS NOT NULL AND ARRAY_SIZE(m_plot_threads_resolved) > 0) THEN
                scene_block := scene_block || 'Plot Threads Resolved: ' || ARRAY_TO_STRING(m_plot_threads_resolved, '; ') || '\n';
            END IF;
            
            IF (m_foreshadowing IS NOT NULL AND ARRAY_SIZE(m_foreshadowing) > 0) THEN
                scene_block := scene_block || 'Foreshadowing: ' || ARRAY_TO_STRING(m_foreshadowing, '; ') || '\n';
            END IF;
            
            IF (m_npc_relationships_changed IS NOT NULL AND m_npc_relationships_changed::VARCHAR != '[]' AND m_npc_relationships_changed::VARCHAR != 'null') THEN
                scene_block := scene_block || 'NPC Relationships Changed: ' || m_npc_relationships_changed::VARCHAR || '\n';
            END IF;
            
            IF (m_promises_made IS NOT NULL AND ARRAY_SIZE(m_promises_made) > 0) THEN
                scene_block := scene_block || 'Promises Made: ' || ARRAY_TO_STRING(m_promises_made, '; ') || '\n';
            END IF;
            
            IF (m_faction_standing_changes IS NOT NULL AND m_faction_standing_changes::VARCHAR != '[]' AND m_faction_standing_changes::VARCHAR != 'null') THEN
                scene_block := scene_block || 'Faction Standing Changes: ' || m_faction_standing_changes::VARCHAR || '\n';
            END IF;
            
            IF (m_locations_discovered IS NOT NULL AND ARRAY_SIZE(m_locations_discovered) > 0) THEN
                scene_block := scene_block || 'Locations Discovered: ' || ARRAY_TO_STRING(m_locations_discovered, ', ') || '\n';
            END IF;
            
            IF (m_locations_altered IS NOT NULL AND ARRAY_SIZE(m_locations_altered) > 0) THEN
                scene_block := scene_block || 'Locations Altered: ' || ARRAY_TO_STRING(m_locations_altered, '; ') || '\n';
            END IF;
            
            IF (m_power_shifts IS NOT NULL AND ARRAY_SIZE(m_power_shifts) > 0) THEN
                scene_block := scene_block || 'Power Shifts: ' || ARRAY_TO_STRING(m_power_shifts, '; ') || '\n';
            END IF;
            
            IF (m_time_sensitive_events IS NOT NULL AND ARRAY_SIZE(m_time_sensitive_events) > 0) THEN
                scene_block := scene_block || 'Time Sensitive Events: ' || ARRAY_TO_STRING(m_time_sensitive_events, '; ') || '\n';
            END IF;
            
            IF (m_combat_tactics_effective IS NOT NULL AND ARRAY_SIZE(m_combat_tactics_effective) > 0) THEN
                scene_block := scene_block || 'Effective Combat Tactics: ' || ARRAY_TO_STRING(m_combat_tactics_effective, '; ') || '\n';
            END IF;
            
            IF (m_combat_tactics_failed IS NOT NULL AND ARRAY_SIZE(m_combat_tactics_failed) > 0) THEN
                scene_block := scene_block || 'Failed Combat Tactics: ' || ARRAY_TO_STRING(m_combat_tactics_failed, '; ') || '\n';
            END IF;
            
            IF (m_enemy_intel_revealed IS NOT NULL AND m_enemy_intel_revealed::VARCHAR != '{}' AND m_enemy_intel_revealed::VARCHAR != 'null') THEN
                scene_block := scene_block || 'Enemy Intel Revealed: ' || m_enemy_intel_revealed::VARCHAR || '\n';
            END IF;
            
            IF (m_items_acquired IS NOT NULL AND m_items_acquired::VARCHAR != '[]' AND m_items_acquired::VARCHAR != 'null') THEN
                scene_block := scene_block || 'Items Acquired: ' || m_items_acquired::VARCHAR || '\n';
            END IF;
            
            IF (m_open_questions IS NOT NULL AND ARRAY_SIZE(m_open_questions) > 0) THEN
                scene_block := scene_block || 'Open Questions: ' || ARRAY_TO_STRING(m_open_questions, '; ') || '\n';
            END IF;
            
            IF (m_unfinished_business IS NOT NULL AND ARRAY_SIZE(m_unfinished_business) > 0) THEN
                scene_block := scene_block || 'Unfinished Business: ' || ARRAY_TO_STRING(m_unfinished_business, '; ') || '\n';
            END IF;
            
            IF (m_next_scene_hooks IS NOT NULL AND ARRAY_SIZE(m_next_scene_hooks) > 0) THEN
                scene_block := scene_block || 'Next Scene Hooks: ' || ARRAY_TO_STRING(m_next_scene_hooks, '; ') || '\n';
            END IF;
            
            IF (m_critical_rolls IS NOT NULL AND m_critical_rolls::VARCHAR != '[]' AND m_critical_rolls::VARCHAR != 'null') THEN
                scene_block := scene_block || 'Critical Rolls: ' || m_critical_rolls::VARCHAR || '\n';
            END IF;
            
            IF (m_character_development_moments IS NOT NULL AND ARRAY_SIZE(m_character_development_moments) > 0) THEN
                scene_block := scene_block || 'Character Development: ' || ARRAY_TO_STRING(m_character_development_moments, '; ') || '\n';
            END IF;
            
            IF (m_creative_solutions IS NOT NULL AND ARRAY_SIZE(m_creative_solutions) > 0) THEN
                scene_block := scene_block || 'Creative Solutions: ' || ARRAY_TO_STRING(m_creative_solutions, '; ') || '\n';
            END IF;
            
            -- Append this scene's metadata block to the overall context
            metadata_context_text := metadata_context_text || scene_block;
        END FOR;
        
        -- If no prior metadata context, set a default message
        IF (metadata_context_text = '## KEY MOMENTS FROM ALL PRIOR SCENES:\n\n\n## METADATA FROM ALL PRIOR SCENES:\n' 
            OR metadata_context_text IS NULL) THEN
            metadata_context_text := 'This is the first SCENE - no prior metadata history available.';
        END IF;
    END;
    
    -- ========================================================================
    -- STEP 4A: Build NARRATIVE AI prompt
    -- ========================================================================
    narrative_prompt := '# D&D SCENE NARRATIVE GENERATION

You are a master storyteller and narrator of a D&D campaign. 
Summarize the following D&D scene as DM would recap players at the start of the next session; make it dramatic yet concise on details.
Maintain a consistent, rich, and immersive tone and voice across scenes.
Write as if part of an ongoing saga, with callback to past sessions and characters when appropriate.

CRITICAL: The first 5 words of the opening sentence MUST be unique to THIS specific scene. DO NOT reuse or copy opening sentences from the prior narrative examples.

## SCENE CONTEXT
**SCENE Number:** ' || :SCENE_num_param || '
**SCENE Title:** ' || COALESCE(:current_SCENE_title, 'Untitled') || '
**SCENE Type:** ' || COALESCE(:current_SCENE_type, 'UNKNOWN') || '
**Primary Location:** ' || COALESCE(:current_location, 'Unknown') || '

## PRIOR NARRATIVE CONTEXT - Write the next narrative in the same style.
' || :narrative_context_text || '

---

## CURRENT SCENE MESSAGES:
' || :SCENE_messages || '

---

# OUTPUT - narrative summary of the scene

1. "story": 2-10 vivid, engaging sentences that capture the scene. Make players FEEL the adventure. 
      Write an engaging narrative summary of this scene to engage the players. 
      Focus on atmosphere, drama, character moments, and emotional impact",
2.  "3 key moments": Optional. Key moments should be pithy and specifically useful for the DM to refer to 
      for campaign arc building, character development or plot advancement.
      They should not be generic moments that won\'t be useful beyond the current scene.
3.  "memorable_quotes": Optional. Quotes from the scene that are memorable, shocking, humorous, or otherwise noteworthy. Prefix the quote with the character\'s.

';

    -- ========================================================================
    -- STEP 4B: Build METADATA AI prompt
    -- ========================================================================
    metadata_prompt := '# D&D SCENE METADATA EXTRACTION

You are a meticulous chronicler tracking campaign continuity and details. Extract structured metadata from this scene \
for campaign tracking. Almost everything is optional - if you can''t find useful information, leave it blank.

## SCENE CONTEXT
**SCENE Number:** ' || :SCENE_num_param || '
**SCENE Title:** ' || COALESCE(:current_SCENE_title, 'Untitled') || '
**SCENE Type:** ' || COALESCE(:current_SCENE_type, 'UNKNOWN') || '
**Primary Location:** ' || COALESCE(:current_location, 'Unknown') || '

## PRIOR CAMPAIGN METADATA CONTEXT
' || :metadata_context_text || '

---

## CURRENT SCENE MESSAGES:
' || :SCENE_messages || '

---

# OUTPUT REQUIREMENTS

{
  "all_locations": ["location1", "location2"],
  "party_members_active": ["Character1: notable action", "Character2: notable action"],
  "npcs_encountered": [
    {"name": "NPC Name", "role": "their role", "disposition": "friendly/hostile/neutral", "info_revealed": "key info"}
  ],
  "enemies_faced": [
    {"type": "enemy type", "tactics": "how they fought", "outcome": "defeated/fled/ongoing"}
  ],
  "plot_threads_new": ["new quest or mystery introduced"],
  "plot_threads_advanced": ["existing thread that progressed"],
  "plot_threads_resolved": ["completed objectives"],
  "foreshadowing": ["hints about future events"],
  "npc_relationships_changed": [
    {"npc": "name", "change": "improved/worsened/complicated", "reason": "why"}
  ],
  "promises_made": ["promise to whom and what"],
  "faction_standing_changes": [
    {"faction": "name", "change": "positive/negative", "reason": "why"}
  ],
  "locations_discovered": ["new location names"],
  "locations_altered": ["location changed and how"],
  "power_shifts": ["political/magical/territorial changes"],
  "time_sensitive_events": ["deadlines or countdowns started"],
  "combat_tactics_effective": ["tactics that worked well"],
  "combat_tactics_failed": ["tactics that did not work"],
  "enemy_intel_revealed": {
    "weaknesses": ["weakness1"],
    "resistances": ["resistance1"],
    "abilities": ["special ability1"]
  },
  "items_acquired": [
    {"name": "item name", "type": "weapon/armor/consumable/magical", "properties": "description"}
  ],
  "open_questions": ["unanswered mystery or question"],
  "unfinished_business": ["interrupted or postponed task"],
  "next_SCENE_hooks": ["where story goes next"],
  "critical_rolls": [
    {"character": "name", "roll": "nat 20/nat 1", "context": "what happened", "impact": "consequence"}
  ],
  "character_development_moments": ["roleplay breakthrough or character growth moment"],
  "creative_solutions": ["clever player idea or unconventional solution"]
}
';

    -- ========================================================================
    -- STEP 5A: Call AI_COMPLETE to generate NARRATIVE
    -- ========================================================================
    BEGIN
        SELECT AI_COMPLETE(
            model => 'claude-4-sonnet',
            prompt => :narrative_prompt,
            response_format => {
                'type': 'json',
                'schema': {
                    'type': 'object',
                    'properties': {
                        'story': {'type': 'string'},
                        'key_moments': {'type': 'array', 'items': {'type': 'string'}},
                        'memorable_quotes': {'type': 'array', 'items': {'type': 'string'}}
                    },
                    'required': ['story', 'key_moments', 'memorable_quotes'],
                    'additionalProperties': false
                }
            }
        )::VARCHAR INTO :narrative_ai_raw_response;
        
        IF (:narrative_ai_raw_response IS NULL OR :narrative_ai_raw_response = '') THEN
            RETURN 'ERROR: AI_COMPLETE returned NULL or empty response for NARRATIVE in SCENE ' || :SCENE_num_param;
        END IF;
        
        SELECT PARSE_JSON(:narrative_ai_raw_response) INTO :narrative_ai_response;
        
    EXCEPTION
        WHEN OTHER THEN
            RETURN 'ERROR: Failed to parse AI narrative response for SCENE ' || :SCENE_num_param || ': ' || SQLERRM || 
                   '. Raw response: ' || SUBSTRING(:narrative_ai_raw_response, 1, 500);
    END;
    
    -- ========================================================================
    -- STEP 5B: Call AI_COMPLETE to generate METADATA
    -- ========================================================================
    IF (NOT :JUST_NARRATIVE_IND) THEN
        BEGIN
            SELECT AI_COMPLETE(
            model => 'claude-4-sonnet',
            prompt => :metadata_prompt,
            response_format => {
                'type': 'json',
                'schema': {
                    'type': 'object',
                    'properties': {
                        'all_locations': {'type': 'array', 'items': {'type': 'string'}},
                        'party_members_active': {'type': 'array', 'items': {'type': 'string'}},
                        'npcs_encountered': {
                            'type': 'array',
                            'items': {
                                'type': 'object',
                                'properties': {
                                    'name': {'type': 'string'},
                                    'role': {'type': 'string'},
                                    'disposition': {'type': 'string'},
                                    'info_revealed': {'type': 'string'}
                                },
                                'required': ['name', 'role', 'disposition', 'info_revealed'],
                                'additionalProperties': false
                            }
                        },
                        'enemies_faced': {
                            'type': 'array',
                            'items': {
                                'type': 'object',
                                'properties': {
                                    'type': {'type': 'string'},
                                    'tactics': {'type': 'string'},
                                    'outcome': {'type': 'string'}
                                },
                                'required': ['type', 'tactics', 'outcome'],
                                'additionalProperties': false
                            }
                        },
                        'plot_threads_new': {'type': 'array', 'items': {'type': 'string'}},
                        'plot_threads_advanced': {'type': 'array', 'items': {'type': 'string'}},
                        'plot_threads_resolved': {'type': 'array', 'items': {'type': 'string'}},
                        'foreshadowing': {'type': 'array', 'items': {'type': 'string'}},
                        'npc_relationships_changed': {
                            'type': 'array',
                            'items': {
                                'type': 'object',
                                'properties': {
                                    'npc': {'type': 'string'},
                                    'change': {'type': 'string'},
                                    'reason': {'type': 'string'}
                                },
                                'required': ['npc', 'change', 'reason'],
                                'additionalProperties': false
                            }
                        },
                        'promises_made': {'type': 'array', 'items': {'type': 'string'}},
                        'faction_standing_changes': {
                            'type': 'array',
                            'items': {
                                'type': 'object',
                                'properties': {
                                    'faction': {'type': 'string'},
                                    'change': {'type': 'string'},
                                    'reason': {'type': 'string'}
                                },
                                'required': ['faction', 'change', 'reason'],
                                'additionalProperties': false
                            }
                        },
                        'locations_discovered': {'type': 'array', 'items': {'type': 'string'}},
                        'locations_altered': {'type': 'array', 'items': {'type': 'string'}},
                        'power_shifts': {'type': 'array', 'items': {'type': 'string'}},
                        'time_sensitive_events': {'type': 'array', 'items': {'type': 'string'}},
                        'combat_tactics_effective': {'type': 'array', 'items': {'type': 'string'}},
                        'combat_tactics_failed': {'type': 'array', 'items': {'type': 'string'}},
                        'enemy_intel_revealed': {
                            'type': 'object',
                            'properties': {
                                'weaknesses': {'type': 'array', 'items': {'type': 'string'}},
                                'resistances': {'type': 'array', 'items': {'type': 'string'}},
                                'abilities': {'type': 'array', 'items': {'type': 'string'}}
                            },
                            'required': ['weaknesses', 'resistances', 'abilities'],
                            'additionalProperties': false
                        },
                        'items_acquired': {
                            'type': 'array',
                            'items': {
                                'type': 'object',
                                'properties': {
                                    'name': {'type': 'string'},
                                    'type': {'type': 'string'},
                                    'properties': {'type': 'string'}
                                },
                                'required': ['name', 'type', 'properties'],
                                'additionalProperties': false
                            }
                        },
                        'open_questions': {'type': 'array', 'items': {'type': 'string'}},
                        'unfinished_business': {'type': 'array', 'items': {'type': 'string'}},
                        'next_SCENE_hooks': {'type': 'array', 'items': {'type': 'string'}},
                        'critical_rolls': {
                            'type': 'array',
                            'items': {
                                'type': 'object',
                                'properties': {
                                    'character': {'type': 'string'},
                                    'roll': {'type': 'string'},
                                    'context': {'type': 'string'},
                                    'impact': {'type': 'string'}
                                },
                                'required': ['character', 'roll', 'context', 'impact'],
                                'additionalProperties': false
                            }
                        },
                        'character_development_moments': {'type': 'array', 'items': {'type': 'string'}},
                        'creative_solutions': {'type': 'array', 'items': {'type': 'string'}}
                    },
                    'required': ['all_locations', 'party_members_active', 'npcs_encountered', 'enemies_faced',
                                'plot_threads_new', 'plot_threads_advanced', 'plot_threads_resolved', 'foreshadowing',
                                'npc_relationships_changed', 'promises_made', 'faction_standing_changes',
                                'locations_discovered', 'locations_altered', 'power_shifts', 'time_sensitive_events',
                                'combat_tactics_effective', 'combat_tactics_failed', 'enemy_intel_revealed',
                                'items_acquired', 'open_questions', 'unfinished_business', 'next_SCENE_hooks',
                                'critical_rolls', 'character_development_moments', 'creative_solutions'],
                    'additionalProperties': false
                }
            }
        )::VARCHAR INTO :metadata_ai_raw_response;
        
        IF (:metadata_ai_raw_response IS NULL OR :metadata_ai_raw_response = '') THEN
            RETURN 'ERROR: AI_COMPLETE returned NULL or empty response for METADATA in SCENE ' || :SCENE_num_param;
        END IF;
        
        SELECT PARSE_JSON(:metadata_ai_raw_response) INTO :metadata_ai_response;
        
        EXCEPTION
            WHEN OTHER THEN
                RETURN 'ERROR: Failed to parse AI metadata response for SCENE ' || :SCENE_num_param || ': ' || SQLERRM || 
                       '. Raw response: ' || SUBSTRING(:metadata_ai_raw_response, 1, 500);
        END;
    END IF;
    
    -- ========================================================================
    -- STEP 6: Insert into SCENE_NARRATIVE table Using a delete and insert
    -- ========================================================================
    BEGIN
        DELETE FROM SCENE_NARRATIVE WHERE SCENE_NUM = :SCENE_num_param;
        INSERT INTO SCENE_NARRATIVE (SCENE_NUM, SCENE_TITLE, SCENE_TYPE, PRIMARY_LOCATION, NARRATIVE_TEXT, KEY_MOMENTS, MEMORABLE_QUOTES)
        SELECT 
            :SCENE_num_param,
            :current_SCENE_title,
            :current_SCENE_type,
            :current_location,
            :narrative_ai_response:story::VARCHAR,
            :narrative_ai_response:key_moments::VARCHAR,
            :narrative_ai_response:memorable_quotes::VARCHAR;
    EXCEPTION
        WHEN OTHER THEN
            RETURN 'ERROR: Failed to insert into SCENE_NARRATIVE for SCENE ' || :SCENE_num_param || ': ' || SQLERRM;
    END;
    
    -- ========================================================================
    -- STEP 7: Insert into SCENE_METADATA table using a delete and insert
    -- ========================================================================
    IF (NOT :JUST_NARRATIVE_IND) THEN
        BEGIN
            DELETE FROM SCENE_METADATA WHERE SCENE_NUM = :SCENE_num_param;
        INSERT INTO SCENE_METADATA (SCENE_NUM, SCENE_TITLE, SCENE_TYPE, ALL_LOCATIONS, PARTY_MEMBERS_ACTIVE, NPCS_ENCOUNTERED, ENEMIES_FACED, PLOT_THREADS_NEW, PLOT_THREADS_ADVANCED, PLOT_THREADS_RESOLVED, FORESHADOWING, NPC_RELATIONSHIPS_CHANGED, PROMISES_MADE, FACTION_STANDING_CHANGES, LOCATIONS_DISCOVERED, LOCATIONS_ALTERED, POWER_SHIFTS, TIME_SENSITIVE_EVENTS, COMBAT_TACTICS_EFFECTIVE, COMBAT_TACTICS_FAILED, ENEMY_INTEL_REVEALED, ITEMS_ACQUIRED, OPEN_QUESTIONS, UNFINISHED_BUSINESS, NEXT_SCENE_HOOKS, CRITICAL_ROLLS, CHARACTER_DEVELOPMENT_MOMENTS, CREATIVE_SOLUTIONS)
        SELECT 
            :SCENE_num_param,
            :current_SCENE_title,
            :current_SCENE_type,
            :metadata_ai_response:all_locations::ARRAY,
            :metadata_ai_response:party_members_active::ARRAY,
            :metadata_ai_response:npcs_encountered::VARIANT,
            :metadata_ai_response:enemies_faced::VARIANT,
            :metadata_ai_response:plot_threads_new::ARRAY,
            :metadata_ai_response:plot_threads_advanced::ARRAY,
            :metadata_ai_response:plot_threads_resolved::ARRAY,
            :metadata_ai_response:foreshadowing::ARRAY,
            :metadata_ai_response:npc_relationships_changed::VARIANT,
            :metadata_ai_response:promises_made::ARRAY,
            :metadata_ai_response:faction_standing_changes::VARIANT,
            :metadata_ai_response:locations_discovered::ARRAY,
            :metadata_ai_response:locations_altered::ARRAY,
            :metadata_ai_response:power_shifts::ARRAY,
            :metadata_ai_response:time_sensitive_events::ARRAY,
            :metadata_ai_response:combat_tactics_effective::ARRAY,
            :metadata_ai_response:combat_tactics_failed::ARRAY,
            :metadata_ai_response:enemy_intel_revealed::VARIANT,
            :metadata_ai_response:items_acquired::VARIANT,
            :metadata_ai_response:open_questions::ARRAY,
            :metadata_ai_response:unfinished_business::ARRAY,
            :metadata_ai_response:next_SCENE_hooks::ARRAY,
            :metadata_ai_response:critical_rolls::VARIANT,
            :metadata_ai_response:character_development_moments::ARRAY,
            :metadata_ai_response:creative_solutions::ARRAY;
        EXCEPTION
            WHEN OTHER THEN
                RETURN 'ERROR: Failed to insert into SCENE_METADATA for SCENE ' || :SCENE_num_param || ': ' || SQLERRM;
        END;
    END IF;
    
    -- ========================================================================
    -- Success! Return confirmation
    -- ========================================================================
    IF (:JUST_NARRATIVE_IND) THEN
        RETURN 'SUCCESS: SCENE ' || :SCENE_num_param || ' (' || :current_SCENE_title || ') processed successfully. ' ||
               'Narrative saved to database (metadata skipped).';
    ELSE
        RETURN 'SUCCESS: SCENE ' || :SCENE_num_param || ' (' || :current_SCENE_title || ') processed successfully. ' ||
               'Narrative and metadata saved to database.';
    END IF;
    
EXCEPTION
    WHEN OTHER THEN
        RETURN 'ERROR: Unexpected error processing SCENE ' || :SCENE_num_param || ': ' || SQLERRM;
END;
$$;




-- ============================================================================
-- Stored Procedure: Process Scene Range
-- ============================================================================
-- This procedure iterates through a range of scenes and calls generate_scene_summary
-- for each scene in the range.
--
-- Parameters:
--   start_scene_num: First scene number to process
--   end_scene_num: Last scene number to process (inclusive)
--   JUST_NARRATIVE_IND: Optional boolean (default FALSE). When TRUE:
--                       - Only generates narratives, skips metadata processing
-- ============================================================================
DROP PROCEDURE IF EXISTS process_scene_range(INTEGER, INTEGER, BOOLEAN);
DROP PROCEDURE IF EXISTS process_scene_range(INTEGER, INTEGER);

CREATE OR REPLACE PROCEDURE process_scene_range(
    start_scene_num INTEGER,
    end_scene_num INTEGER,
    JUST_NARRATIVE_IND BOOLEAN DEFAULT FALSE
)
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
DECLARE
    current_scene INTEGER;
    result_message VARCHAR;
    all_results VARCHAR DEFAULT '';
BEGIN
    -- Validate input parameters
    IF (:start_scene_num > :end_scene_num) THEN
        RETURN 'ERROR: start_scene_num (' || :start_scene_num || ') must be less than or equal to end_scene_num (' || :end_scene_num || ')';
    END IF;
    
    IF (:start_scene_num < 1) THEN
        RETURN 'ERROR: start_scene_num must be greater than 0';
    END IF;
    
    -- Initialize the loop counter
    current_scene := :start_scene_num;
    
    -- Loop through each scene in the range
    WHILE (current_scene <= :end_scene_num) DO
        BEGIN
            -- Call generate_scene_summary for the current scene
            CALL generate_scene_summary(:current_scene, :JUST_NARRATIVE_IND) INTO :result_message;
            
            -- Append the result to the overall results
            all_results := :all_results || 'Scene ' || :current_scene || ': ' || :result_message || '\n';
            
        EXCEPTION
            WHEN OTHER THEN
                all_results := :all_results || 'Scene ' || :current_scene || ': ERROR - ' || SQLERRM || '\n';
        END;
        
        -- Move to next scene
        current_scene := :current_scene + 1;
    END WHILE;
    
    -- Return summary of all processing
    RETURN 'Processed scenes ' || :start_scene_num || ' to ' || :end_scene_num || ':\n' || :all_results;
    
EXCEPTION
    WHEN OTHER THEN
        RETURN 'ERROR: Unexpected error in process_scene_range: ' || SQLERRM;
END;
$$;

-- ============================================================================
-- PROCESSING COMMANDS
-- ============================================================================

-- Process a single session (with metadata)
-- CALL generate_scene_summary(4);

-- Process a single session (narrative only, skip metadata)
 CALL generate_scene_summary(72, TRUE);

-- Process a range of scenes (with metadata)
-- CALL process_scene_range(72, 80);

-- Process a range of scenes (narrative only, skip metadata)
 CALL process_scene_range(75, 82, TRUE);


-- Verify narratives are now unique
SELECT SCENE_NUM, SCENE_TITLE,NARRATIVE_TEXT
FROM SCENE_NARRATIVE 
WHERE SCENE_NUM BETWEEN 70 AND 90
ORDER BY SCENE_NUM;
 


-- ============================================================================
-- USAGE EXAMPLES
-- ============================================================================

 SELECT * FROM SCENE_NARRATIVE ORDER BY SCENE_NUM DESC;
 SELECT * FROM SCENE_METADATA ORDER BY SCENE_NUM DESC;

-- Find all scenes with a specific NPC
-- SELECT SCENE_NUM, SCENE_TITLE, NPCS_ENCOUNTERED
-- FROM SCENE_METADATA
-- WHERE NPCS_ENCOUNTERED::VARCHAR ILIKE '%Feligrinn%'
-- ORDER BY SCENE_NUM;

-- Track a plot thread across scenes
-- SELECT SCENE_NUM, SCENE_TITLE, PLOT_THREADS_ADVANCED
-- FROM SCENE_METADATA
-- WHERE ARRAY_TO_STRING(PLOT_THREADS_ADVANCED, ' ') ILIKE '%trinket%'
-- ORDER BY SCENE_NUM;


-- TURN ON CHANGE TRACKING FOR FINAL TABLES
ALTER TABLE WPA.DATA.FINAL_MESSAGES SET CHANGE_TRACKING = TRUE;
ALTER TABLE WPA.DATA.SCENE_METADATA SET CHANGE_TRACKING = TRUE;
ALTER TABLE WPA.DATA.SCENE_NARRATIVE SET CHANGE_TRACKING = TRUE;
