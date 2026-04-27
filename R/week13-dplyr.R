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


