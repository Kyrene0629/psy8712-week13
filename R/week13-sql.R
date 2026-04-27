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


