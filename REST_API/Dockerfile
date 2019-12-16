FROM rocker/tidyverse:latest

MAINTAINER Tim M.Schendzielorz "tim.schendzielorz@googlemail.com"
 
# Install dependencies and Download and install shiny server
RUN apt-get update && apt-get install -y \
    gosu \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libssl-dev \
	libv8-dev \
	libxml2-dev \
    libxt-dev && \
    rm -f version.txt ss-latest.deb && \
    R -e "install.packages(c('plumber','pins','padr','lubridate'), dependencies = TRUE)" && \
    R -e 'if(!require(devtools)) { install.packages("devtools") }; library(devtools);' && \
    R -e "library(devtools); install_cran('plotly')" && \
	rm -rf /var/lib/apt/lists/*


	
RUN mkdir -p /src/shared-data

COPY /src    /src  
WORKDIR /src

# make all app files readable, gives rwe permisssion (solves issue when dev in Windows, but building in Ubuntu)
RUN chmod -R 755 /src


EXPOSE 3838

#ENTRYPOINT ["R", "-e", "r_plumb <- plumber::plumb("API.R"); pr$run(host='0.0.0.0', port=3838)"] 
ENTRYPOINT ["Rscript", "/src/main.R"]

