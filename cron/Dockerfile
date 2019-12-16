FROM rocker/tidyverse:latest

MAINTAINER Tim M.Schendzielorz "tim.schendzielorz@googlemail.com"
 
# Install dependencies and Download and install shiny server
RUN apt-get update && apt-get install -y \
    gosu \
    gdebi-core \
    git-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libssl-dev \
	libudunits2-dev \
	libv8-dev \
	libmariadb-dev \
	#libmariadb-dev-compat \
    libmariadbclient-dev-compat \
    #libmysqlclient-dev \
	default-libmysqlclient-dev \
	unixodbc-dev \
	libsqlite3-dev \
	libgdal-dev \
	libxml2-dev \
    cron \
    libxt-dev && \
    #gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
    R -e "install.packages(c('plumber','pins','padr','dplyr','dbplyr','lubridate','DBI', 'RMySQL', 'pool'), dependencies = TRUE)" && \
    R -e 'if(!require(devtools)) { install.packages("devtools") }; library(devtools);' && \
    R -e "library(devtools); install_cran('plotly')" && \
	R -e "library(devtools); install_cran('RMySQL')" && \
    R -e 'devtools::install_github("bnosac/cronR")' && \
    rm -rf /var/lib/apt/lists/*


	


RUN mkdir -p /src/shared-data

COPY /src    /src  
WORKDIR /src


# make all app files readable, gives rwe permisssion (solves issue when dev in Windows, but building in Ubuntu)
RUN chmod -R 755 /src

# Apply cron job
RUN crontab /src/cronjob

# Create the log file to be able to run tail - put in CMD as otherwise not working 
RUN touch /var/log/cron.log

# Run the command on container startup with extra touch as https://stackoverflow.com/questions/43802109/output-of-tail-f-at-the-end-of-a-docker-cmd-is-not-showing/43807880#43807880
CMD echo "cronjob wird gestartet" && (cron) && echo "now touch n' tail" && touch /var/log/cron.log && tail -f /var/log/cron.log



