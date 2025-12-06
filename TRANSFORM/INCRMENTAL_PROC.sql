USE ROLE SYSADMIN;
USE SCHEMA WPA.RAW_DATA;
CREATE OR REPLACE TABLE raw_json_chron_20251124 (file_content VARIANT);
COPY INTO raw_json_chron_20251124 FROM @RAW_WPA/the-chronicles-20251124.json FILE_FORMAT = (TYPE = 'JSON');
USE SCHEMA WPA.RAW_VIEWS;

-- CHECK THE THREAD NUMBER!! 
SELECT MAX(THREAD_ID) FROM STG_MESSAGES;
SET THREAD_ID_NUMBER = 22;

CREATE OR REPLACE VIEW v_chron_20251124_messages AS
SELECT 
    $THREAD_ID_NUMBER as thread_id,
    TRY_TO_TIMESTAMP(msg.value:timestamp::string) as msg_timestamp,
    msg.value:id::string as msg_id,
    file_content:channel.category::string || ': ' || file_content:channel.name::string as location_name,
    msg.value:author.nickname::string as author_nickname,
    msg.value:content::string as msg_content,
    msg.value:reactions as reactions,
    msg.value:embeds[0].title::string as embed_title,
    msg.value:embeds[0].description::string as embed_description,
    msg.value:embeds[0].footer.text::string as footer_text,
    ARRAY_TO_STRING(ARRAY_CONSTRUCT_COMPACT(
        ARRAY_AGG(CASE WHEN f.value:name IS NOT NULL THEN 
            OBJECT_CONSTRUCT('Note', f.value:value)
        END) WITHIN GROUP (ORDER BY f.index)
    ), ' | ')::string as fields_values
FROM WPA.RAW_DATA.raw_json_chron_20251124,
LATERAL FLATTEN(input => file_content:messages) as msg,
LATERAL FLATTEN(input => msg.value:embeds[0].fields, outer => true) as f
GROUP BY ALL;    

USE SCHEMA WPA.DATA;

INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, MSG_TIMESTAMP, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
SELECT THREAD_ID
    , MSG_ID
    , (10 * ROW_NUMBER() OVER (ORDER BY MSG_TIMESTAMP)) + (THREAD_ID * 1000000) AS THREAD_MSG_NUM
    , MSG_TIMESTAMP
    , LOCATION_NAME
    , CASE  WHEN LEFT(TRIM(MSG_CONTENT), 1) = '>' THEN 'Dungeon Master'
            WHEN REGEXP_SUBSTR(AUTHOR_NICKNAME, '^[^ ]+') = 'Flapjacks-over-Eggs' AND LEFT(MSG_CONTENT, 2) = '((' THEN 'Dungeon Master'
            WHEN AUTHOR_NICKNAME ILIKE '%AVRAE%' AND LEFT(EMBED_TITLE, 19) = 'An unknown creature' THEN 'An unknown creature'
                 WHEN AUTHOR_NICKNAME ILIKE '%AVRAE%' AND LEFT(EMBED_TITLE, 3) = 'An ' THEN REGEXP_SUBSTR(EMBED_TITLE, '^An ([^ ]+)', 1, 1, '', 1)
                WHEN AUTHOR_NICKNAME ILIKE '%AVRAE%' AND LEFT(EMBED_TITLE, 2) = 'A ' THEN REGEXP_SUBSTR(EMBED_TITLE, '^A ([^ ]+)', 1, 1, '', 1)
                WHEN AUTHOR_NICKNAME ILIKE '%AVRAE%' AND LEN(EMBED_TITLE) > 0 THEN REGEXP_SUBSTR(EMBED_TITLE, '^[^ ]+')
            WHEN AUTHOR_NICKNAME ILIKE '%AVRAE%' THEN 'Dungeon Master'
            ELSE REGEXP_SUBSTR(AUTHOR_NICKNAME, '^[^ ]+') 
      END AS CHARACTER_NAME
    , TRIM(CASE WHEN MSG_CONTENT ILIKE '%Everyone roll for initiative%' THEN 'Start Init'
            WHEN MSG_CONTENT ILIKE '%Combat ended%' THEN 'End Init'
            WHEN LEN(MSG_CONTENT) = 0 AND LEN(EMBED_TITLE) > 0 THEN EMBED_TITLE || ' ' || EMBED_DESCRIPTION
            WHEN LEN(MSG_CONTENT) = 0 AND LEN(EMBED_TITLE) = 0 THEN 'IGNORE THIS'
            ELSE MSG_CONTENT
       END || CASE WHEN FOOTER_TEXT IS NOT NULL THEN ' ' || FOOTER_TEXT ELSE '' END
           || CASE WHEN FIELDS_VALUES <> '[]' THEN ' ' || REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(FIELDS_VALUES, '{\"', '\n'), '\"}', ''), '\"', ''), '\\n', '\n'), '[', '\n'), ']', '') ELSE '' END
        ) AS MESSAGE
    FROM WPA.RAW_VIEWS.v_chron_20251124_messages 
    WHERE LEN(MESSAGE) > 4
        AND MESSAGE NOT ILIKE '%Custom Counters%'
        AND MESSAGE NOT ILIKE '%IGNORE THIS%'
        AND LEFT(MESSAGE,1) <> '!'
        AND MSG_CONTENT NOT ILIKE '%Selection timed out or was cancelled.%'
        AND MSG_CONTENT NOT ILIKE '%```md%'
        AND MSG_CONTENT NOT ILIKE '%Pinned a message%'
        AND MSG_CONTENT NOT ILIKE '%added to combat with initiative%'
        AND MSG_CONTENT NOT ILIKE '%It is not your turn%'
        AND MSG_CONTENT NOT ILIKE '%Target XX not found%'        
        AND MSG_CONTENT NOT ILIKE '%!cc%'
        AND MSG_CONTENT NOT ILIKE '%!help%'
        AND MSG_CONTENT NOT ILIKE '%Channel already in combat%'
 ORDER BY THREAD_MSG_NUM;

-- REVIEW DATA FOR THE THREAD 

select thread_id, max(thread_msg_num) from stg_messages WHERE THREAD_ID >= $THREAD_ID_NUMBER  - 1 group by thread_id order by thread_id;
SELECT * FROM STG_MESSAGES WHERE thread_msg_num >= 22003750 - 100 ORDER BY thread_msg_num ;

UPDATE STG_MESSAGES SET THREAD_MSG_NUM = 22003305 WHERE THREAD_MSG_NUM = 22003730;
UPDATE STG_MESSAGES SET THREAD_ID = 23, LOCATION_NAME = 'Mountains: Isanya\'s Spine - Icy Descent' WHERE THREAD_MSG_NUM >= 22003735 ;--AND THREAD_MSG_NUM <= 8005070;
UPDATE STG_MESSAGES SET CHARACTER_NAME = 'Ice Matron' WHERE CHARACTER_NAME = 'IM1';
UPDATE STG_MESSAGES SET CHARACTER_NAME = 'Ra\'vek' WHERE CHARACTER_NAME = 'Misfortune';

INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, MSG_TIMESTAMP, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
VALUES (23, 0, 22003735, '2025-11-24 22:24:30'::TIMESTAMP_NTZ, 'Mountains: Isanya\'s Spine - Hag\'s Icy Ledge' , 'Dungeon Master', 'New Scene');


SELECT LOCATION_NAME, COUNT(*) AS MSG_COUNT
FROM WPA.DATA.STG_MESSAGES
GROUP BY LOCATION_NAME
ORDER BY MSG_COUNT DESC;

SELECT CHARACTER_NAME, COUNT(*) AS MSG_COUNT
FROM WPA.DATA.STG_MESSAGES
GROUP BY CHARACTER_NAME
ORDER BY MSG_COUNT DESC;

-- More cleanup of character names needed!!

-- SELECT MAX SESSION
SELECT MAX(SESSION_NUM) FROM FINAL_MESSAGES ;

INSERT INTO FINAL_MESSAGES (SESSION_NUM, THREAD_MSG_NUM, LOCATION_NAME, CHARACTER_NAME, MESSAGE) 
SELECT 84 + 
    SUM(CASE WHEN THREAD_ID = 22 AND THREAD_MSG_NUM IN (21010010, 21020010) THEN 0 
             WHEN MESSAGE = 'Start Init' OR MESSAGE = 'End Init' OR MESSAGE = 'New Scene' 
             --    OR MOD(THREAD_MSG_NUM, 10000) = 10 -- NEW LOCATION MARKER
                    THEN 1 ELSE 0 END) OVER (ORDER BY THREAD_MSG_NUM ROWS UNBOUNDED PRECEDING) AS SESSION_NUM,
    THREAD_MSG_NUM,
    LOCATION_NAME,
    CHARACTER_NAME,
    MESSAGE    
FROM STG_MESSAGES
WHERE THREAD_ID = 22
ORDER BY THREAD_MSG_NUM ;
;
SELECT SESSION_NUM, SESSION_TYPE, SESSION_TITLE, COUNT(*) AS MESSAGE_COUNT
FROM FINAL_MESSAGES
WHERE SESSION_NUM >= 85
GROUP BY ALL
ORDER BY SESSION_NUM;

UPDATE FINAL_MESSAGES SET SESSION_TYPE = 'EXPLORATION' WHERE SESSION_NUM = 87;
UPDATE FINAL_MESSAGES SET SESSION_TYPE = 'NPC ENCOUNTER' WHERE SESSION_NUM = 85;
UPDATE FINAL_MESSAGES SET SESSION_TYPE = 'BATTLE' WHERE SESSION_NUM = 86;

-- Not the best...
call generate_session_titles(85); 
UPDATE FINAL_MESSAGES SET SESSION_TITLE = 'Icy Preparations: Before the Chill' WHERE SESSION_NUM = 85;
UPDATE FINAL_MESSAGES SET SESSION_TITLE = 'Snæbjörg\'s Final Stand: The Ice Matron' WHERE SESSION_NUM = 86;
UPDATE FINAL_MESSAGES SET SESSION_TITLE = 'Cavern Collapse: The Enlarged Escape' WHERE SESSION_NUM = 87;

-- Generate scene summaries and metadata
CALL process_scene_range(85, 87);


 SELECT * FROM SCENE_NARRATIVE ORDER BY SCENE_NUM DESC;
 SELECT * FROM SCENE_METADATA ORDER BY SCENE_NUM DESC;
