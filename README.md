# AWQMSdata
ORDEQ internal AWQMS Query Tools

You need an ODBC connection named AWQMS for this to work 

This package contails the following functions:


  * __AWQMS_Chars(project, station)__ - Returns characteristics available for downloading from AWQMS
  * __AWQMS_Projects()__ - Returns projects available for downloading from AWQMS
  * __AWQMS_Orgs(project, station)__ - Returns organizations with data available for downloding from AWQMS
  * __AWQMS_Data(startdate, enddate, station,
                       project, char, stat_base,
                       media, org, HUC8, filterQC = TRUE)__  - Returns data from AWQMS

Note - This is a work in progress
