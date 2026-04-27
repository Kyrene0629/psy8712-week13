setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) 
library(DBI)
library(RPostgres)
library(tidyverse)

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
dbGetQuery(con, "
           SELECT COUNT(employee_id) AS total_managers
           FROM datascience_employees
           INNER JOIN datascience_testscores
           USING (employee_id)
           WHERE test_score IS NOT NULL
           ")

# display the total number of unique managers
dbGetQuery(con, "
           SELECT COUNT(DISTINCT employee_id) AS unique_managers
           FROM datascience_employees
           INNER JOIN datascience_testscores
           USING (employee_id)
           WHERE test_score IS NOT NULL
           ")

# display a summary of the number of managers split by location, but only include those who were not originally hired as managers
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
