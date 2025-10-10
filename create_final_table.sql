-- Create the final table with session numbers

-- check if THREAD_MSG_NUM IS A NUMBER THAT HAS 0010 AS THE LAST FOUR DIGITS

-- Final logic        
CREATE OR REPLACE TABLE FINAL_MESSAGES AS
SELECT 
    SUM(CASE WHEN THREAD_MSG_NUM IN (21010010, 21020010) THEN 0 
             WHEN MESSAGE = 'Start Init' OR MESSAGE = 'End Init' OR MESSAGE = 'New Scene' 
                 OR MOD(THREAD_MSG_NUM, 10000) = 10 -- NEW LOCATION MARKER
                    THEN 1 ELSE 0 END) OVER (ORDER BY THREAD_MSG_NUM ROWS UNBOUNDED PRECEDING) AS SESSION_NUM,
    THREAD_MSG_NUM,
    LOCATION_NAME,
    CHARACTER_NAME,
    MESSAGE    
FROM STG_MESSAGES
ORDER BY THREAD_MSG_NUM
;

SELECT SESSION_NUM, COUNT(*) AS MESSAGE_COUNT
FROM FINAL_MESSAGES GROUP BY ALL ORDER BY SESSION_NUM
;

SELECT *
FROM FINAL_MESSAGES
ORDER BY THREAD_MSG_NUM
;


-- show the preceding 3 rows and the following 3 rows for messages with 'Start Init'
SELECT * EXCLUDE( CHARACTER_NAME, PREV_SESSION) FROM (
SELECT 
    THREAD_MSG_NUM,
    CHARACTER_NAME,
    LAG(SESSION_NUM, 1) OVER (ORDER BY THREAD_MSG_NUM) AS PREV_SESSION,
    SESSION_NUM,
    LAG(LOCATION_NAME,1) OVER (ORDER BY THREAD_MSG_NUM) AS PREV_LOCATION,
    LOCATION_NAME,
    LAG(MESSAGE, 3) OVER (ORDER BY THREAD_MSG_NUM) AS PREVIOUS_3,
    LAG(MESSAGE, 2) OVER (ORDER BY THREAD_MSG_NUM) AS PREVIOUS_2,
    LAG(MESSAGE, 1) OVER (ORDER BY THREAD_MSG_NUM) AS PREVIOUS_1,
    MESSAGE,
    LEAD(MESSAGE, 1) OVER (ORDER BY THREAD_MSG_NUM) AS NEXT_1,
    LEAD(MESSAGE, 2) OVER (ORDER BY THREAD_MSG_NUM) AS NEXT_2,
    LEAD(MESSAGE, 3) OVER (ORDER BY THREAD_MSG_NUM) AS NEXT_3
FROM FINAL_MESSAGES
)
WHERE SESSION_NUM <> PREV_SESSION
ORDER BY THREAD_MSG_NUM
;

SELECT THREAD_MSG_NUM,LOCATION_NAME, MESSAGE,
LEAD(MESSAGE, 1) OVER (ORDER BY THREAD_MSG_NUM) AS NEXT_THREAD,
LEAD(LOCATION_NAME, 1) OVER (ORDER BY THREAD_MSG_NUM) AS NEXT_LOCATION
FROM STG_MESSAGES
WHERE MESSAGE = 'End Init'
;


SELECT THREAD_MSG_NUM, LOCATION_NAME, MESSAGE
FROM STG_MESSAGES 
WHERE THREAD_MSG_NUM >= 17005400

ORDER BY THREAD_MSG_NUM
limit 300;

8004590 -- NEW SCENE

SELECT MSG_ID, LEFT(MSG_CONTENT, 25) AS MESSAGE_START, *
FROM WPA.RAW_VIEWS.v_thread17_messages 
--WHERE MSG_ID > 1345160368225255505 AND MSG_ID < 1351589087035002950
;

WITH SESS AS (
    -- Your query that aggregates events into a single string
    SELECT 
        SESSION_NUM
        , LISTAGG(        
            CONCAT('Msg #: ', THREAD_MSG_NUM, ' | Location: ', LOCATION_NAME, ' | Persona: ', CHARACTER_NAME, ' | Message: ', MESSAGE), 
            '\n'
            ) WITHIN GROUP (ORDER BY THREAD_MSG_NUM) AS SESSION_LOG
        , CONCAT(
            'You are a fantasy chronicler creating a D&D session summary. ',
            'Analyze the following session events and create a structured scroll entry.\n\n',
            'Use rich, descriptive language to capture the atmosphere and tone of the session. ',
            'Ensure clarity and coherence, making it engaging for readers. ',
            'Focus on the most impactful moments and details. ',
            'Avoid extraneous information. ',
            'Format the output as a well-structured scroll entry.\n\n',
            'Required format:\n',
            '- Session Title: [Create an evocative title]\n',
            '- Location(s): [Extract all locations mentioned]\n',
            '- Key NPCs Encountered: [List NPCs with brief descriptions]\n',
            '- Party Members Present: [List player characters]\n',
            '- Major Events Summary: [Narrative overview of what happened]\n',
            '- Loot & Rewards: [Items, gold, XP mentioned]\n',
            '- Unresolved Threads: [Open plot hooks or cliffhangers]\n',
            '- Key Quotes: [Memorable dialogue]\n',
            '- Casualties/Consequences: [Deaths, injuries, setbacks]\n',
            '- Maps/Sketches Notes: [References to locations needing maps]\n\n'              
        ) AS PROMPT
    FROM FINAL_MESSAGES
    GROUP BY ALL
)

SELECT SESSION_NUM
    , AI_AGG(SESSION_LOG,PROMPT ) AS SESSION_SCROLL
FROM SESS
GROUP BY SESSION_NUM
;



-- Your query that aggregates events into a single string
    SELECT 
        SESSION_NUM,
        LISTAGG(        
            CONCAT('Msg #: ', THREAD_MSG_NUM, ' | Location: ', LOCATION_NAME, ' | Persona: ', CHARACTER_NAME, ' | Message: ', MESSAGE), 
            '\n'
        ) WITHIN GROUP (ORDER BY THREAD_MSG_NUM) AS event_log
    FROM FINAL_MESSAGES
    GROUP BY SESSION_NUM
    ;