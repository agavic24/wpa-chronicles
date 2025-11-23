-- ====================================================================
-- CREATE WPA.DATA.SHEETS TABLE
-- ====================================================================
-- This table stores character sheets from markdown files
-- One row per sheet with all content in a single large VARCHAR field

USE ROLE SYSADMIN;
USE SCHEMA WPA.DATA;

-- Drop table if exists (optional - remove if you want to preserve data)
-- DROP TABLE IF EXISTS WPA.DATA.SHEETS;

-- Create the SHEETS table
CREATE OR REPLACE TABLE WPA.DATA.SHEETS (
    sheet_name VARCHAR(255) NOT NULL,
    sheet_content VARCHAR(16777216),  -- Large VARCHAR to store full markdown content (up to 16MB)
    created_at TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ====================================================================
-- CREATE FILE FORMAT FOR MARKDOWN FILES
-- ====================================================================
-- Create a file format that reads the entire file as one field

CREATE OR REPLACE FILE FORMAT WPA.DATA.MD_FILE_FORMAT
    TYPE = 'CSV'
    COMPRESSION = 'AUTO'
    FIELD_DELIMITER = 'NONE'
    RECORD_DELIMITER = 'NONE'
    SKIP_HEADER = 0
    FIELD_OPTIONALLY_ENCLOSED_BY = 'NONE'
    TRIM_SPACE = FALSE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    ESCAPE = 'NONE'
    ESCAPE_UNENCLOSED_FIELD = 'NONE'
    DATE_FORMAT = 'AUTO'
    TIMESTAMP_FORMAT = 'AUTO'
    NULL_IF = ()
    COMMENT = 'File format to read entire markdown file as single field';

-- ====================================================================
-- LOAD DATA FROM STAGE WPA.DATA.DOCS
-- ====================================================================
-- Load markdown files from the stage into the SHEETS table
-- Each file becomes ONE ROW with all content in sheet_content field

COPY INTO WPA.DATA.SHEETS (sheet_name, sheet_content)
FROM (
    SELECT 
        REGEXP_REPLACE(METADATA$FILENAME, '.*/(.+)\\.md$', '\\1') AS sheet_name,  -- Extract filename without path and extension
        $1 AS sheet_content  -- Entire file content as one field
    FROM @WPA.DATA.DOCS
)
FILE_FORMAT = (FORMAT_NAME = 'WPA.DATA.MD_FILE_FORMAT')
PATTERN = '.*\\.md$'  -- Only load markdown files
ON_ERROR = 'CONTINUE';  -- Continue if some files have issues

-- Verify the data was loaded (should see one row per sheet)
SELECT 
    sheet_name,
    LENGTH(sheet_content) AS content_length_bytes,
    LEFT(sheet_content, 100) AS content_preview,
    created_at
FROM WPA.DATA.SHEETS
ORDER BY sheet_name;

-- SETUP SEARCH SERVICE
USE ROLE WPA_SI_ROLE;
USE SCHEMA WPA.APPS;
CREATE OR REPLACE CORTEX SEARCH SERVICE WPA.APPS.WPA_SHEET_SEARCH
  ON SHEET_CONTENT
  ATTRIBUTES SHEET_NAME
  WAREHOUSE = COMPUTE_XS
  TARGET_LAG = '1 day'
AS SELECT * FROM WPA.DATA.SHEETS;
ALTER CORTEX SEARCH SERVICE WPA_SHEET_SEARCH SUSPEND INDEXING;
DESC CORTEX SEARCH SERVICE WPA_SHEET_SEARCH;

USE ROLE ACCOUNTADMIN;
ALTER SNOWFLAKE INTELLIGENCE SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT ADD AGENT WPA.APPS.WPA_AGENT;
