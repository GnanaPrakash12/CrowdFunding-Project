# CrowdFunding-Project
This repository contains the Crowdfunding Data Analysis project (2009–2019). The project demonstrates an end-to-end analytics pipeline: data cleaning (Excel), data modelling & queries (MySQL), and interactive dashboards (Tableau & Power BI). The deliverables include SQL scripts, datasets, dashboards, and the presentation.

---

## Repository structure

- data/ — Raw data files (Project.xlsx, Creator.xlsx).  
- sql/ — SQL scripts (table creation, transformations, calendar, queries Q3–Q12).  
- dashboards/tableau/ — Tableau workbook or exported images.  
- dashboards/powerbi/ — Power BI report file (.pbix) or exported images.  
- docs/screenshots/ — Screenshots used in the PPT or README.  
- presentation/ — Final PPT file for viva.  
- .gitignore — Recommended ignores.  
- LICENSE — License file (MIT recommended).

---

## Quickstart

### Prerequisites
- MySQL 8.0+ (Workbench recommended).  
- Tableau Desktop (or Tableau Reader) — optional for viewing workbook.  
- Power BI Desktop — optional for viewing .pbix.  
- Git installed locally.

### Steps to run the analysis locally
1. Import data files into MySQL (Workbench):  
   - Save Project.xlsx and Creator.xlsx as CSV (if desired).  
   - Use LOAD DATA LOCAL INFILE or Workbench CSV import to load into projects and creators staging tables.

2. Run the SQL scripts (in order) from /sql:
   - 01_create_tables_Project.sql — creates staging tables and schema.
   - 03_transform_epoch_to_datetime.sql — converts epoch to DATETIME.
   - 04_calendar_table.sql — builds a calendar table used for time analysis.
   - 05_normalization_fact_dim.sql — creates fact_projects, dim_category, dim_location.
   - 06_queries_Q4_to_Q12.sql — contains KPI queries and views.

3. Export the SQL query outputs (CSV) and connect Tableau / Power BI to those exported tables or directly to your MySQL database.

4. Open dashboards/tableau/... in Tableau and dashboards/powerbi/... in Power BI to reproduce visualizations.

---

## Key SQL queries (high level)
- Convert epoch → DATETIME: UPDATE projects SET created_dt = FROM_UNIXTIME(created_at);
- Calendar generation: use WITH RECURSIVE or numbers-table technique (scripts included).
- Success rate: SELECT ROUND(SUM(state='successful')*100.0/COUNT(*),2) FROM fact_projects;
- KPIs: top categories, top countries by pledged, avg goal vs pledged, time-based trends.

---

