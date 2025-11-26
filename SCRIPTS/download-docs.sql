-- ====================================================================
-- GOOGLE DOCS DOWNLOADER FOR SNOWFLAKE
-- ====================================================================
-- This script creates a stored procedure to download Google Docs content
-- using the Google Docs API and store it in a Snowflake table.
--
-- Prerequisites:
-- 1. External access integration (SI_WEB_ACCESS_INTEGRATION) must be set up
-- 2. Google Cloud API key or OAuth credentials
-- 3. Google Docs API must be enabled in your Google Cloud project
--
-- Setup Instructions:
-- 1. Get a Google API Key:
--    - Go to https://console.cloud.google.com/
--    - Create a project or select existing one
--    - Enable Google Docs API
--    - Create credentials (API Key)
-- 2. Store the API key as a Snowflake secret (recommended)
-- 3. Run this script to create the table and stored procedure
-- ====================================================================

USE ROLE SYSADMIN;
USE DATABASE WPA;
USE SCHEMA WPA.APPS;
USE WAREHOUSE COMPUTE_XS;

-- ====================================================================
-- CREATE SECRET FOR GOOGLE API KEY (RECOMMENDED)
-- ====================================================================
-- Uncomment and replace with your actual API key
 CREATE OR REPLACE SECRET GOOGLE_API_KEY
   TYPE = GENERIC_STRING
   SECRET_STRING = 'YOUR_GOOGLE_API_KEY_HERE';

-- ====================================================================
-- CREATE TABLE TO STORE DOWNLOADED DOCUMENTS
-- ====================================================================

CREATE TABLE IF NOT EXISTS GOOGLE_DOCS_CONTENT (
    DOC_ID VARCHAR(500) PRIMARY KEY,
    DOC_TITLE VARCHAR(1000),
    DOC_CONTENT VARIANT,          -- Full JSON response from API
    DOC_TEXT VARCHAR(16777216),    -- Extracted plain text
    DOWNLOAD_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    STATUS VARCHAR(50),             -- 'SUCCESS' or 'ERROR'
    ERROR_MESSAGE VARCHAR(5000),
    METADATA VARIANT                -- Additional metadata
);

-- ====================================================================
-- CREATE STORED PROCEDURE TO DOWNLOAD GOOGLE DOCS
-- ====================================================================

CREATE OR REPLACE PROCEDURE DOWNLOAD_GOOGLE_DOCS(
    DOC_IDS ARRAY,           -- Array of Google Doc IDs to download
    API_KEY VARCHAR          -- Google API Key
)
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
EXTERNAL_ACCESS_INTEGRATIONS = (SI_WEB_ACCESS_INTEGRATION)
AS
$$
    // ================================================================
    // Helper function to make HTTP GET request
    // ================================================================
    function makeHttpRequest(url) {
        try {
            // Create HTTP request
            var request = new XMLHttpRequest();
            request.open('GET', url, false);  // false = synchronous
            request.send();
            
            if (request.status === 200) {
                return {
                    success: true,
                    data: request.responseText,
                    status: request.status
                };
            } else {
                return {
                    success: false,
                    error: 'HTTP ' + request.status + ': ' + request.statusText,
                    data: request.responseText,
                    status: request.status
                };
            }
        } catch (error) {
            return {
                success: false,
                error: 'Request failed: ' + error.toString()
            };
        }
    }
    
    // ================================================================
    // Helper function to extract text from Google Doc content
    // ================================================================
    function extractTextFromDoc(docContent) {
        try {
            var doc = JSON.parse(docContent);
            var textContent = '';
            
            if (doc.body && doc.body.content) {
                for (var i = 0; i < doc.body.content.length; i++) {
                    var element = doc.body.content[i];
                    
                    // Extract text from paragraph
                    if (element.paragraph && element.paragraph.elements) {
                        for (var j = 0; j < element.paragraph.elements.length; j++) {
                            var elem = element.paragraph.elements[j];
                            if (elem.textRun && elem.textRun.content) {
                                textContent += elem.textRun.content;
                            }
                        }
                    }
                    
                    // Extract text from table
                    if (element.table && element.table.tableRows) {
                        for (var r = 0; r < element.table.tableRows.length; r++) {
                            var row = element.table.tableRows[r];
                            if (row.tableCells) {
                                for (var c = 0; c < row.tableCells.length; c++) {
                                    var cell = row.tableCells[c];
                                    if (cell.content) {
                                        for (var k = 0; k < cell.content.length; k++) {
                                            var cellElem = cell.content[k];
                                            if (cellElem.paragraph && cellElem.paragraph.elements) {
                                                for (var l = 0; l < cellElem.paragraph.elements.length; l++) {
                                                    var textElem = cellElem.paragraph.elements[l];
                                                    if (textElem.textRun && textElem.textRun.content) {
                                                        textContent += textElem.textRun.content;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    textContent += '\t';  // Tab between cells
                                }
                                textContent += '\n';  // Newline after row
                            }
                        }
                    }
                }
            }
            
            return textContent;
        } catch (error) {
            return 'Error extracting text: ' + error.toString();
        }
    }
    
    // ================================================================
    // Helper function to escape single quotes for SQL
    // ================================================================
    function escapeSql(str) {
        if (str === null || str === undefined) return 'NULL';
        return str.toString().replace(/'/g, "''");
    }
    
    // ================================================================
    // Main processing logic
    // ================================================================
    var results = {
        total: DOC_IDS.length,
        successful: 0,
        failed: 0,
        errors: []
    };
    
    // Process each document ID
    for (var i = 0; i < DOC_IDS.length; i++) {
        var docId = DOC_IDS[i];
        var docTitle = '';
        var docContent = null;
        var docText = '';
        var status = 'ERROR';
        var errorMessage = '';
        
        try {
            // Construct Google Docs API URL
            var apiUrl = 'https://docs.googleapis.com/v1/documents/' + docId + '?key=' + API_KEY;
            
            // Make HTTP request
            var response = makeHttpRequest(apiUrl);
            
            if (response.success) {
                // Parse response
                docContent = response.data;
                var docJson = JSON.parse(docContent);
                
                // Extract title
                if (docJson.title) {
                    docTitle = docJson.title;
                }
                
                // Extract text content
                docText = extractTextFromDoc(docContent);
                
                status = 'SUCCESS';
                results.successful++;
                
            } else {
                errorMessage = response.error;
                results.failed++;
                results.errors.push({
                    docId: docId,
                    error: errorMessage
                });
            }
            
        } catch (error) {
            errorMessage = 'Processing error: ' + error.toString();
            results.failed++;
            results.errors.push({
                docId: docId,
                error: errorMessage
            });
        }
        
        // Insert into table using MERGE to handle duplicates
        try {
            var sql = `
                MERGE INTO GOOGLE_DOCS_CONTENT AS target
                USING (
                    SELECT 
                        '${escapeSql(docId)}' AS DOC_ID,
                        '${escapeSql(docTitle)}' AS DOC_TITLE,
                        PARSE_JSON('${escapeSql(docContent)}') AS DOC_CONTENT,
                        '${escapeSql(docText)}' AS DOC_TEXT,
                        CURRENT_TIMESTAMP() AS DOWNLOAD_TIMESTAMP,
                        '${status}' AS STATUS,
                        '${escapeSql(errorMessage)}' AS ERROR_MESSAGE,
                        OBJECT_CONSTRUCT('api_response_length', ${docContent ? docContent.length : 0}) AS METADATA
                ) AS source
                ON target.DOC_ID = source.DOC_ID
                WHEN MATCHED THEN UPDATE SET
                    DOC_TITLE = source.DOC_TITLE,
                    DOC_CONTENT = source.DOC_CONTENT,
                    DOC_TEXT = source.DOC_TEXT,
                    DOWNLOAD_TIMESTAMP = source.DOWNLOAD_TIMESTAMP,
                    STATUS = source.STATUS,
                    ERROR_MESSAGE = source.ERROR_MESSAGE,
                    METADATA = source.METADATA
                WHEN NOT MATCHED THEN INSERT (
                    DOC_ID, DOC_TITLE, DOC_CONTENT, DOC_TEXT,
                    DOWNLOAD_TIMESTAMP, STATUS, ERROR_MESSAGE, METADATA
                ) VALUES (
                    source.DOC_ID, source.DOC_TITLE, source.DOC_CONTENT, source.DOC_TEXT,
                    source.DOWNLOAD_TIMESTAMP, source.STATUS, source.ERROR_MESSAGE, source.METADATA
                );
            `;
            
            snowflake.execute({sqlText: sql});
            
        } catch (insertError) {
            results.errors.push({
                docId: docId,
                error: 'Database insert error: ' + insertError.toString()
            });
        }
    }
    
    // Return summary
    return JSON.stringify(results, null, 2);
$$;

-- ====================================================================
-- EXAMPLE USAGE
-- ====================================================================

/*

-- Example 1: Download a single document
CALL DOWNLOAD_GOOGLE_DOCS(
    ARRAY_CONSTRUCT('YOUR_GOOGLE_DOC_ID_HERE'),
    'YOUR_API_KEY_HERE'
);

-- Example 2: Download multiple documents
CALL DOWNLOAD_GOOGLE_DOCS(
    ARRAY_CONSTRUCT(
        '1ABC123XYZ...',  -- Replace with actual doc IDs
        '1DEF456UVW...',
        '1GHI789RST...'
    ),
    'YOUR_API_KEY_HERE'
);

-- Example 3: Using a secret for the API key (recommended)
-- First create the secret (uncomment the CREATE SECRET section above)
-- Then use it in the procedure call:
CALL DOWNLOAD_GOOGLE_DOCS(
    ARRAY_CONSTRUCT('YOUR_GOOGLE_DOC_ID_HERE'),
    (SELECT SECRET_STRING FROM SNOWFLAKE.SECRETS.API_KEYS WHERE NAME = 'GOOGLE_API_KEY')
);

-- Example 4: Query the downloaded documents
SELECT 
    DOC_ID,
    DOC_TITLE,
    LEFT(DOC_TEXT, 200) AS TEXT_PREVIEW,
    DOWNLOAD_TIMESTAMP,
    STATUS
FROM GOOGLE_DOCS_CONTENT
ORDER BY DOWNLOAD_TIMESTAMP DESC;

-- Example 5: Get full text of a specific document
SELECT 
    DOC_TITLE,
    DOC_TEXT
FROM GOOGLE_DOCS_CONTENT
WHERE DOC_ID = 'YOUR_GOOGLE_DOC_ID_HERE';

-- Example 6: Analyze the JSON structure
SELECT 
    DOC_ID,
    DOC_TITLE,
    DOC_CONTENT:title::STRING AS title_from_json,
    DOC_CONTENT:body:content AS body_content
FROM GOOGLE_DOCS_CONTENT
WHERE STATUS = 'SUCCESS';

*/

-- ====================================================================
-- ALTERNATIVE: SIMPLER VERSION WITHOUT TEXT EXTRACTION
-- ====================================================================
-- If you just need the raw JSON without text extraction,
-- uncomment this simpler version:

/*
CREATE OR REPLACE PROCEDURE DOWNLOAD_GOOGLE_DOCS_SIMPLE(
    DOC_IDS ARRAY,
    API_KEY VARCHAR
)
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
EXTERNAL_ACCESS_INTEGRATIONS = (SI_WEB_ACCESS_INTEGRATION)
AS
$$
    var results = {successful: 0, failed: 0, errors: []};
    
    for (var i = 0; i < DOC_IDS.length; i++) {
        var docId = DOC_IDS[i];
        
        try {
            var apiUrl = 'https://docs.googleapis.com/v1/documents/' + docId + '?key=' + API_KEY;
            var request = new XMLHttpRequest();
            request.open('GET', apiUrl, false);
            request.send();
            
            if (request.status === 200) {
                var content = request.responseText;
                var docJson = JSON.parse(content);
                
                var sql = `
                    INSERT INTO GOOGLE_DOCS_CONTENT (DOC_ID, DOC_TITLE, DOC_CONTENT, STATUS)
                    SELECT 
                        '${docId}',
                        '${docJson.title.replace(/'/g, "''")}',
                        PARSE_JSON('${content.replace(/'/g, "''")}'),
                        'SUCCESS'
                `;
                
                snowflake.execute({sqlText: sql});
                results.successful++;
            } else {
                results.failed++;
                results.errors.push({docId: docId, error: 'HTTP ' + request.status});
            }
        } catch (error) {
            results.failed++;
            results.errors.push({docId: docId, error: error.toString()});
        }
    }
    
    return JSON.stringify(results);
$$;
*/

-- ====================================================================
-- HOW TO GET GOOGLE DOC ID
-- ====================================================================
-- The Google Doc ID is in the URL:
-- https://docs.google.com/document/d/1ABC123XYZ.../edit
--                                    ^^^^^^^^^^^
--                                    This is the Doc ID

-- ====================================================================
-- TROUBLESHOOTING
-- ====================================================================
-- 1. If you get "Network rule not found" error:
--    Make sure SI_WEB_ACCESS_INTEGRATION is created (check setup-wpa-role.sql)
--
-- 2. If you get 403 Forbidden:
--    - Check that your API key is valid
--    - Make sure Google Docs API is enabled in Google Cloud Console
--    - Verify the document is accessible (not private)
--
-- 3. If you get 404 Not Found:
--    - Verify the document ID is correct
--    - Make sure the document exists and you have access to it
--
-- 4. To test your API key and doc ID manually:
--    Use curl: curl "https://docs.googleapis.com/v1/documents/YOUR_DOC_ID?key=YOUR_API_KEY"

-- ====================================================================
-- CLEANUP (if needed)
-- ====================================================================
-- DROP TABLE IF EXISTS GOOGLE_DOCS_CONTENT;
-- DROP PROCEDURE IF EXISTS DOWNLOAD_GOOGLE_DOCS(ARRAY, VARCHAR);

