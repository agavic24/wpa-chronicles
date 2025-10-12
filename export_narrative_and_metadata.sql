-- ============================================================================
-- EXPORT SCENE NARRATIVE AND METADATA TO CSV FORMAT
-- ============================================================================
-- This query uses COPY INTO to export data directly to CSV files
-- Output will be written to the WPA.RAW_DATA.RAW_WPA stage
-- ============================================================================

USE ROLE SYSADMIN;
USE SCHEMA WPA.DATA;

-- ============================================================================
-- Export 1: Complete markdown document to CSV file
-- ============================================================================
COPY INTO @WPA.RAW_DATA.RAW_WPA/WPA_NARRATIVE_1_to_83.csv
FROM (
    SELECT 
        '# Written Path Adventures\n\n' ||
        LISTAGG(
            '## ' || SCENE_TITLE || '\n\n' ||
            '### ' || PRIMARY_LOCATION || '\n\n' ||
            NARRATIVE_TEXT || '\n\n',
            ''
        ) WITHIN GROUP (ORDER BY SCENE_NUM)
        AS markdown_content
    FROM SCENE_NARRATIVE
)
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    RECORD_DELIMITER = '\n'
    COMPRESSION = 'NONE'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
)
SINGLE = TRUE
OVERWRITE = TRUE
HEADER = FALSE;

-- ============================================================================
-- Export 2: Scene metadata to CSV file
-- ============================================================================
COPY INTO @WPA.RAW_DATA.RAW_WPA/SCENE_METADATA.csv
FROM (
    SELECT *
    FROM SCENE_METADATA
    ORDER BY SCENE_NUM
)
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    RECORD_DELIMITER = '\n'
    COMPRESSION = 'NONE'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE_UNENCLOSED_FIELD = NONE
)
SINGLE = TRUE
OVERWRITE = TRUE
HEADER = TRUE;

