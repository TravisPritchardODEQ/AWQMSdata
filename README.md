# AWQMSdata
ORDEQ internal AWQMS Query Tools

You need an ODBC connection named AWQMS for this to work 

This package contails the following functions:


  * AWQMS_Chars(project, station) - Returns characteristics available for downloading from AWQMS
  * AWQMS_Projects() - Returns projects available for downloading from AWQMS
  * AWQMS_Orgs(project, station) - Returns organizations with data available for downloding from AWQMS
  * AWQMS_Data(startdate, enddate, station,
                       project, char, stat_base,
                       media, org, HUC8, filterQC = TRUE)  - Resturns data from AWQMS

Note - This is a work in progress
