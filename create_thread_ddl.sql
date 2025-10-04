-- Snowflake DDL for flattening all JSON thread files (t1.json through t20.json)
-- This creates tables and views to extract message data from all JSON files

-- =============================================================================
-- SECTION 1: CREATE RAW TABLES FOR ALL JSON FILES
-- =============================================================================

USE ROLE SYSADMIN;
USE SCHEMA WPA.RAW_DATA;

-- Create staging tables to hold the raw JSON data for each thread
CREATE OR REPLACE TABLE raw_json_t1_data (file_content VARIANT);
CREATE OR REPLACE TABLE raw_json_t2_data (file_content VARIANT);
CREATE OR REPLACE TABLE raw_json_t3_data (file_content VARIANT);
CREATE OR REPLACE TABLE raw_json_t4_data (file_content VARIANT);
CREATE OR REPLACE TABLE raw_json_t5_data (file_content VARIANT);
CREATE OR REPLACE TABLE raw_json_t6_data (file_content VARIANT);
CREATE OR REPLACE TABLE raw_json_t7_data (file_content VARIANT);
CREATE OR REPLACE TABLE raw_json_t8_data (file_content VARIANT);
CREATE OR REPLACE TABLE raw_json_t9_data (file_content VARIANT);
CREATE OR REPLACE TABLE raw_json_t10_data (file_content VARIANT);
CREATE OR REPLACE TABLE raw_json_t11_data (file_content VARIANT);
CREATE OR REPLACE TABLE raw_json_t12_data (file_content VARIANT);
CREATE OR REPLACE TABLE raw_json_t13_data (file_content VARIANT);
CREATE OR REPLACE TABLE raw_json_t14_data (file_content VARIANT);
CREATE OR REPLACE TABLE raw_json_t15_data (file_content VARIANT);
CREATE OR REPLACE TABLE raw_json_t16_data (file_content VARIANT);
CREATE OR REPLACE TABLE raw_json_t17_data (file_content VARIANT);
CREATE OR REPLACE TABLE raw_json_t18_data (file_content VARIANT);
CREATE OR REPLACE TABLE raw_json_t19_data (file_content VARIANT);
CREATE OR REPLACE TABLE raw_json_t20_data (file_content VARIANT);
CREATE OR REPLACE TABLE raw_json_chron_20250530 (file_content VARIANT);

-- =============================================================================
-- SECTION 2: COPY DATA FROM JSON FILES INTO RAW TABLES
-- =============================================================================

-- Load the JSON files into their respective staging tables
COPY INTO raw_json_t1_data FROM @RAW_WPA/t1.json FILE_FORMAT = (TYPE = 'JSON');
COPY INTO raw_json_t2_data FROM @RAW_WPA/t2.json FILE_FORMAT = (TYPE = 'JSON');
COPY INTO raw_json_t3_data FROM @RAW_WPA/t3.json FILE_FORMAT = (TYPE = 'JSON');
COPY INTO raw_json_t4_data FROM @RAW_WPA/t4.json FILE_FORMAT = (TYPE = 'JSON');
COPY INTO raw_json_t5_data FROM @RAW_WPA/t5.json FILE_FORMAT = (TYPE = 'JSON');
COPY INTO raw_json_t6_data FROM @RAW_WPA/t6.json FILE_FORMAT = (TYPE = 'JSON');
COPY INTO raw_json_t7_data FROM @RAW_WPA/t7.json FILE_FORMAT = (TYPE = 'JSON');
COPY INTO raw_json_t8_data FROM @RAW_WPA/t8.json FILE_FORMAT = (TYPE = 'JSON');
COPY INTO raw_json_t9_data FROM @RAW_WPA/t9.json FILE_FORMAT = (TYPE = 'JSON');
COPY INTO raw_json_t10_data FROM @RAW_WPA/t10.json FILE_FORMAT = (TYPE = 'JSON');
COPY INTO raw_json_t11_data FROM @RAW_WPA/t11.json FILE_FORMAT = (TYPE = 'JSON');
COPY INTO raw_json_t12_data FROM @RAW_WPA/t12.json FILE_FORMAT = (TYPE = 'JSON');
COPY INTO raw_json_t13_data FROM @RAW_WPA/t13.json FILE_FORMAT = (TYPE = 'JSON');
COPY INTO raw_json_t14_data FROM @RAW_WPA/t14.json FILE_FORMAT = (TYPE = 'JSON');
COPY INTO raw_json_t15_data FROM @RAW_WPA/t15.json FILE_FORMAT = (TYPE = 'JSON');
COPY INTO raw_json_t16_data FROM @RAW_WPA/t16.json FILE_FORMAT = (TYPE = 'JSON');
COPY INTO raw_json_t17_data FROM @RAW_WPA/t17.json FILE_FORMAT = (TYPE = 'JSON');
COPY INTO raw_json_t18_data FROM @RAW_WPA/t18.json FILE_FORMAT = (TYPE = 'JSON');
COPY INTO raw_json_t19_data FROM @RAW_WPA/t19.json FILE_FORMAT = (TYPE = 'JSON');
COPY INTO raw_json_t20_data FROM @RAW_WPA/t20.json FILE_FORMAT = (TYPE = 'JSON');
COPY INTO raw_json_chron_20250530 FROM @RAW_WPA/the-chronicles-20250530.json FILE_FORMAT = (TYPE = 'JSON');

-- =============================================================================
-- SECTION 3: CREATE VIEWS FOR FLATTENED MESSAGE DATA
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS WPA.RAW_VIEWS;

-- Create views to flatten the messages array for each thread
USE SCHEMA WPA.RAW_VIEWS;

CREATE OR REPLACE VIEW v_thread1_messages AS
SELECT 
    1 as thread_id,
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
FROM WPA.RAW_DATA.raw_json_t1_data,
LATERAL FLATTEN(input => file_content:messages) as msg,
LATERAL FLATTEN(input => msg.value:embeds[0].fields, outer => true) as f
GROUP BY ALL;

CREATE OR REPLACE VIEW v_thread2_messages AS
SELECT 
    2 as thread_id,
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
FROM WPA.RAW_DATA.raw_json_t2_data,
LATERAL FLATTEN(input => file_content:messages) as msg,
LATERAL FLATTEN(input => msg.value:embeds[0].fields, outer => true) as f
GROUP BY ALL;

CREATE OR REPLACE VIEW v_thread3_messages AS
SELECT 
    3 as thread_id,
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
FROM WPA.RAW_DATA.raw_json_t3_data,
LATERAL FLATTEN(input => file_content:messages) as msg,
LATERAL FLATTEN(input => msg.value:embeds[0].fields, outer => true) as f
GROUP BY ALL;

CREATE OR REPLACE VIEW v_thread4_messages AS
SELECT 
    4 as thread_id,
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
FROM WPA.RAW_DATA.raw_json_t4_data,
LATERAL FLATTEN(input => file_content:messages) as msg,
LATERAL FLATTEN(input => msg.value:embeds[0].fields, outer => true) as f
GROUP BY ALL;

CREATE OR REPLACE VIEW v_thread5_messages AS
SELECT 
    5 as thread_id,
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
FROM WPA.RAW_DATA.raw_json_t5_data,
LATERAL FLATTEN(input => file_content:messages) as msg,
LATERAL FLATTEN(input => msg.value:embeds[0].fields, outer => true) as f
GROUP BY ALL;

CREATE OR REPLACE VIEW v_thread6_messages AS
SELECT 
    6 as thread_id,
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
FROM WPA.RAW_DATA.raw_json_t6_data,
LATERAL FLATTEN(input => file_content:messages) as msg,
LATERAL FLATTEN(input => msg.value:embeds[0].fields, outer => true) as f
GROUP BY ALL;

CREATE OR REPLACE VIEW v_thread7_messages AS
SELECT 
    7 as thread_id,
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
FROM WPA.RAW_DATA.raw_json_t7_data,
LATERAL FLATTEN(input => file_content:messages) as msg,
LATERAL FLATTEN(input => msg.value:embeds[0].fields, outer => true) as f
GROUP BY ALL;

CREATE OR REPLACE VIEW v_thread8_messages AS
SELECT 
    8 as thread_id,
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
FROM WPA.RAW_DATA.raw_json_t8_data,
LATERAL FLATTEN(input => file_content:messages) as msg,
LATERAL FLATTEN(input => msg.value:embeds[0].fields, outer => true) as f
GROUP BY ALL;

CREATE OR REPLACE VIEW v_thread9_messages AS
SELECT 
    9 as thread_id,
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
FROM WPA.RAW_DATA.raw_json_t9_data,
LATERAL FLATTEN(input => file_content:messages) as msg,
LATERAL FLATTEN(input => msg.value:embeds[0].fields, outer => true) as f
GROUP BY ALL;

CREATE OR REPLACE VIEW v_thread10_messages AS
SELECT 
    10 as thread_id,
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
FROM WPA.RAW_DATA.raw_json_t10_data,
LATERAL FLATTEN(input => file_content:messages) as msg,
LATERAL FLATTEN(input => msg.value:embeds[0].fields, outer => true) as f
GROUP BY ALL;

CREATE OR REPLACE VIEW v_thread11_messages AS
SELECT 
    11 as thread_id,
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
FROM WPA.RAW_DATA.raw_json_t11_data,
LATERAL FLATTEN(input => file_content:messages) as msg,
LATERAL FLATTEN(input => msg.value:embeds[0].fields, outer => true) as f
GROUP BY ALL;

CREATE OR REPLACE VIEW v_thread12_messages AS
SELECT 
    12 as thread_id,
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
FROM WPA.RAW_DATA.raw_json_t12_data,
LATERAL FLATTEN(input => file_content:messages) as msg,
LATERAL FLATTEN(input => msg.value:embeds[0].fields, outer => true) as f
GROUP BY ALL;

CREATE OR REPLACE VIEW v_thread13_messages AS
SELECT 
    13 as thread_id,
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
FROM WPA.RAW_DATA.raw_json_t13_data,
LATERAL FLATTEN(input => file_content:messages) as msg,
LATERAL FLATTEN(input => msg.value:embeds[0].fields, outer => true) as f
GROUP BY ALL;

CREATE OR REPLACE VIEW v_thread14_messages AS
SELECT 
    14 as thread_id,
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
FROM WPA.RAW_DATA.raw_json_t14_data,
LATERAL FLATTEN(input => file_content:messages) as msg,
LATERAL FLATTEN(input => msg.value:embeds[0].fields, outer => true) as f
GROUP BY ALL;

CREATE OR REPLACE VIEW v_thread15_messages AS
SELECT 
    15 as thread_id,
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
FROM WPA.RAW_DATA.raw_json_t15_data,
LATERAL FLATTEN(input => file_content:messages) as msg,
LATERAL FLATTEN(input => msg.value:embeds[0].fields, outer => true) as f
GROUP BY ALL;

CREATE OR REPLACE VIEW v_thread16_messages AS
SELECT 
    16 as thread_id,
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
FROM WPA.RAW_DATA.raw_json_t16_data,
LATERAL FLATTEN(input => file_content:messages) as msg,
LATERAL FLATTEN(input => msg.value:embeds[0].fields, outer => true) as f
GROUP BY ALL;

CREATE OR REPLACE VIEW v_thread17_messages AS
SELECT 
    17 as thread_id,
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
FROM WPA.RAW_DATA.raw_json_t17_data,
LATERAL FLATTEN(input => file_content:messages) as msg,
LATERAL FLATTEN(input => msg.value:embeds[0].fields, outer => true) as f
GROUP BY ALL;

CREATE OR REPLACE VIEW v_thread18_messages AS
SELECT 
    18 as thread_id,
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
FROM WPA.RAW_DATA.raw_json_t18_data,
LATERAL FLATTEN(input => file_content:messages) as msg,
LATERAL FLATTEN(input => msg.value:embeds[0].fields, outer => true) as f
GROUP BY ALL;

CREATE OR REPLACE VIEW v_thread19_messages AS
SELECT 
    19 as thread_id,
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
FROM WPA.RAW_DATA.raw_json_t19_data,
LATERAL FLATTEN(input => file_content:messages) as msg,
LATERAL FLATTEN(input => msg.value:embeds[0].fields, outer => true) as f
GROUP BY ALL;

CREATE OR REPLACE VIEW v_thread20_messages AS
SELECT 
    20 as thread_id,
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
FROM WPA.RAW_DATA.raw_json_t20_data,
LATERAL FLATTEN(input => file_content:messages) as msg,
LATERAL FLATTEN(input => msg.value:embeds[0].fields, outer => true) as f
GROUP BY ALL;

CREATE OR REPLACE VIEW v_chron_20250530_messages AS
SELECT 
    21 as thread_id,
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
FROM WPA.RAW_DATA.raw_json_chron_20250530,
LATERAL FLATTEN(input => file_content:messages) as msg,
LATERAL FLATTEN(input => msg.value:embeds[0].fields, outer => true) as f
GROUP BY ALL;    

-- =============================================================================

--- Sample data
select * from wpa.raw_data.raw_json_t13_data;
select * from wpa.RAW_VIEWS.v_thread13_messages;
