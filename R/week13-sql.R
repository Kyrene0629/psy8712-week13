# Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) 
library(DBI)
library(RPostgres)
library(tidyverse)

# Data Import and Cleaning
# Connect to the SQL database using the host, port, database name, and SSL requirement from the lecture on Wednesday
# Use constants NEON_USER and NEON_PW so that they are not saved in plain text
con <- dbConnect(
  RPostgres::Postgres(),
  host = "ep-billowing-union-am14lcnh-pooler.c-5.us-east-1.aws.neon.tech",
  port = 5432,
  dbname = "neondb",
  user = Sys.getenv("NEON_USER"),
  password = Sys.getenv("NEON_PW"),
  sslmode = "require"
)

# Analysis
# display the total number of managers
# I use an INNER JOIN for the test score table becuase only employees with test scores are included.
# test_score IS NOT NULL is used to make sure the query only counts employees who actually have the test score
dbGetQuery(con, "
           SELECT COUNT(employee_id) AS total_managers
           FROM datascience_employees
           INNER JOIN datascience_testscores
           USING (employee_id)
           WHERE test_score IS NOT NULL
           ")

# display the total number of unique managers
# DISTINCT is used to make sure that each employee_id is only counted once
# INNER JOIN can limit the data to those employees who have test scores
dbGetQuery(con, "
           SELECT COUNT(DISTINCT employee_id) AS unique_managers
           FROM datascience_employees
           INNER JOIN datascience_testscores
           USING (employee_id)
           WHERE test_score IS NOT NULL
           ")

# display a summary of the number of managers split by location, but only include those who were not originally hired as managers
# manager_hire = 'N' onlt keep managers who are not originally hired as managers
# GROUP BY city creates a count for each city separately, and ORDER BY city ASC sort the output alphabeticaally
dbGetQuery(con, "
           SELECT city, 
                  COUNT(employee_id) AS n_managers
           FROM datascience_employees
           INNER JOIN datascience_testscores
           USING (employee_id)
           WHERE test_score IS NOT NULL
             AND manager_hire = 'N'
           GROUP BY city
           ORDER BY city ASC
           ")

# display the mean & sd of number of years of employment split by performance level
# AVG() calculates the mean of number of years of employment within each performance group
# STDDEV() calculates the standard deviation of that within each performance group
# GROUP BY performance_group creates a separate summary for bottom, middle, and top performance level
dbGetQuery(con, "
           SELECT performance_group,
                  AVG(yrs_employed) AS mean_yrs_employed,
                  STDDEV(yrs_employed) AS sd_yrs_employed
           FROM datascience_employees
           INNER JOIN datascience_testscores
           USING (employee_id)
           WHERE test_score IS NOT NULL
           GROUP BY performance_group
           ")

# display each manager's location classification (urban vs. suburban), ID number, and test score, in alphabetical order by location type and then descending order of test score
# I join the offices table because office_type has the urban vs suburban each manager's location classification
# The ON statement can match employee city to the office name in the office table
# ORDER BY can sort office type alphabetically and then sort test scores from highest to lowest for each office type
dbGetQuery(con, "
           SELECT office_type,
                  employee_id,
                  test_score
           FROM datascience_employees
           INNER JOIN datascience_testscores
           USING (employee_id)
           LEFT JOIN datascience_offices
           ON datascience_employees.city = datascience_offices.office
           WHERE test_score IS NOT NULL
           ORDER BY office_type ASC, test_score DESC
           ")
