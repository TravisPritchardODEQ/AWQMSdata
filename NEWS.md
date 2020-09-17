# AWQMSdata 1.1

# AWQMSdata 1.1 (2020-09-16)
### Breaking Updates
* Changed column names in criteria tables to align with what comes out of AWQMS.
  See readme for new column names. 

### Non-breaking Upates
* Added Mlocs_crit() to query stations database to provide criteria codes.
  Function joins criteria tables to provide site speific criteria
  

# AWQMSdata 1.0 (2019-12-03)

* Added AWQMS_Data_Cont() to query raw continuous data
* Modified AWQMS_Data() to include option to query by Assessment Unit


# AWQMSdata 0.9.8

* Added query_stations() to query stations dta straight from the STATIONS 
  database, as opposed to from AWQMS
