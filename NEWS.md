

# AWQMSdata 1.3 (2020-10-07)
### Breaking Updates
* Changed column names in criteria tables to align with what comes out of AWQMS.
  See readme for new column names. 

### Non-breaking Upates
* Added `Mlocs_crit()` to query stations database to provide criteria codes.
  Function joins criteria tables to provide site speific criteria
  
* Added ability to query by submedia in `AWQMSdata()`: <br/>
  - NULL
  - Bottom material
  - Const. Material
  - Drinking Water
  - Finished Water
  - Groundwater
  - Industrial Effluent
  - Industrial Waste
  - Leachate
  - Mixing Zone
  - Mixing Zone, Zone of Initial Dilution
  - Municipal Sewage Effluent
  - Municipal Waste
  - Ocean Water
  - Oil/Oily Sludge
  - Reagent water
  - Septic Effluent
  - Stormwater
  - Surface Water
  - Untreated water supply
  - Wastewater Treatment Plant Effluent
  - Wastewater Treatment Plant Influent
  - Water-Vadose Zone
  
  
# AWQMSdata 1.2 (2020-04-15)

* Changed format of SampleStartTime in AWQMSdata to remove decimal seconds. Time is now dsilayed as hh:mm:ss

# AWQMSdata 1.1 (2019-12-13)

* Merged Aliana Britson's updates to copper BLM script which adds Result type for all characteristics


# AWQMSdata 1.0 (2019-12-03)

* Added `AWQMS_Data_Cont()` to query raw continuous data
* Modified `AWQMS_Data()` to include option to query by Assessment Unit


# AWQMSdata 0.9.8

* Added `query_stations()` to query stations dta straight from the STATIONS 
  database, as opposed to from AWQMS
