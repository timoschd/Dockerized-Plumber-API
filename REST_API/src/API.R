## Header --------------------------- 
##
## Script name: Plumber API 
##
## Purpose of script: Offer Air Quality Data from Google Big Query (bigquery-public-data:openaq.global_air_quality) at REST API 
##
## Author: Tim M. Schendzielorz 
##
## Date Created: 2019-12-15
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


## Global Options ---------------------------

options(scipen = 7, digits = 2,  encoding = "UTF-8") # I prefer to view outputs in non-scientific notation
#memory.limit(30000000)               # this is needed on some PCs to increase memory allowance, but has no impact on macs.

## Packages and Functions ---------------------------

## load up the packages we will need:  (uncomment as required)

pacman::p_load("tidyverse", "lubridate", "plumber")

## Header End ----------------------------------------------------------------------


# check if shared directory exists
print("Shared directory exists:")
print(dir.exists("shared-data/"))



## REST API -----------------------------------------------------------------------------------------------------------

# define APIs

#* @apiTitle Air Quality India from Google Big Query public data set bigquery-public-data:openaq.global_air_quality


#* Get complete data from all Indian measurement points 
#* @post /all
function(){
            readRDS("shared-data/airquality_india.RDS")
        
}

#* Get all Indian measurement locations
#* @post /locations
function(){
            distinct(readRDS("shared-data/airquality_india.RDS"), city, location)

}

#* Get median airquality metrics of the current date with date horizon for averaging. Specific measurement location or default all locations
#* @param date The daterange (today, week, month, quarter, year). Defaults to today.
#* @param measurement_location see locations for possible values
#* @post /summed_quality_now
function(date = "today", measurement_location = "all"){
           if(date == "year"){
                        readRDS("shared-data/airquality_india.RDS") [readRDS("shared-data/airquality_india.RDS")$Year == floor_date(Sys.Date(), "year"),] %>% 
                                   {
                                     if (measurement_location %in% distinct(readRDS("shared-data/airquality_india.RDS"), location)[[1]])
                                     filter(., location == measurement_location)
                                    else
                                     .
                                    }  %>% 
                                   group_by(location, pollutant, unit) %>% 
                                   summarise(Average_Daily_Value= median(value, na.rm=TRUE))
                                   
           
           } else if ( date == "quarter"){
                       readRDS("shared-data/airquality_india.RDS") [readRDS("shared-data/airquality_india.RDS")$Quarter == floor_date(Sys.Date(), "quarter"),] %>% 
                                   {
                                               if (measurement_location %in% distinct(readRDS("shared-data/airquality_india.RDS"), location)[[1]])
                                                           filter(., location == measurement_location)
                                               else
                                                           .
                                   }  %>% 
                                   group_by(location, pollutant, unit) %>% 
                                   summarise(Average_Daily_Value= median(value, na.rm=TRUE))
                       
                       
           } else if ( date == "month"){
                       readRDS("shared-data/airquality_india.RDS") [readRDS("shared-data/airquality_india.RDS")$Month == floor_date(Sys.Date(), "month"),] %>% 
                                   {
                                               if (measurement_location %in% distinct(readRDS("shared-data/airquality_india.RDS"), location)[[1]])
                                                           filter(., location == measurement_location)
                                               else
                                                           .
                                   }  %>% 
                                   group_by(location, pollutant, unit) %>% 
                                   summarise(Average_Daily_Value= median(value, na.rm=TRUE))


           } else if ( date == "week"){
                       readRDS("shared-data/airquality_india.RDS") [readRDS("shared-data/airquality_india.RDS")$Week == floor_date(Sys.Date(), "week", week_start = 1),] %>% 
                                   {
                                               if (measurement_location %in% distinct(readRDS("shared-data/airquality_india.RDS"), location)[[1]])
                                                           filter(., location == measurement_location)
                                               else
                                                           .
                                   }  %>% 
                                   group_by(location, pollutant, unit) %>% 
                                   summarise(Average_Daily_Value= median(value, na.rm=TRUE))
                       

           } else if ( date == "today"){
                       readRDS("shared-data/airquality_india.RDS") [readRDS("shared-data/airquality_india.RDS")$Day == floor_date(Sys.Date(), "day"),] %>% 
                                   {
                                               if (measurement_location %in% distinct(readRDS("shared-data/airquality_india.RDS"), location)[[1]])
                                                           filter(., location == measurement_location)
                                               else
                                                           .
                                   }  %>% 
                                   group_by(location, city, pollutant, unit) %>% 
                                   summarise(Average_Daily_Value= median(value, na.rm=TRUE))
                 
           }
}



#* Get averaged air quality for all dates. The timerange for averaging and the measurement location can be set. No set location defaults to all.
#* @param date The daterange over which is averaged (day, week, month, quarter, year). Defaults to day.
#* @param measurement_location see locations for possible values
#* @post /summed_quality
function(date = "day", measurement_location = "all"){
            if(date == "year"){
                        readRDS("shared-data/airquality_india.RDS") %>% 
                                    {
                                                if (measurement_location %in% distinct(readRDS("shared-data/airquality_india.RDS"), location)[[1]])
                                                            filter(., location == measurement_location)
                                                else
                                                            .
                                    }  %>% 
                                    group_by(location, city, pollutant, unit, Year) %>% 
                                    summarise(Average_Daily_Value= median(value, na.rm=TRUE))
                        
           
            } else if ( date == "quarter"){
                        readRDS("shared-data/airquality_india.RDS") %>% 
                                    {
                                                if (measurement_location %in% distinct(readRDS("shared-data/airquality_india.RDS"), location)[[1]])
                                                            filter(., location == measurement_location)
                                                else
                                                            .
                                    }  %>% 
                                    group_by(location, city, pollutant, unit, Quarter) %>% 
                                    summarise(Average_Daily_Value= median(value, na.rm=TRUE))
                        
                        
            } else if ( date == "month"){
                        readRDS("shared-data/airquality_india.RDS") %>% 
                                    {
                                                if (measurement_location %in% distinct(readRDS("shared-data/airquality_india.RDS"), location)[[1]])
                                                            filter(., location == measurement_location)
                                                else
                                                            .
                                    }  %>% 
                                    group_by(location, city, pollutant, unit, Month) %>% 
                                    summarise(Average_Daily_Value= median(value, na.rm=TRUE))
                        
                        
            } else if ( date == "week"){
                        readRDS("shared-data/airquality_india.RDS") %>% 
                                    {
                                                if (measurement_location %in% distinct(readRDS("shared-data/airquality_india.RDS"), location)[[1]])
                                                            filter(., location == measurement_location)
                                                else
                                                            .
                                    }  %>% 
                                    group_by(location, city, pollutant, unit, Week) %>% 
                                    summarise(Average_Daily_Value= median(value, na.rm=TRUE))
                        
                        
            } else if ( date == "day"){
                        readRDS("shared-data/airquality_india.RDS") %>% 
                                    {
                                                if (measurement_location %in% distinct(readRDS("shared-data/airquality_india.RDS"), location)[[1]])
                                                            filter(., location == measurement_location)
                                                else
                                                            .
                                    }  %>% 
                                    group_by(location, city, pollutant, unit, days()) %>% 
                                    summarise(Average_Daily_Value= median(value, na.rm=TRUE))
            }
}





#* Plot a histogram (test)
#* @png
#* @get /plot
function(){
  rand <- rnorm(100)
  hist(rand)
}



