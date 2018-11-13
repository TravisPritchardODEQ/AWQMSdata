# AWQMSdata

AWQMSdata was created to load Oregon DEQ AWQMS data into R. This is intended for internal Oregon DEQ users. Public users should use the AWQMS frontend locacted  [here.](https://www.oregon.gov/deq/wq/Pages/WQdata.aspx) 

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

There is also a Shiny App that can be used to help put together the data retrieval function. You can clone or download that app [here](https://github.com/TravisPritchardODEQ/AWQMSdata_ShinyHelp)


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
| `AWQMS_Chars` | project <br/> station | Return a vector of available characteristics |
| `AWQMS_Orgs` |  project <br/> station | Return a vector of available organizations |
| `AWQMS_Projects` | - | Return a vactor of available projects |
| `AWQMS_Stations` | project <br/> char <br/> HUC8 |  Return a vector of available stations |




