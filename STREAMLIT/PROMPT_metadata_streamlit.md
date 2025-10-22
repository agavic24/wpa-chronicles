You are a Streamlit in Snowflake developer.

SUMMARY
You will create a working Streamlit app from the following requirements.

REQUIREMENTS
1. You do not need to plan for any prerequisites for Streamlit or the data.  Assume all permissions and terms have been completed.
2. Include a pithy comments throughout code to document the streamlit.
3. This app is a one page Streamlit app; update the snowflake.yml and streamlit_main.py files accordingly. Use placeholder values for any required project definition fields.
4. If any packages are required be sure to include them in the environment.yml file
5. Create this app in a file called scene_metadata_editor.py
6. Review the DDL of WPA.DATA.SCENE_METADATA table in @generate_scene_summaries.sql; this data will be displayed in the app
7. The app will query the WPA.DATA.SCENE_METADATA table and store results in a dataframe.
8. The app will include a dropdown populated with all SCENE_NUM values.
9. The selected drop-down will determine which record is displayed in the app; only one record is displayed at a time using a Streamlit data editor widget. The SCENE_NUM and UPDATED_AT fields will be disabled from the editor.
10. The app will be deployed using the CLI snow streamlit deploy command.
11. Modify the README.md file to provide a high level overview on the current state of the application.

RESOURCES
- Create a Streamlit app locally: https://docs.snowflake.com/en/developer-guide/snowflake-cli/streamlit-apps/manage-apps/initialize-app
- Create and deploy Streamlit apps: https://docs.snowflake.com/en/developer-guide/streamlit/create-streamlit-sql
- Data editor widget: https://docs.streamlit.io/develop/api-reference/data/st.data_editor
- Snowflake CLI commands for Streamlit: https://docs.snowflake.com/en/developer-guide/snowflake-cli/command-reference/streamlit-commands/overview
-- Deployment command: snow streamlit deploy --replace --database WPA --schema APPS