# Dockerized Plumber API

These REST APIs provide a way for platform/language independent access to the public Google Big Query dataset  `bigquery-public-data:openaq.global_air_quality` of air pollution measured soley at Indian measurement points. The dataset is updated daily, however older data seem to get deleted. To access this data a Cron job fetches new data in 12 hour intervals from Google through the R script `get_data_big_query.R` and adds new rows to the saved dataset. The data can be requested fully or aggregated on date intervals through the APIs provided in the Rscript `API.R`. The data import via Cron and the APIs are run seperately in two Docker containers with a shared volume for the data as specified in the `docker-compose.yml`. The APIs for Cloud Storage and Big Query have to be activated first for the used Google account at https://console.cloud.google.com/ and the API of the R package `bigrquery` need to be given access to the Google account once manually, see https://github.com/r-dbi/bigrquery. 


## API Documentation:  

- Get complete data from all Indian measurement points   

      POST */all

      NO parameters
      content-type: application/json 

- Get all Indian measurement locations 

       POST */locations

      NO parameters
      content-type: application/json  

- Get median airquality metrics of the current date with date horizon for averaging at measurement location.

      POST */summed_quality_now?measurment_location=&date=

      measurment_location: Takes all values from the Indian measurement locations, defaults to all
      date: The daterange, takes either today, week, month, quarter, year, defaults to today
      content-type: application/json   
      

- Get median air quality for all dates. The timerange for averaging and the measurement location can be set. 

      POST */summed_quality?measurment_location=&date=

      measurment_location: Takes all values from the Indian measurement locations, defaults to all
      date: The daterange, takes either day, week, month, quarter, year, defaults to day
      content-type: application/json  



- Plot a test histogram

      GET */plot

      NO parameters
      content-type: application/json  
