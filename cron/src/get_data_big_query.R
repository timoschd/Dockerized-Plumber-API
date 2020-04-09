## Header --------------------------- 
##
## Script name: Get Data Big Query
##
## Purpose of script: Get Data From Bigquery public dataset
##
## Author: Tim M. Schendzielorz 
##
## Date Created: 2019-12-14
##
## Copyright (c) Tim M. Schendzielorz, 2019
## Email: tim.schendzielorz@googlemail.com
##
## ---
##
## Notes:
##   
##
## ---

## set working directory for Mac and PC

#setwd("~/Google Drive/")                          # Tim's working directory (mac)
#setwd("C:/Users/tim/Google Drive/")              # Tim's working directory (PC)

## Global Options ---------------------------

options(scipen = 7, digits = 2,  encoding = "UTF-8") # I prefer to view outputs in non-scientific notation
#memory.limit(30000000)               # this is needed on some PCs to increase memory allowance, but has no impact on macs.

## Packages and Functions ---------------------------

## load up the packages we will need:  (uncomment as required)

pacman::p_load("tidyverse", "lubridate", "padr", "dbplyr", "DBI", "bigrquery")

# source("functions/packages.R")       # loads up all the packages we need

## --

## load up our functions into memory

# source("functions/summarise_data.R") 

## Header End ----------------------------------------------------------------------


# check if shared directory, file and last_update date exists
print("Shared directory exists:")
print(file.exists("/src/shared-data/"))

print("Saved file exists:")
print(file.exists("/src/shared-data/airquality_india.RDS"))

print("Last data update:")
print(try(readRDS("/src/shared-data/last_update.RDS"), silent = TRUE))


## Get Data from Big Query conditional on check of table last update timestamp ------------------------------------------


get_data<- function(){
            
           # connect to Big Query Dataset global_air_quality; bigrquery readme: https://github.com/r-dbi/bigrquery

            bq_auth(path = "/src/service-account-big-query.json") # put your own json account token in src folder for auth, see https://gargle.r-lib.org/articles/get-api-credentials.html section "Service account token" for generation

            
            con <- dbConnect(
                        bigrquery::bigquery(),
                        project = "bigquery-public-data",
                        dataset = "openaq",
                        billing = "divine-outlet-259218"
            )
            
            #dbListTables(con) # see list of cointained tables - we just have this one in openaq dataset
            
            airqual <- tbl(con, "global_air_quality")
            print("Connection to Big Query global air quality data set established")
            
            # make query function to get the last update date of the table
            query <- "SELECT *, TIMESTAMP_MILLIS(last_modified_time) AS last_update
                      FROM `bigquery-public-data.openaq.__TABLES__`
                        WHERE table_id = 'global_air_quality'"
            
            
            last_update <- dbGetQuery(con, query)$last_update
            
            # Explanation: To update data only if the dataset has changed we read in metadata of the dataset to get last update time.
            # This is done via SQL querying as it is more convenient instead dplyr. We could also check the timestamp of the last entrie in
            # the data set itself, however querying only the meta data table is faster and does not get billed. The timestamp is calculated
            # in DB in ms as the raw timestamp from BQ leads to an integer overflow in R.
            
            # check for new entries, if not equal, get new data
            if(last_update != try(readRDS("/src/shared-data/last_update.RDS"), silent = TRUE)){
                        
                        # dblyr filter measurements from India
                        airquality_india<- airqual %>% 
                                    filter(country == "IN") %>% 
                                    as_tibble 
                        
                        # dplyr & lubridate date features 
                        airquality_india<- airquality_india %>%           
                                    mutate(Day= floor_date(timestamp, "day")) %>% 
                                    mutate(Week= floor_date(Day, "week", week_start = 1)) %>% 
                                    mutate(Month= floor_date(Day, "month")) %>% 
                                    mutate(Quarter= floor_date(Day, "quarter")) %>% 
                                    mutate(Year= floor_date(Day, "year")) %>% 
                                    distinct(Day, location, .keep_all = TRUE) %>%  # only one measurement per location and day
                                    pad(by= "Day")    # add missing days with NA values
                        
                        # join new airquality data with the old and save
                        airquality_india_joined <-  readRDS("/src/shared-data/airquality_india.RDS") %>% 
                                    full_join(airquality_india, by= names(airquality_india))
                        
                        saveRDS(airquality_india_joined, "/src/shared-data/airquality_india.RDS")
                        
                        # save last update date for future runs
                        saveRDS(last_update, "/src/shared-data/last_update.RDS")
                        
                        print("New data saved")
                        
            }
            # disconnect from Big Query
            dbDisconnect(con)
}

# run function
get_data()
