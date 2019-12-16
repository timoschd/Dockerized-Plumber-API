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



get_data<- function(){
            
            # check for already existing data for first sourcing
            if(class(try(readRDS("/src/shared-data/airquality_india.RDS"), silent = TRUE))== "try-error"){
                        
                        saveRDS(0, "/src/shared-data/rownumber.RDS")
            } else{}
            
            # connect to Big Query Dataset global_air_quality; bigrquery readme: https://github.com/r-dbi/bigrquery
            bq_auth("tschendzie@googlemail.com") # auth with email for which Big Query API is enabled at https://console.cloud.google.com/
            
            con <- dbConnect(
                        bigrquery::bigquery(),
                        project = "bigquery-public-data",
                        dataset = "openaq",
                        billing = "divine-outlet-259218"
            )
            
            #dbListTables(con) # see list of cointained tables
            
            airqual <- tbl(con, "global_air_quality")
            print("Connection to Big Query global air quality dataset established")
            
            n_entries<- function(){
                        airqual %>% 
                                    filter(country == "IN") %>% 
                                    select(location) %>% 
                                    collect %>% 
                                    dim()
            } 
            
            # check for new entries, if not equal, get new data
            if(n_entries()[1] != readRDS("/src/shared-data/rownumber.RDS")){
                        
                        # dblyr filter measurements from India
                        airquality_india<- airqual %>% 
                                    filter(country == "IN") %>% 
                                    as_tibble 
                        
                        # save new number of entries
                        saveRDS(dim(airquality_india)[1], "/src/shared-data/rownumber.RDS")
                        
                        # dplyr date features 
                        airquality_india<- airquality_india %>%           
                                    mutate(Day= floor_date(timestamp, "day")) %>% 
                                    mutate(Week= floor_date(Day, "week", week_start = 1)) %>% 
                                    mutate(Month= floor_date(Day, "month")) %>% 
                                    mutate(Quarter= floor_date(Day, "quarter")) %>% 
                                    mutate(Year= floor_date(Day, "year")) %>% 
                                    distinct(Day, location, .keep_all = TRUE) %>%  # only one measurement per location and day
                                    pad(by= "Day")    # fill missing days with NA
                        
                        # save new data
                        saveRDS(airquality_india, "/src/shared-data/airquality_india.RDS")
                        print("New data saved")
                        
            }
            # disconnect from Big Query
            dbDisconnect(con)
}

# run function
get_data()