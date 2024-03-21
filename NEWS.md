# AWQMSdata 3.0.3

-   Adding station description to continuous data pull

# AWQMSdata 3.0.2 (2024-03-21)

-   Big fix. data functions will not error when returning empty dataframes from AWQMS

# AWQMSdata 3.0.1(2024-03-20)

-   Bugfix. Correcting continuous data startdate filter to use Result_Date.

# AWQMSdata 3.0 (2024-03-15)

##### Breaking Updates

-   Changed column names in function arguments tables to align with what comes out of AWQMS. See readme for new column names.

-   Big update to incorporate AWQMS move to cloud services

-   Changes some argument names to better match what is in AWQMS.

-   Created username and password storage solution.

##### Non Breaking Updates

-   Change to dbplyr syntax

# AWQMSdata 2.1 (2022-08-12)

-   Bioassessment data update. Added functions to query data from the following views in AWQMS: Raw_Macros, Bio_Metrics, Bio_Indexes

# AWQMSdata 2.0

-   Major update. Added AWQMS_set_servers function to implement needed fix where we need to specify server addresses in query sent to database. Since we don't want to publish the server addresses, we need to save them in our .Renviron to be usable. All the AWQMSdata functions were rewritten to incorporate this change.

-   Added CAS number as a query parameter in AWQMS_Data().

# AWQMSdata 1.7 (2022-05-26)

-   Added error checks to AWQMSdata if numeric HUCs are not in character format.

# AWQMSdata 1.6 (2022-05-12)

-   Added return_query = FALSE as argument in AWQMS_Data. If true, will return actual query sent to AWQMS. Hopefully helpful for troubleshooting.

# AWQMSdata 1.5 (2022-05-04)

### Breaking Updates

-   Bug fix following AWQMS server update. User will need to update package.

# AWQMSdata 1.3 (2020-10-07)

### Breaking Updates

-   Changed column names in criteria tables to align with what comes out of AWQMS. See readme for new column names.

### Non-breaking Upates

-   Added `Mlocs_crit()` to query stations database to provide criteria codes. Function joins criteria tables to provide site speific criteria

-   Added ability to query by submedia in `AWQMSdata()`: <br/>

    -   NULL
    -   Bottom material
    -   Const. Material
    -   Drinking Water
    -   Finished Water
    -   Groundwater
    -   Industrial Effluent
    -   Industrial Waste
    -   Leachate
    -   Mixing Zone
    -   Mixing Zone, Zone of Initial Dilution
    -   Municipal Sewage Effluent
    -   Municipal Waste
    -   Ocean Water
    -   Oil/Oily Sludge
    -   Reagent water
    -   Septic Effluent
    -   Stormwater
    -   Surface Water
    -   Untreated water supply
    -   Wastewater Treatment Plant Effluent
    -   Wastewater Treatment Plant Influent
    -   Water-Vadose Zone

# AWQMSdata 1.2 (2020-04-15)

-   Changed format of SampleStartTime in AWQMSdata to remove decimal seconds. Time is now dsilayed as hh:mm:ss

# AWQMSdata 1.1 (2019-12-13)

-   Merged Aliana Britson's updates to copper BLM script which adds Result type for all characteristics

# AWQMSdata 1.0 (2019-12-03)

-   Added `AWQMS_Data_Cont()` to query raw continuous data
-   Modified `AWQMS_Data()` to include option to query by Assessment Unit

# AWQMSdata 0.9.8

-   Added `query_stations()` to query stations dta straight from the STATIONS database, as opposed to from AWQMS
