## Header --------------------------- 
##
## Script name: Plumber Lead und Umsatz: Main for API init and Cron job
##
## Purpose of script: 
##
## Author: Tim M. Schendzielorz 
##
## Date Created: 2019-11-09
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

library("tidyverse")
library("lubridate")
library("padr")

library("plumber")

## Header End ----------------------------------------------------------------------


# define local pin board for data exchange across scripts
library("pins")
board_register_local(cache = "./shared-data/pins")


## cron job, for linux: cronR ------------------------------------------------------------------------------------------
#library("cronR")  # defined in separate docker container!

# set linux cron job every minute
#cmd <- cron_rscript("get_data.R")
#cron_add(command = cmd, frequency = 'minutely', id = 'check_for_new_leads', description = 'Checks for new leads at lucenta database and computes company KPIs')

# Run every minute on windows taskscheduler- for testing as docker container linux

#taskscheduler_create(taskname = "check_for_new_leads", rscript = "./get_data.R",
#   schedule = "MINUTE", modifier = 1)

#taskscheduler_delete(taskname = "check_for_new_leads")


## init plumbr API ---------------

r_plumb <- plumb("API.R")
r_plumb$run(port=3838, host="0.0.0.0")