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

# download the three SQL tables
employees_tbl <- dbGetQuery(con, "SELECT * 
                            FROM datascience_employees")
testscores_tbl <- dbGetQuery(con, "SELECT * 
                             FROM datascience_testscores")
offices_tbl <- dbGetQuery(con, "SELECT * 
                          FROM datascience_offices")

# save the imported tables into the out subfolder
write_csv(employees_tbl, "../out/employees.csv")
write_csv(testscores_tbl, "../out/testscores.csv")
write_csv(offices_tbl, "../out/offices.csv")

# combine & save data that remove employees without test scores using joins only
week13_tbl <- employees_tbl %>%
  inner_join(testscores_tbl, by = "employee_id") %>%
  left_join(offices_tbl, by = c("city" = "office"))
write_csv(week13_tbl, "../out/week13.csv")


# Analysis
# display the total number of managers
total_managers_tbl <- week13_tbl %>%
  summarise(total_managers = n())
total_managers_tbl

# display the total number of unique managers
unique_managers_tbl <- week13_tbl %>%
  summarise(unique_managers = n_distinct(employee_id))
unique_managers_tbl

# diaplay a summary of the number of managers split by location, but only include those who were not originally hired as managers
managers_by_location_tbl <- week13_tbl %>% 
  filter(manager_hire == "N") %>% 
  count(office_type, name = "n_managers")
managers_by_location_tbl

# display the mean & sd of number of years of employment split by performance level
years_performance_tbl <- week13_tbl %>% 
  group_by(performance_group) %>% 
  summarise(
    mean_yrs_employed = mean(yrs_employed),
    sd_yrs_employed = sd(yrs_employed)
  )
years_performance_tbl

# display each manager's location classification (urban vs. suburban), ID number, and test score, in alphabetical order by location type and then descending order of test score
manager_scores_tbl <- week13_tbl %>% 
  select(office_type, employee_id, test_score) %>% 
  arrange(office_type, desc(test_score))
manager_scores_tbl

