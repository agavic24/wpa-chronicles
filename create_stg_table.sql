
USE ROLE SYSADMIN;
CREATE SCHEMA IF NOT EXISTS WPA.DATA;
USE SCHEMA WPA.DATA;

CREATE OR REPLACE TABLE STG_MESSAGES (
    THREAD_ID NUMERIC,
    MSG_ID NUMERIC,
    THREAD_MSG_NUM NUMERIC,
    LOCATION_NAME VARCHAR,
    CHARACTER_NAME VARCHAR,
    MESSAGE VARCHAR
);

-- Thread 1
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
SELECT THREAD_ID
    , MSG_ID
    , (10 * ROW_NUMBER() OVER (ORDER BY MSG_TIMESTAMP)) + (THREAD_ID * 1000000) AS THREAD_MSG_NUM
    , LOCATION_NAME
    , CASE  WHEN LEFT(TRIM(MSG_CONTENT), 1) = '>' THEN 'Dungeon Master'
            WHEN REGEXP_SUBSTR(AUTHOR_NICKNAME, '^[^ ]+') = 'Flapjacks-over-Eggs' AND LEFT(MSG_CONTENT, 2) = '((' THEN 'Dungeon Master'
            WHEN AUTHOR_NICKNAME ILIKE '%AVRAE%' AND LEFT(EMBED_TITLE, 19) = 'An unknown creature' THEN 'An unknown creature'
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
    FROM WPA.RAW_VIEWS.v_thread1_messages 
    WHERE LEN(MESSAGE) > 4
        AND MESSAGE NOT ILIKE '%Custom Counters%'
        AND MESSAGE <> 'IGNORE THIS'
        AND LEFT(MESSAGE,1) <> '!'
        AND MSG_CONTENT NOT ILIKE '%Selection timed out or was cancelled.%'
        AND MSG_CONTENT NOT ILIKE '%```md%'
        AND MSG_CONTENT NOT ILIKE '%Pinned a message%'
        AND MSG_CONTENT NOT ILIKE '%added to combat with initiative%'
        AND MSG_CONTENT NOT ILIKE '%It is not your turn%'
        AND MSG_CONTENT NOT ILIKE '%Target XX not found%'        
        AND MSG_CONTENT NOT ILIKE '%!cc%'
 ORDER BY THREAD_MSG_NUM;

-- Thread 2
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
SELECT THREAD_ID
    , MSG_ID
    , (10 * ROW_NUMBER() OVER (ORDER BY MSG_TIMESTAMP)) + (THREAD_ID * 1000000) AS THREAD_MSG_NUM
    , LOCATION_NAME
    , CASE  WHEN LEFT(TRIM(MSG_CONTENT), 1) = '>' THEN 'Dungeon Master'
            WHEN REGEXP_SUBSTR(AUTHOR_NICKNAME, '^[^ ]+') = 'Flapjacks-over-Eggs' AND LEFT(MSG_CONTENT, 2) = '((' THEN 'Dungeon Master'
            WHEN AUTHOR_NICKNAME ILIKE '%AVRAE%' AND LEFT(EMBED_TITLE, 19) = 'An unknown creature' THEN 'An unknown creature'
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
    FROM WPA.RAW_VIEWS.v_thread2_messages 
    WHERE LEN(MESSAGE) > 4
        AND MESSAGE NOT ILIKE '%Custom Counters%'
        AND MESSAGE <> 'IGNORE THIS'
        AND LEFT(MESSAGE,1) <> '!'
        AND MSG_CONTENT NOT ILIKE '%Selection timed out or was cancelled.%'
        AND MSG_CONTENT NOT ILIKE '%```md%'
        AND MSG_CONTENT NOT ILIKE '%Pinned a message%'
        AND MSG_CONTENT NOT ILIKE '%added to combat with initiative%'
        AND MSG_CONTENT NOT ILIKE '%It is not your turn%'
        AND MSG_CONTENT NOT ILIKE '%Target XX not found%'        
        AND MSG_CONTENT NOT ILIKE '%!cc%'
 ORDER BY THREAD_MSG_NUM;

-- Thread 3
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
SELECT THREAD_ID
    , MSG_ID
    , (10 * ROW_NUMBER() OVER (ORDER BY MSG_TIMESTAMP)) + (THREAD_ID * 1000000) AS THREAD_MSG_NUM
    , LOCATION_NAME
    , CASE  WHEN LEFT(TRIM(MSG_CONTENT), 1) = '>' THEN 'Dungeon Master'
            WHEN REGEXP_SUBSTR(AUTHOR_NICKNAME, '^[^ ]+') = 'Flapjacks-over-Eggs' AND LEFT(MSG_CONTENT, 2) = '((' THEN 'Dungeon Master'
            WHEN AUTHOR_NICKNAME ILIKE '%AVRAE%' AND LEFT(EMBED_TITLE, 19) = 'An unknown creature' THEN 'An unknown creature'
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
    FROM WPA.RAW_VIEWS.v_thread3_messages 
    WHERE LEN(MESSAGE) > 4
        AND MESSAGE NOT ILIKE '%Custom Counters%'
        AND MESSAGE <> 'IGNORE THIS'
        AND LEFT(MESSAGE,1) <> '!'
        AND MSG_CONTENT NOT ILIKE '%Selection timed out or was cancelled.%'
        AND MSG_CONTENT NOT ILIKE '%```md%'
        AND MSG_CONTENT NOT ILIKE '%Pinned a message%'
        AND MSG_CONTENT NOT ILIKE '%added to combat with initiative%'
        AND MSG_CONTENT NOT ILIKE '%It is not your turn%'
        AND MSG_CONTENT NOT ILIKE '%Target XX not found%'        
        AND MSG_CONTENT NOT ILIKE '%!cc%'
 ORDER BY THREAD_MSG_NUM;

-- Thread 4
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
SELECT THREAD_ID
    , MSG_ID
    , (10 * ROW_NUMBER() OVER (ORDER BY MSG_TIMESTAMP)) + (THREAD_ID * 1000000) AS THREAD_MSG_NUM
    , LOCATION_NAME
    , CASE  WHEN LEFT(TRIM(MSG_CONTENT), 1) = '>' THEN 'Dungeon Master'
            WHEN REGEXP_SUBSTR(AUTHOR_NICKNAME, '^[^ ]+') = 'Flapjacks-over-Eggs' AND LEFT(MSG_CONTENT, 2) = '((' THEN 'Dungeon Master'
            WHEN AUTHOR_NICKNAME ILIKE '%AVRAE%' AND LEFT(EMBED_TITLE, 19) = 'An unknown creature' THEN 'An unknown creature'
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
    FROM WPA.RAW_VIEWS.v_thread4_messages 
    WHERE LEN(MESSAGE) > 4
        AND MESSAGE NOT ILIKE '%Custom Counters%'
        AND MESSAGE <> 'IGNORE THIS'
        AND LEFT(MESSAGE,1) <> '!'
        AND MSG_CONTENT NOT ILIKE '%Selection timed out or was cancelled.%'
        AND MSG_CONTENT NOT ILIKE '%```md%'
        AND MSG_CONTENT NOT ILIKE '%Pinned a message%'
        AND MSG_CONTENT NOT ILIKE '%added to combat with initiative%'
        AND MSG_CONTENT NOT ILIKE '%It is not your turn%'
        AND MSG_CONTENT NOT ILIKE '%Target XX not found%'        
        AND MSG_CONTENT NOT ILIKE '%!cc%'
 ORDER BY THREAD_MSG_NUM;

-- Thread 5
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
SELECT THREAD_ID
    , MSG_ID
    , (10 * ROW_NUMBER() OVER (ORDER BY MSG_TIMESTAMP)) + (THREAD_ID * 1000000) AS THREAD_MSG_NUM
    , LOCATION_NAME
    , CASE  WHEN LEFT(TRIM(MSG_CONTENT), 1) = '>' THEN 'Dungeon Master'
            WHEN REGEXP_SUBSTR(AUTHOR_NICKNAME, '^[^ ]+') = 'Flapjacks-over-Eggs' AND LEFT(MSG_CONTENT, 2) = '((' THEN 'Dungeon Master'
            WHEN AUTHOR_NICKNAME ILIKE '%AVRAE%' AND LEFT(EMBED_TITLE, 19) = 'An unknown creature' THEN 'An unknown creature'
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
    FROM WPA.RAW_VIEWS.v_thread5_messages 
    WHERE LEN(MESSAGE) > 4
        AND MESSAGE NOT ILIKE '%Custom Counters%'
        AND MESSAGE <> 'IGNORE THIS'
        AND LEFT(MESSAGE,1) <> '!'
        AND MSG_CONTENT NOT ILIKE '%Selection timed out or was cancelled.%'
        AND MSG_CONTENT NOT ILIKE '%```md%'
        AND MSG_CONTENT NOT ILIKE '%Pinned a message%'
        AND MSG_CONTENT NOT ILIKE '%added to combat with initiative%'
        AND MSG_CONTENT NOT ILIKE '%It is not your turn%'
        AND MSG_CONTENT NOT ILIKE '%Target XX not found%'        
        AND MSG_CONTENT NOT ILIKE '%!cc%'
 ORDER BY THREAD_MSG_NUM;

-- Thread 6
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
SELECT THREAD_ID
    , MSG_ID
    , (10 * ROW_NUMBER() OVER (ORDER BY MSG_TIMESTAMP)) + (THREAD_ID * 1000000) AS THREAD_MSG_NUM
    , LOCATION_NAME
    , CASE  WHEN LEFT(TRIM(MSG_CONTENT), 1) = '>' THEN 'Dungeon Master'
            WHEN REGEXP_SUBSTR(AUTHOR_NICKNAME, '^[^ ]+') = 'Flapjacks-over-Eggs' AND LEFT(MSG_CONTENT, 2) = '((' THEN 'Dungeon Master'
            WHEN AUTHOR_NICKNAME ILIKE '%AVRAE%' AND LEFT(EMBED_TITLE, 19) = 'An unknown creature' THEN 'An unknown creature'
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
    FROM WPA.RAW_VIEWS.v_thread6_messages 
    WHERE LEN(MESSAGE) > 4
        AND MESSAGE NOT ILIKE '%Custom Counters%'
        AND MESSAGE <> 'IGNORE THIS'
        AND LEFT(MESSAGE,1) <> '!'
        AND MSG_CONTENT NOT ILIKE '%Selection timed out or was cancelled.%'
        AND MSG_CONTENT NOT ILIKE '%```md%'
        AND MSG_CONTENT NOT ILIKE '%Pinned a message%'
        AND MSG_CONTENT NOT ILIKE '%added to combat with initiative%'
        AND MSG_CONTENT NOT ILIKE '%It is not your turn%'
        AND MSG_CONTENT NOT ILIKE '%Target XX not found%'        
        AND MSG_CONTENT NOT ILIKE '%!cc%'
 ORDER BY THREAD_MSG_NUM;

-- Thread 7
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
SELECT THREAD_ID
    , MSG_ID
    , (10 * ROW_NUMBER() OVER (ORDER BY MSG_TIMESTAMP)) + (THREAD_ID * 1000000) AS THREAD_MSG_NUM
    , LOCATION_NAME
    , CASE  WHEN LEFT(TRIM(MSG_CONTENT), 1) = '>' THEN 'Dungeon Master'
            WHEN REGEXP_SUBSTR(AUTHOR_NICKNAME, '^[^ ]+') = 'Flapjacks-over-Eggs' AND LEFT(MSG_CONTENT, 2) = '((' THEN 'Dungeon Master'
            WHEN AUTHOR_NICKNAME ILIKE '%AVRAE%' AND LEFT(EMBED_TITLE, 19) = 'An unknown creature' THEN 'An unknown creature'
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
    FROM WPA.RAW_VIEWS.v_thread7_messages 
    WHERE LEN(MESSAGE) > 4
        AND MESSAGE NOT ILIKE '%Custom Counters%'
        AND MESSAGE <> 'IGNORE THIS'
        AND LEFT(MESSAGE,1) <> '!'
        AND MSG_CONTENT NOT ILIKE '%Selection timed out or was cancelled.%'
        AND MSG_CONTENT NOT ILIKE '%```md%'
        AND MSG_CONTENT NOT ILIKE '%Pinned a message%'
        AND MSG_CONTENT NOT ILIKE '%added to combat with initiative%'
        AND MSG_CONTENT NOT ILIKE '%It is not your turn%'
        AND MSG_CONTENT NOT ILIKE '%Target XX not found%'        
        AND MSG_CONTENT NOT ILIKE '%!cc%'
 ORDER BY THREAD_MSG_NUM;

-- Thread 8
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
SELECT THREAD_ID
    , MSG_ID
    , (10 * ROW_NUMBER() OVER (ORDER BY MSG_TIMESTAMP)) + (THREAD_ID * 1000000) AS THREAD_MSG_NUM
    , LOCATION_NAME
    , CASE  WHEN LEFT(TRIM(MSG_CONTENT), 1) = '>' THEN 'Dungeon Master'
            WHEN REGEXP_SUBSTR(AUTHOR_NICKNAME, '^[^ ]+') = 'Flapjacks-over-Eggs' AND LEFT(MSG_CONTENT, 2) = '((' THEN 'Dungeon Master'
            WHEN AUTHOR_NICKNAME ILIKE '%AVRAE%' AND LEFT(EMBED_TITLE, 19) = 'An unknown creature' THEN 'An unknown creature'
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
    FROM WPA.RAW_VIEWS.v_thread8_messages 
    WHERE LEN(MESSAGE) > 4
        AND MESSAGE NOT ILIKE '%Custom Counters%'
        AND MESSAGE <> 'IGNORE THIS'
        AND LEFT(MESSAGE,1) <> '!'
        AND MSG_CONTENT NOT ILIKE '%Selection timed out or was cancelled.%'
        AND MSG_CONTENT NOT ILIKE '%```md%'
        AND MSG_CONTENT NOT ILIKE '%Pinned a message%'
        AND MSG_CONTENT NOT ILIKE '%added to combat with initiative%'
        AND MSG_CONTENT NOT ILIKE '%It is not your turn%'
        AND MSG_CONTENT NOT ILIKE '%Target XX not found%'        
        AND MSG_CONTENT NOT ILIKE '%!cc%'
 ORDER BY THREAD_MSG_NUM;

-- Thread 9
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
SELECT THREAD_ID
    , MSG_ID
    , (10 * ROW_NUMBER() OVER (ORDER BY MSG_TIMESTAMP)) + (THREAD_ID * 1000000) AS THREAD_MSG_NUM
    , LOCATION_NAME
    , CASE  WHEN LEFT(TRIM(MSG_CONTENT), 1) = '>' THEN 'Dungeon Master'
            WHEN REGEXP_SUBSTR(AUTHOR_NICKNAME, '^[^ ]+') = 'Flapjacks-over-Eggs' AND LEFT(MSG_CONTENT, 2) = '((' THEN 'Dungeon Master'
            WHEN AUTHOR_NICKNAME ILIKE '%AVRAE%' AND LEFT(EMBED_TITLE, 19) = 'An unknown creature' THEN 'An unknown creature'
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
    FROM WPA.RAW_VIEWS.v_thread9_messages 
    WHERE LEN(MESSAGE) > 4
        AND MESSAGE NOT ILIKE '%Custom Counters%'
        AND MESSAGE <> 'IGNORE THIS'
        AND LEFT(MESSAGE,1) <> '!'
        AND MSG_CONTENT NOT ILIKE '%Selection timed out or was cancelled.%'
        AND MSG_CONTENT NOT ILIKE '%```md%'
        AND MSG_CONTENT NOT ILIKE '%Pinned a message%'
        AND MSG_CONTENT NOT ILIKE '%added to combat with initiative%'
        AND MSG_CONTENT NOT ILIKE '%It is not your turn%'
        AND MSG_CONTENT NOT ILIKE '%Target XX not found%'        
        AND MSG_CONTENT NOT ILIKE '%!cc%'
 ORDER BY THREAD_MSG_NUM;

-- Thread 10
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
SELECT THREAD_ID
    , MSG_ID
    , (10 * ROW_NUMBER() OVER (ORDER BY MSG_TIMESTAMP)) + (THREAD_ID * 1000000) AS THREAD_MSG_NUM
    , LOCATION_NAME
    , CASE  WHEN LEFT(TRIM(MSG_CONTENT), 1) = '>' THEN 'Dungeon Master'
            WHEN REGEXP_SUBSTR(AUTHOR_NICKNAME, '^[^ ]+') = 'Flapjacks-over-Eggs' AND LEFT(MSG_CONTENT, 2) = '((' THEN 'Dungeon Master'
            WHEN AUTHOR_NICKNAME ILIKE '%AVRAE%' AND LEFT(EMBED_TITLE, 19) = 'An unknown creature' THEN 'An unknown creature'
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
    FROM WPA.RAW_VIEWS.v_thread10_messages 
    WHERE LEN(MESSAGE) > 4
        AND MESSAGE NOT ILIKE '%Custom Counters%'
        AND MESSAGE <> 'IGNORE THIS'
        AND LEFT(MESSAGE,1) <> '!'
        AND MSG_CONTENT NOT ILIKE '%Selection timed out or was cancelled.%'
        AND MSG_CONTENT NOT ILIKE '%```md%'
        AND MSG_CONTENT NOT ILIKE '%Pinned a message%'
        AND MSG_CONTENT NOT ILIKE '%added to combat with initiative%'
        AND MSG_CONTENT NOT ILIKE '%It is not your turn%'
        AND MSG_CONTENT NOT ILIKE '%Target XX not found%'        
        AND MSG_CONTENT NOT ILIKE '%!cc%'
 ORDER BY THREAD_MSG_NUM;

-- Thread 11
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
SELECT THREAD_ID
    , MSG_ID
    , (10 * ROW_NUMBER() OVER (ORDER BY MSG_TIMESTAMP)) + (THREAD_ID * 1000000) AS THREAD_MSG_NUM
    , LOCATION_NAME
    , CASE  WHEN LEFT(TRIM(MSG_CONTENT), 1) = '>' THEN 'Dungeon Master'
            WHEN REGEXP_SUBSTR(AUTHOR_NICKNAME, '^[^ ]+') = 'Flapjacks-over-Eggs' AND LEFT(MSG_CONTENT, 2) = '((' THEN 'Dungeon Master'
            WHEN AUTHOR_NICKNAME ILIKE '%AVRAE%' AND LEFT(EMBED_TITLE, 19) = 'An unknown creature' THEN 'An unknown creature'
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
    FROM WPA.RAW_VIEWS.v_thread11_messages 
    WHERE LEN(MESSAGE) > 4
        AND MESSAGE NOT ILIKE '%Custom Counters%'
        AND MESSAGE <> 'IGNORE THIS'
        AND LEFT(MESSAGE,1) <> '!'
        AND MSG_CONTENT NOT ILIKE '%Selection timed out or was cancelled.%'
        AND MSG_CONTENT NOT ILIKE '%```md%'
        AND MSG_CONTENT NOT ILIKE '%Pinned a message%'
        AND MSG_CONTENT NOT ILIKE '%added to combat with initiative%'
        AND MSG_CONTENT NOT ILIKE '%It is not your turn%'
        AND MSG_CONTENT NOT ILIKE '%Target XX not found%'        
        AND MSG_CONTENT NOT ILIKE '%!cc%'
 ORDER BY THREAD_MSG_NUM;

-- Thread 12
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
SELECT THREAD_ID
    , MSG_ID
    , (10 * ROW_NUMBER() OVER (ORDER BY MSG_TIMESTAMP)) + (THREAD_ID * 1000000) AS THREAD_MSG_NUM
    , LOCATION_NAME
    , CASE  WHEN LEFT(TRIM(MSG_CONTENT), 1) = '>' THEN 'Dungeon Master'
            WHEN REGEXP_SUBSTR(AUTHOR_NICKNAME, '^[^ ]+') = 'Flapjacks-over-Eggs' AND LEFT(MSG_CONTENT, 2) = '((' THEN 'Dungeon Master'
            WHEN AUTHOR_NICKNAME ILIKE '%AVRAE%' AND LEFT(EMBED_TITLE, 19) = 'An unknown creature' THEN 'An unknown creature'
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
    FROM WPA.RAW_VIEWS.v_thread12_messages 
    WHERE LEN(MESSAGE) > 4
        AND MESSAGE NOT ILIKE '%Custom Counters%'
        AND MESSAGE <> 'IGNORE THIS'
        AND LEFT(MESSAGE,1) <> '!'
        AND MSG_CONTENT NOT ILIKE '%Selection timed out or was cancelled.%'
        AND MSG_CONTENT NOT ILIKE '%```md%'
        AND MSG_CONTENT NOT ILIKE '%Pinned a message%'
        AND MSG_CONTENT NOT ILIKE '%added to combat with initiative%'
        AND MSG_CONTENT NOT ILIKE '%It is not your turn%'
        AND MSG_CONTENT NOT ILIKE '%Target XX not found%'        
        AND MSG_CONTENT NOT ILIKE '%!cc%'
 ORDER BY THREAD_MSG_NUM;

-- Thread 13
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
SELECT THREAD_ID
    , MSG_ID
    , (10 * ROW_NUMBER() OVER (ORDER BY MSG_TIMESTAMP)) + (THREAD_ID * 1000000) AS THREAD_MSG_NUM
    , LOCATION_NAME
    , CASE  WHEN LEFT(TRIM(MSG_CONTENT), 1) = '>' THEN 'Dungeon Master'
            WHEN REGEXP_SUBSTR(AUTHOR_NICKNAME, '^[^ ]+') = 'Flapjacks-over-Eggs' AND LEFT(MSG_CONTENT, 2) = '((' THEN 'Dungeon Master'
            WHEN AUTHOR_NICKNAME ILIKE '%AVRAE%' AND LEFT(EMBED_TITLE, 19) = 'An unknown creature' THEN 'An unknown creature'
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
    FROM WPA.RAW_VIEWS.v_thread13_messages 
    WHERE LEN(MESSAGE) > 4
        AND MESSAGE NOT ILIKE '%Custom Counters%'
        AND MESSAGE <> 'IGNORE THIS'
        AND LEFT(MESSAGE,1) <> '!'
        AND MSG_CONTENT NOT ILIKE '%Selection timed out or was cancelled.%'
        AND MSG_CONTENT NOT ILIKE '%```md%'
        AND MSG_CONTENT NOT ILIKE '%Pinned a message%'
        AND MSG_CONTENT NOT ILIKE '%added to combat with initiative%'
        AND MSG_CONTENT NOT ILIKE '%It is not your turn%'
        AND MSG_CONTENT NOT ILIKE '%Target XX not found%'        
        AND MSG_CONTENT NOT ILIKE '%!cc%'
 ORDER BY THREAD_MSG_NUM;

-- Thread 14
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
SELECT THREAD_ID
    , MSG_ID
    , (10 * ROW_NUMBER() OVER (ORDER BY MSG_TIMESTAMP)) + (THREAD_ID * 1000000) AS THREAD_MSG_NUM
    , LOCATION_NAME
    , CASE  WHEN LEFT(TRIM(MSG_CONTENT), 1) = '>' THEN 'Dungeon Master'
            WHEN REGEXP_SUBSTR(AUTHOR_NICKNAME, '^[^ ]+') = 'Flapjacks-over-Eggs' AND LEFT(MSG_CONTENT, 2) = '((' THEN 'Dungeon Master'
            WHEN AUTHOR_NICKNAME ILIKE '%AVRAE%' AND LEFT(EMBED_TITLE, 19) = 'An unknown creature' THEN 'An unknown creature'
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
    FROM WPA.RAW_VIEWS.v_thread14_messages 
    WHERE LEN(MESSAGE) > 4
        AND MESSAGE NOT ILIKE '%Custom Counters%'
        AND MESSAGE <> 'IGNORE THIS'
        AND LEFT(MESSAGE,1) <> '!'
        AND MSG_CONTENT NOT ILIKE '%Selection timed out or was cancelled.%'
        AND MSG_CONTENT NOT ILIKE '%```md%'
        AND MSG_CONTENT NOT ILIKE '%Pinned a message%'
        AND MSG_CONTENT NOT ILIKE '%added to combat with initiative%'
        AND MSG_CONTENT NOT ILIKE '%It is not your turn%'
        AND MSG_CONTENT NOT ILIKE '%Target XX not found%'        
        AND MSG_CONTENT NOT ILIKE '%!cc%'
 ORDER BY THREAD_MSG_NUM;

-- Thread 15
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
SELECT THREAD_ID
    , MSG_ID
    , (10 * ROW_NUMBER() OVER (ORDER BY MSG_TIMESTAMP)) + (THREAD_ID * 1000000) AS THREAD_MSG_NUM
    , LOCATION_NAME
    , CASE  WHEN LEFT(TRIM(MSG_CONTENT), 1) = '>' THEN 'Dungeon Master'
            WHEN REGEXP_SUBSTR(AUTHOR_NICKNAME, '^[^ ]+') = 'Flapjacks-over-Eggs' AND LEFT(MSG_CONTENT, 2) = '((' THEN 'Dungeon Master'
            WHEN AUTHOR_NICKNAME ILIKE '%AVRAE%' AND LEFT(EMBED_TITLE, 19) = 'An unknown creature' THEN 'An unknown creature'
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
    FROM WPA.RAW_VIEWS.v_thread15_messages 
    WHERE LEN(MESSAGE) > 4
        AND MESSAGE NOT ILIKE '%Custom Counters%'
        AND MESSAGE <> 'IGNORE THIS'
        AND LEFT(MESSAGE,1) <> '!'
        AND MSG_CONTENT NOT ILIKE '%Selection timed out or was cancelled.%'
        AND MSG_CONTENT NOT ILIKE '%```md%'
        AND MSG_CONTENT NOT ILIKE '%Pinned a message%'
        AND MSG_CONTENT NOT ILIKE '%added to combat with initiative%'
        AND MSG_CONTENT NOT ILIKE '%It is not your turn%'
        AND MSG_CONTENT NOT ILIKE '%Target XX not found%'        
        AND MSG_CONTENT NOT ILIKE '%!cc%'
 ORDER BY THREAD_MSG_NUM;

-- Thread 16
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
SELECT THREAD_ID
    , MSG_ID
    , (10 * ROW_NUMBER() OVER (ORDER BY MSG_TIMESTAMP)) + (THREAD_ID * 1000000) AS THREAD_MSG_NUM
    , LOCATION_NAME
    , CASE  WHEN LEFT(TRIM(MSG_CONTENT), 1) = '>' THEN 'Dungeon Master'
            WHEN REGEXP_SUBSTR(AUTHOR_NICKNAME, '^[^ ]+') = 'Flapjacks-over-Eggs' AND LEFT(MSG_CONTENT, 2) = '((' THEN 'Dungeon Master'
            WHEN AUTHOR_NICKNAME ILIKE '%AVRAE%' AND LEFT(EMBED_TITLE, 19) = 'An unknown creature' THEN 'An unknown creature'
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
    FROM WPA.RAW_VIEWS.v_thread16_messages 
    WHERE LEN(MESSAGE) > 4
        AND MESSAGE NOT ILIKE '%Custom Counters%'
        AND MESSAGE <> 'IGNORE THIS'
        AND LEFT(MESSAGE,1) <> '!'
        AND MSG_CONTENT NOT ILIKE '%Selection timed out or was cancelled.%'
        AND MSG_CONTENT NOT ILIKE '%```md%'
        AND MSG_CONTENT NOT ILIKE '%Pinned a message%'
        AND MSG_CONTENT NOT ILIKE '%added to combat with initiative%'
        AND MSG_CONTENT NOT ILIKE '%It is not your turn%'
        AND MSG_CONTENT NOT ILIKE '%Target XX not found%'        
        AND MSG_CONTENT NOT ILIKE '%!cc%'
 ORDER BY THREAD_MSG_NUM;

-- Thread 17
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
SELECT THREAD_ID
    , MSG_ID
    , (10 * ROW_NUMBER() OVER (ORDER BY MSG_TIMESTAMP)) + (THREAD_ID * 1000000) AS THREAD_MSG_NUM
    , LOCATION_NAME
    , CASE  WHEN LEFT(TRIM(MSG_CONTENT), 1) = '>' THEN 'Dungeon Master'
            WHEN REGEXP_SUBSTR(AUTHOR_NICKNAME, '^[^ ]+') = 'Flapjacks-over-Eggs' AND LEFT(MSG_CONTENT, 2) = '((' THEN 'Dungeon Master'
            WHEN AUTHOR_NICKNAME ILIKE '%AVRAE%' AND LEFT(EMBED_TITLE, 19) = 'An unknown creature' THEN 'An unknown creature'
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
    FROM WPA.RAW_VIEWS.v_thread17_messages 
    WHERE LEN(MESSAGE) > 4
        AND MESSAGE NOT ILIKE '%Custom Counters%'
        AND MESSAGE <> 'IGNORE THIS'
        AND LEFT(MESSAGE,1) <> '!'
        AND MSG_CONTENT NOT ILIKE '%Selection timed out or was cancelled.%'
        AND MSG_CONTENT NOT ILIKE '%```md%'
        AND MSG_CONTENT NOT ILIKE '%Pinned a message%'
        AND MSG_CONTENT NOT ILIKE '%added to combat with initiative%'
        AND MSG_CONTENT NOT ILIKE '%It is not your turn%'
        AND MSG_CONTENT NOT ILIKE '%Target XX not found%'        
        AND MSG_CONTENT NOT ILIKE '%!cc%'
 ORDER BY THREAD_MSG_NUM;

-- Thread 18
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
SELECT THREAD_ID
    , MSG_ID
    , (10 * ROW_NUMBER() OVER (ORDER BY MSG_TIMESTAMP)) + (THREAD_ID * 1000000) AS THREAD_MSG_NUM
    , LOCATION_NAME
    , CASE  WHEN LEFT(TRIM(MSG_CONTENT), 1) = '>' THEN 'Dungeon Master'
            WHEN REGEXP_SUBSTR(AUTHOR_NICKNAME, '^[^ ]+') = 'Flapjacks-over-Eggs' AND LEFT(MSG_CONTENT, 2) = '((' THEN 'Dungeon Master'
            WHEN AUTHOR_NICKNAME ILIKE '%AVRAE%' AND LEFT(EMBED_TITLE, 19) = 'An unknown creature' THEN 'An unknown creature'
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
    FROM WPA.RAW_VIEWS.v_thread18_messages 
    WHERE LEN(MESSAGE) > 4
        AND MESSAGE NOT ILIKE '%Custom Counters%'
        AND MESSAGE <> 'IGNORE THIS'
        AND LEFT(MESSAGE,1) <> '!'
        AND MSG_CONTENT NOT ILIKE '%Selection timed out or was cancelled.%'
        AND MSG_CONTENT NOT ILIKE '%```md%'
        AND MSG_CONTENT NOT ILIKE '%Pinned a message%'
        AND MSG_CONTENT NOT ILIKE '%added to combat with initiative%'
        AND MSG_CONTENT NOT ILIKE '%It is not your turn%'
        AND MSG_CONTENT NOT ILIKE '%Target XX not found%'        
        AND MSG_CONTENT NOT ILIKE '%!cc%'
 ORDER BY THREAD_MSG_NUM;

-- Thread 19
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
SELECT THREAD_ID
    , MSG_ID
    , (10 * ROW_NUMBER() OVER (ORDER BY MSG_TIMESTAMP)) + (THREAD_ID * 1000000) AS THREAD_MSG_NUM
    , LOCATION_NAME
    , CASE  WHEN LEFT(TRIM(MSG_CONTENT), 1) = '>' THEN 'Dungeon Master'
            WHEN REGEXP_SUBSTR(AUTHOR_NICKNAME, '^[^ ]+') = 'Flapjacks-over-Eggs' AND LEFT(MSG_CONTENT, 2) = '((' THEN 'Dungeon Master'
            WHEN AUTHOR_NICKNAME ILIKE '%AVRAE%' AND LEFT(EMBED_TITLE, 19) = 'An unknown creature' THEN 'An unknown creature'
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
    FROM WPA.RAW_VIEWS.v_thread19_messages 
    WHERE LEN(MESSAGE) > 4
        AND MESSAGE NOT ILIKE '%Custom Counters%'
        AND MESSAGE <> 'IGNORE THIS'
        AND LEFT(MESSAGE,1) <> '!'
        AND MSG_CONTENT NOT ILIKE '%Selection timed out or was cancelled.%'
        AND MSG_CONTENT NOT ILIKE '%```md%'
        AND MSG_CONTENT NOT ILIKE '%Pinned a message%'
        AND MSG_CONTENT NOT ILIKE '%added to combat with initiative%'
        AND MSG_CONTENT NOT ILIKE '%It is not your turn%'
        AND MSG_CONTENT NOT ILIKE '%Target XX not found%'        
        AND MSG_CONTENT NOT ILIKE '%!cc%'
 ORDER BY THREAD_MSG_NUM;

-- Thread 20
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
SELECT THREAD_ID
    , MSG_ID
    , (10 * ROW_NUMBER() OVER (ORDER BY MSG_TIMESTAMP)) + (THREAD_ID * 1000000) AS THREAD_MSG_NUM
    , LOCATION_NAME
    , CASE  WHEN LEFT(TRIM(MSG_CONTENT), 1) = '>' THEN 'Dungeon Master'
            WHEN REGEXP_SUBSTR(AUTHOR_NICKNAME, '^[^ ]+') = 'Flapjacks-over-Eggs' AND LEFT(MSG_CONTENT, 2) = '((' THEN 'Dungeon Master'
            WHEN AUTHOR_NICKNAME ILIKE '%AVRAE%' AND LEFT(EMBED_TITLE, 19) = 'An unknown creature' THEN 'An unknown creature'
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
    FROM WPA.RAW_VIEWS.v_thread20_messages 
    WHERE LEN(MESSAGE) > 4
        AND MESSAGE NOT ILIKE '%Custom Counters%'
        AND MESSAGE <> 'IGNORE THIS'
        AND LEFT(MESSAGE,1) <> '!'
        AND MSG_CONTENT NOT ILIKE '%Selection timed out or was cancelled.%'
        AND MSG_CONTENT NOT ILIKE '%```md%'
        AND MSG_CONTENT NOT ILIKE '%Pinned a message%'
        AND MSG_CONTENT NOT ILIKE '%added to combat with initiative%'
        AND MSG_CONTENT NOT ILIKE '%It is not your turn%'
        AND MSG_CONTENT NOT ILIKE '%Target XX not found%'        
        AND MSG_CONTENT NOT ILIKE '%!cc%'
 ORDER BY THREAD_MSG_NUM;


-- Thread 21
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
SELECT THREAD_ID
    , MSG_ID
    , (10 * ROW_NUMBER() OVER (ORDER BY MSG_TIMESTAMP)) + (THREAD_ID * 1000000) AS THREAD_MSG_NUM
    , LOCATION_NAME
    , CASE  WHEN LEFT(TRIM(MSG_CONTENT), 1) = '>' THEN 'Dungeon Master'
            WHEN REGEXP_SUBSTR(AUTHOR_NICKNAME, '^[^ ]+') = 'Flapjacks-over-Eggs' AND LEFT(MSG_CONTENT, 2) = '((' THEN 'Dungeon Master'
            WHEN AUTHOR_NICKNAME ILIKE '%AVRAE%' AND LEFT(EMBED_TITLE, 19) = 'An unknown creature' THEN 'An unknown creature'
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
    FROM WPA.RAW_VIEWS.v_chron_20250530_messages 
    WHERE LEN(MESSAGE) > 4
        AND MESSAGE NOT ILIKE '%Custom Counters%'
        AND MESSAGE <> 'IGNORE THIS'
        AND LEFT(MESSAGE,1) <> '!'
        AND MSG_CONTENT NOT ILIKE '%Selection timed out or was cancelled.%'
        AND MSG_CONTENT NOT ILIKE '%```md%'
        AND MSG_CONTENT NOT ILIKE '%Pinned a message%'
        AND MSG_CONTENT NOT ILIKE '%added to combat with initiative%'
        AND MSG_CONTENT NOT ILIKE '%It is not your turn%'
        AND MSG_CONTENT NOT ILIKE '%Target XX not found%'        
        AND MSG_CONTENT NOT ILIKE '%!cc%'
 ORDER BY THREAD_MSG_NUM;



-- Insert a single record to indicate the start of a new scene
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
VALUES (17, 0, 8004585, 'swamp: Feligrinn\s Home', 'Dungeon Master', 'New Scene') 
     , (17, 0, 8005135, 'swamp: Plant Men', 'Dungeon Master', 'New Scene') 
     , (17, 0, 9001165, 'swamp: The Hunt for Oona', 'Dungeon Master', 'New Scene')
     , (17, 0, 9001695, 'swamp: The Hunt for Oona', 'Dungeon Master', 'New Scene')
     , (17, 0, 9005845, 'swamp: The Hunt for Oona', 'Dungeon Master', 'New Scene')
     ;

-- CONTINUE HERE...


--SELECT COUNT(*) AS TOTAL_MESSAGES FROM STG_MESSAGES;
--SELECT * FROM STG_MESSAGES ORDER BY THREAD_ID, MSG_ID LIMIT 100;