# AWQMSdata  


AWQMSdata was created to load Oregon DEQ AWQMS data into R. This is intended for internal Oregon DEQ users. Public users should use the AWQMS frontend locacted  [here.](https://www.oregon.gov/deq/wq/Pages/WQdata.aspx)   

There is a Shiny App that can be used to help put together the data retrieval function. You can clone or download that app [here](https://github.com/TravisPritchardODEQ/AWQMSdata_ShinyHelp)  


Note that this package is currently a work in progress.

## Installation

You need an ODBC connection to the AWQMS database named AWQMS, and read access to VW_AWQMS_Results. 

You also need to have the [devtools](https://github.com/hadley/devtools) package installed. 
```
install.packages("devtools")
```

To install AWQMSdata:
```
library(devtools)
install_github("TravisPritchardODEQ/AWQMSdata")
```



## Description

This package contails the following functions:


  * __AWQMS_Chars(project, station)__ - Returns characteristics available for downloading from AWQMS
  * __AWQMS_Projects()__ - Returns projects available for downloading from AWQMS
  * __AWQMS_Orgs(project, station)__ - Returns organizations with data available for downloding from AWQMS
  * __AWQMS_Data(startdate, enddate, station,
                       project, char, stat_base,
                       media, org, HUC8, filterQC = TRUE)__  - Returns data from AWQMS  
                       
<br/>
<br/>

###### Available functions:                       


| Function Name | Arguments | Description |
| ------------- | --------- | ----------- |
| `AWQMS_Data`  | startdate <br/> enddate <br/> station <br/> project <br/> char <br/> stat_base <br/> media <br/> org <br/> HUC8 <br/> filterQC | Retrieve a dataframe of data exported from AWQMS       |
| `AWQMS_Chars` | project <br/> station | Return a dataframe of available characteristics |
| `AWQMS_Orgs` |  project <br/> station | Return a dataframe of available organizations |
| `AWQMS_Projects` | - | Return a dataframe of available projects |
| `AWQMS_Stations` | project <br/> char <br/> HUC8 |  Return a dataframe of available stations |

<br/>

## Usage

#### AWQMS_Projects
Use `AWQMS_Projects()` to return all available projects from AWQMS. This function will include projects found in the Project1, Project2, and Project3 fields. 

```
projects <- AWQMS_Projects()
```

A vector of projects can be then created.

```
projects_vector <- projects$Project
```

<br/>  


#### AWQMS_Stations
Use `AWQMS_Stations()` to return available stations from AWQMS. This function's arguments can include any or all of vectors of project, characteristics, HUC8, or HUC8 name.  

To see all available stations:
```
stations <- AWQMS_Stations()
```

To see stations that are associated with Oregon DEQ:
```
stations <- AWQMS_Stations(org = 'OREGONDEQ')
```

To see stations with water temperature and dissolved oxygen data:

```
stations <- AWQMS_Stations(char = c('Temperature, water', 'Dissolved oxygen (DO)'))
```

To see stations with water temperature and dissolved oxygen data in the Middle Fork John Day:

```
stations <- AWQMS_Stations(char = c('Temperature, water', 'Dissolved oxygen (DO)'), HUC8 = '17070203')
```

For all the functions in this package, the arguments can be a single parameter or a vector of parameters. For example, to see stations with water temperature and dissolved oxygen data in the Middle Fork John Day, and the Lower John Day :

```
stations <- AWQMS_Stations(char = c('Temperature, water', 'Dissolved oxygen (DO)'), HUC8 = c('17070203', '17070204')
```

<br/>

#### AWQMS_Orgs
Use `AWQMS_Orgs()` to return available organizations from AWQMS.  This function's arguments can include vectors of project or stations.  

To return all available organizations in AWQMS:

```
organizations <- AWQMS_Orgs()
```

To return all available organizations that have water temperature and dissolved oxygen data for the Middle and Lower John Day:

```
> stations <- AWQMS_Stations(char = c('Temperature, water', 'Dissolved oxygen (DO)'), HUC8 = c('17070203', '17070204')   
> stations_vector <- stations$MLocID  
> organizations <- AWQMS_Orgs(station = stations_vector)  
```




