FROM rocker/tidyverse:latest

MAINTAINER Tobias Verbeke "tobias.verbeke@openanalytics.eu"
 

# install R packages
RUN R -e "install.packages(c('pacman', 'lubridate', 'plumber'), dependencies = TRUE)"
	
# make dir	
RUN mkdir -p /src/shared-data

COPY /src    /src  
WORKDIR /src

# make all app files readable, gives rwe permisssion (solves issue when dev in Windows, but building in Ubuntu)
RUN chmod -R 755 /src

# expose port
EXPOSE 3838

CMD ["R", "-e", "pr <- plumber::plumb('/src/API.R'); pr$run(host='0.0.0.0', port=3838)"]

