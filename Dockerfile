# Mobivi R Docker file
# Business Intelligence Department - Thinh Huynh
# May 2016
## Based on r-base
FROM r-base:latest 
MAINTAINER Thinh Huynh "thinh.hc@mobivi.vn"

## Add RStudio binaries to PATH 
ENV PATH /usr/lib/rstudio-server/bin/:$PATH 

# get R from a CRAN archive 
RUN echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial/" >> /etc/apt/sources.list
RUN DEBIAN_FRONTEND=noninteractive apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

RUN apt-get update && \
apt-get upgrade -y

#Install Open JDK for rJava package
RUN apt-get install -y -q openjdk-8-jdk
RUN R CMD javareconf

RUN apt-get update && \
apt-get upgrade -y

#Install XML Libs
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
libxml2 \
libxml2-dev

RUN apt-get update && \
apt-get upgrade -y

## Download and install RStudio server & dependencies 
RUN rm -rf /var/lib/apt/lists/ \
&& apt-get update \
&& apt-get install -y -t unstable --no-install-recommends \
ca-certificates \ 
file \ 
git \ 
libapparmor1 \ 
libedit2 \ 
libcurl4-openssl-dev \ 
libmariadb-client-lgpl-dev \
libssl1.0.0 \ 
libssl-dev \ 
psmisc \ 
python-setuptools \ 
sudo \
&& VER=$(wget --no-check-certificate -qO- https://s3.amazonaws.com/rstudio-server/current.ver) \
&& wget -q http://download2.rstudio.org/rstudio-server-${VER}-amd64.deb \
&& dpkg -i rstudio-server-${VER}-amd64.deb \
&& rm rstudio-server-*-amd64.deb \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/

## Install external libraries
RUN install2.r --error \
-r "https://cran.rstudio.com" \
-r "http://www.bioconductor.org/packages/release/bioc" \
assertthat \
R6 \
Rcpp \
magrittr \
lazyeval \
DBI \
BH \
dplyr \
gtools \
rJava \
scales \
gsheet \
Hmisc \
lubridate \
readxl \
data.table \
xlsx \
googlesheets \
XLConnect \
RMySQL \
reshape2 \
sqldf \
mondate \
stringr

# Config rserver.conf 05/12/2016
RUN rserverconf="/etc/rstudio/rserver.conf"
RUN if [ -f "$rserverconf" ]; then mv "$rserverconf" "${rserverconf}.bak"; fi
RUN echo "www-address=127.0.0.1" >> "$rserverconf"

# Config rsession.conf
RUN rsessionconf="/etc/rstudio/rsession.conf"
RUN if [ -f "$rsessionconf" ]; then mv "$rsessionconf" "${rsessionconf}.bak"; fi
RUN echo "r-libs-user=~/R/%p-library/%v" >> "$rsessionconf"

#Add rstudio/rstudio username/password
RUN usermod -l rstudio docker \ 
&& usermod -m -d /home/rstudio rstudio \ 
&& groupmod -n rstudio docker \ 
&& echo '"\e[5~": history-search-backward' >> /etc/inputrc \ 
&& echo '"\e[6~": history-search-backward' >> /etc/inputrc \ 
&& echo "rstudio:rstudio" | chpasswd

## Use s6 
RUN wget -P /tmp/ https://github.com/just-containers/s6-overlay/releases/download/v1.11.0.1/s6-overlay-amd64.tar.gz \
&& tar xzf /tmp/s6-overlay-amd64.tar.gz -C / 

COPY userconf.sh /etc/cont-init.d/conf 
COPY run.sh /etc/services.d/rstudio/run 
COPY add-users.sh /usr/local/bin/add-users 

EXPOSE 8787 

## Expose a default volume for Kitematic 
VOLUME /home/rstudio 
CMD ["/init"]
