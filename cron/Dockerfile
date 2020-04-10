FROM rocker/tidyverse:latest

MAINTAINER Tobias Verbeke "tobias.verbeke@openanalytics.eu"
 
# Install dependencies
RUN apt-get update && apt-get install -y \
    cron 


# install R packages
RUN R -e "install.packages(c('pacman', 'lubridate', 'padr', 'dbplyr', 'DBI', 'bigrquery'), dependencies = TRUE)"
	
# make dir
RUN mkdir -p /src/shared-data

# copy folder which contains cronfile, RScript and Big Query auth JSON
COPY /src    /src  
WORKDIR /src


# make all app files readable, gives rwe permisssion (solves issue when dev in Windows, but building in Ubuntu)
RUN chmod -R 755 /src

# Apply cron job
RUN crontab /src/cronjob


# Run the command on container startup with extra touch as https://stackoverflow.com/questions/43802109/output-of-tail-f-at-the-end-of-a-docker-cmd-is-not-showing/43807880#43807880. Otherwise if seperate RUN touch recipe layer the output does not get appenended.
CMD echo "cronjob gets started" && (cron) && echo "now touch n' tail" && touch /var/log/cron.log && tail -f /var/log/cron.log



