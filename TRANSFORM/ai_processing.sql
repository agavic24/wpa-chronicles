USE ROLE SYSADMIN;
CREATE SCHEMA IF NOT EXISTS WPA.DATA;
USE SCHEMA WPA.DATA;

-- Add a SESSION_TITLE column to the FINAL_MESSAGES table
ALTER TABLE FINAL_MESSAGES ADD COLUMN SESSION_TITLE VARCHAR;

-- Add SESSION_TYPE column to the FINAL_MESSAGES table
ALTER TABLE FINAL_MESSAGES ADD COLUMN SESSION_TYPE VARCHAR;

-- Update the SESSION_TYPE = 'EXPLORATION' for all records where LOCATION_NAME NOT ILIKE '%ENCOUNTER%'
UPDATE FINAL_MESSAGES
SET SESSION_TYPE = 'EXPLORATION'
WHERE LOCATION_NAME NOT ILIKE '%ENCOUNTER%';


-- Classify remaining sessions as either BATTLE or NPC ENCOUNTER using AI
UPDATE FINAL_MESSAGES
SET SESSION_TYPE = classified_sessions.session_classification
FROM (
    WITH session_messages AS (
        -- Aggregate all messages for each session where SESSION_TYPE is NULL
        SELECT 
            SESSION_NUM,
            LISTAGG(MESSAGE, '\n ') WITHIN GROUP (ORDER BY THREAD_MSG_NUM) AS combined_messages
        FROM FINAL_MESSAGES
        WHERE SESSION_TYPE IS NULL
        GROUP BY SESSION_NUM
    )
    -- Use AI_CLASSIFY to determine session type
    SELECT 
        SESSION_NUM,
        AI_CLASSIFY(
            combined_messages,
            ['BATTLE', 'NPC ENCOUNTER'],
            {
                'task_description': 'Classify D&D session logs as BATTLE (combat encounters with monsters) or NPC ENCOUNTER (social interactions, conversations, and roleplay with NPCs)'
            }
        ):labels[0]::VARCHAR AS session_classification
    FROM session_messages
) AS classified_sessions
WHERE FINAL_MESSAGES.SESSION_NUM = classified_sessions.SESSION_NUM
  AND FINAL_MESSAGES.SESSION_TYPE IS NULL;

-- Create stored procedure to generate unique session titles one at a time
CREATE OR REPLACE PROCEDURE generate_session_titles()
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
DECLARE
    session_cursor CURSOR FOR 
        SELECT DISTINCT SESSION_NUM, SESSION_TYPE 
        FROM FINAL_MESSAGES 
        ORDER BY SESSION_NUM;
    current_session_num INTEGER;
    current_session_type VARCHAR;
    session_messages_text VARCHAR;
    previous_titles_text VARCHAR;
    ai_prompt VARCHAR;
    generated_title VARCHAR;
BEGIN
    -- Loop through each session in order
    OPEN session_cursor;
    FOR session_rec IN session_cursor DO
        current_session_num := session_rec.SESSION_NUM;
        current_session_type := session_rec.SESSION_TYPE;
        
        -- Get all messages for this session
        SELECT LISTAGG(MESSAGE, '\n') WITHIN GROUP (ORDER BY THREAD_MSG_NUM)
        INTO :session_messages_text
        FROM FINAL_MESSAGES
        WHERE SESSION_NUM = :current_session_num;
        
        -- Get all previous session titles (for uniqueness checking)
        SELECT LISTAGG(SESSION_NUM || ': ' || COALESCE(SESSION_TITLE, 'Untitled'), '\n') 
               WITHIN GROUP (ORDER BY SESSION_NUM)
        INTO :previous_titles_text
        FROM (
            SELECT DISTINCT SESSION_NUM, SESSION_TITLE
            FROM FINAL_MESSAGES
            WHERE SESSION_NUM < :current_session_num
              AND SESSION_TITLE IS NOT NULL
        );
        
        -- Build the AI prompt with all requirements
        ai_prompt := 'You are creating a provocative title for a D&D session (maximum 60 characters).

Session Type: ' || COALESCE(:current_session_type, 'UNKNOWN') || '

Requirements:
1. Create a unique, dramatic title that captures the essence of this session
2. If this is an NPC ENCOUNTER, include the NPC name in the title (NOT these player characters: Ra, Ra''vek, Flapjacks-over-Eggs, Saba, Quinn, Aillig, Cala, Mina, Darias)
3. DO NOT repeat any adjectives or nouns from the previous session titles listed below
4. Return ONLY the title text, no quotes or extra formatting

Previous Session Titles (avoid these titles):
' || COALESCE(:previous_titles_text, 'None yet') || '

Current Session Messages:
' || :session_messages_text;
        
        -- Generate title using AI_COMPLETE
        SELECT AI_COMPLETE('claude-4-sonnet', :ai_prompt)::VARCHAR
        INTO :generated_title;
        
        -- Update all records for this session with the generated title
        UPDATE FINAL_MESSAGES
        SET SESSION_TITLE = :generated_title
        WHERE SESSION_NUM = :current_session_num;
        
    END FOR;
    CLOSE session_cursor;
    
    RETURN 'Session titles generated successfully';
END;
$$;

-- Call the stored procedure to generate titles
CALL generate_session_titles();

update FINAL_MESSAGES
SET SESSION_TITLE = 'Cardshark\'s Gambit: Fortune Favors the Bold'
WHERE SESSION_NUM = 150;

UPDATE FINAL_MESSAGES SET SESSION_TITLE = 'River Walk: Stories of the Past', SESSION_TYPE = 'EXPLORATION' WHERE THREAD_MSG_NUM >= 17000885 AND THREAD_MSG_NUM <= 17001140;
DELETE FROM FINAL_MESSAGES WHERE THREAD_MSG_NUM = 17001145;
INSERT INTO FINAL_MESSAGES (SESSION_NUM, THREAD_MSG_NUM, LOCATION_NAME, CHARACTER_NAME, MESSAGE, SESSION_TITLE, SESSION_TYPE) 
VALUES (415, 17001145, 'East Island: Autumnal Forest - Riverside', 'Dungeon Master', 'New Scene', 'Sky Thief: Traps and Trades', 'NPC ENCOUNTER');
INSERT INTO FINAL_MESSAGES (SESSION_NUM, THREAD_MSG_NUM, LOCATION_NAME, CHARACTER_NAME, MESSAGE, SESSION_TITLE, SESSION_TYPE) 
VALUES (415, 17001325, 'East Island: Autumnal Forest - Riverside', 'Dungeon Master', '>>> “Oh - hmm… maybe… Krip-Krip fly like bird?  Krip-Krip safe? Hmm… oh… yes, that would be…”', 'Sky Thief: Traps and Trades', 'NPC ENCOUNTER');

UPDATE FINAL_MESSAGES SET SESSION_TITLE = 'Big Snapper: Jaws from the Deep'
, LOCATION_NAME = 'East Island: Autumnal Forest - Riverside (ENCOUNTER)'
, SESSION_TYPE = 'BATTLE'
, MESSAGE = '> *As Krip-Krip is in mid-rant and Klymok is thrashing around in the net, a deep, guttural raven croak echoes from nearby and a sudden, prickling chill crawls up of the spine of everyone in the party.*

*Before anyone fully register\’s that this is a warning call, the river erupts and water sprays everywhere as a **giant crocodile** lunges from the depths.  Its dagger-like maw stretched outward ready to clamp down on Klymok!*

( Roll Initiative with advantage from Ra\’s Dagger of Warning )  '
, SESSION_NUM = 420 
WHERE THREAD_MSG_NUM = 17001330;
UPDATE FINAL_MESSAGES SET SESSION_TITLE = 'Sky Thief: Traps and Trades', SESSION_NUM = 415 WHERE THREAD_MSG_NUM >= 17001145 AND THREAD_MSG_NUM <= 17001330;
UPDATE FINAL_MESSAGES SET SESSION_TITLE = 'Big Snapper: Jaws from the Deep' WHERE SESSION_NUM = 420;
UPDATE FINAL_MESSAGES SET SESSION_TITLE = 'Dawn of a New Day: Darias joins the Party' WHERE SESSION_NUM = 390;
UPDATE FINAL_MESSAGES SET SESSION_TITLE = 'Coves Edge: Heroes Respite' WHERE SESSION_NUM = 360;
UPDATE FINAL_MESSAGES SET SESSION_TITLE = 'Mirewatch: Beyond the Reeds' WHERE SESSION_NUM = 130;
UPDATE FINAL_MESSAGES SET SESSION_TITLE = 'Pool of Problems: Unexpected Ambush' WHERE SESSION_NUM = 460;
UPDATE FINAL_MESSAGES SET SESSION_TITLE = 'Truth Revealed: Sporion\'s Last Stand' WHERE SESSION_NUM = 290;
UPDATE FINAL_MESSAGES SET SESSION_TITLE = 'Hippo Stampede: Tought and Terrible Trolls' WHERE SESSION_NUM = 470;
UPDATE FINAL_MESSAGES SET SESSION_TITLE = 'Aleksandra\'s Corner: Looking for a Clue' WHERE SESSION_NUM = 380;
UPDATE FINAL_MESSAGES SET SESSION_TITLE = 'Frozen Ambush: Winter Wolves Strike' WHERE SESSION_NUM = 500;
UPDATE FINAL_MESSAGES SET SESSION_TITLE = 'Abominable Assault: Colossal Yeti Rampage' WHERE SESSION_NUM = 530;
UPDATE FINAL_MESSAGES SET SESSION_TITLE = 'The Silent Archway: Threads of Sorrow' WHERE SESSION_NUM = 600;
UPDATE FINAL_MESSAGES SET SESSION_TITLE = 'Chilling Discoveries: Treasures of the Trapped' WHERE SESSION_NUM = 760;

--REMOVE ' (ENCOUNTER)' FROM LOCATION
UPDATE FINAL_MESSAGES SET LOCATION_NAME = REPLACE(LOCATION_NAME, ' (ENCOUNTER)', '') WHERE LOCATION_NAME LIKE '%(ENCOUNTER)%';

UPDATE FINAL_MESSAGES SET LOCATION_NAME = 'East Island: Woodlands' WHERE LOCATION_NAME = 'East Island: Woodlands (ENCOUNTER)';
UPDATE FINAL_MESSAGES SET LOCATION_NAME = 'East Island: Autumnal Forest' WHERE LOCATION_NAME = 'East Island: Autumnal Forest (ENCOUNTER)';
UPDATE FINAL_MESSAGES SET LOCATION_NAME = 'East Island: Cold Jungle Floor' WHERE LOCATION_NAME = 'East Island: Cold Jungle Floor (ENCOUNTER)';
UPDATE FINAL_MESSAGES SET LOCATION_NAME = 'East Island: Verdant Hills' WHERE LOCATION_NAME = 'East Island: Verdant Hills (ENCOUNTER)';
UPDATE FINAL_MESSAGES SET LOCATION_NAME = 'East Island: Woodlands' WHERE LOCATION_NAME = 'East Island: Woodlands (ENCOUNTER)';

select DISTINCT SESSION_NUM, SESSION_TYPE, LOCATION_NAME, SESSION_TITLE
from FINAL_MESSAGES
--where session_title ilike '%edri%'
order by SESSION_NUM
;

SELECT * FROM FINAL_MESSAGES
WHERE SESSION_NUM = 760
order by session_num, thread_msg_num
;
update FINAL_MESSAGES
set character_name = 'Ra\'skar'
where character_name = 'Ra\’vek'
and session_num = 37;

;