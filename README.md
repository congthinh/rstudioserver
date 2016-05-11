# mobivi/rstudio-server

Rstudio-server on Docker container with statistic packages:


```
dplyr
gtools
rJava
scales
gsheet
Hmisc
lubridate
readxl
data.table
xlsx
googlesheets
XLConnect
RMySQL
reshape2
sqldf
mondate
stringr
```


### What does this repository contain? ###

* Dockerfile
* add-users.sh
* run.sh
* userconf.sh

### How to setup? ###
From the docker window: 

```
sudo docker run -d -p 8787:8787 mobivi/rstudio-server
```
In case you are using Docker Toolbox on Windows/Mac, run:


```
docker-machine ip
```


to retrieve your local or remote machine IP (for example: 192.168.99.100), then enter this with 8787 port into web browser address box.


```
192.168.99.100:8787
```

### Login ###

* username: rstudio
* password: rstudio
