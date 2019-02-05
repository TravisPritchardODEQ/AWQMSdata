#' AWQMS_Station
#'
#' This function will return a list of monitoring locations with data found in OregonDEQ AWQMS
#' @param project Optional vector of projects to be filtered on
#' @param char Optional vector of characters to be filtered on
#' @param HUC8 Optional vector of HUC8s to be filtered on
#' @param HUC8_Name Optional vector of HUC8 names to be filtered on
#' @param org Optional vector of organizations to be filtered on
#' @param crit_codes If true, include standard codes used in determining criteria
#' @return Dataframe of monitoring locations
#' @examples AWQMS_Station(project = 'Total Maximum Daily Load Sampling', char = "Temperature, water", HUC8 = "17090003", crit_codes = false)
#' @export


AWQMS_Stations <- function(project = NULL, char = NULL, HUC8 = NULL, HUC8_Name = NULL, org = NULL, crit_codes = FALSE) {


# Connect to database -----------------------------------------------------


  con <- DBI::dbConnect(odbc::odbc(), "AWQMS")

  if(crit_codes == TRUE){

    query = "SELECT distinct  a.[MLocID],
    a.[StationDes],
    a.[MonLocType],
    a.[EcoRegion3],
    a.[EcoRegion4],
    a.[HUC8],
    a.[HUC8_Name],
    a.[HUC10],
    a.[HUC12],
    a.[HUC12_Name],
    a.[Lat_DD],
    a.[Long_DD],
    a.[Reachcode],
    a.[Measure],
    a.[AU_ID],
    s.FishCode,
    s.SpawnCode,
    s.WaterTypeCode,
    s.WaterBodyCode,
    s.BacteriaCode,
    s.DO_code,
    s.ben_use_code,
    s.pH_code,
    s.DO_SpawnCode
    FROM  [deqlead-lims\\awqms].[awqms].[dbo].[VW_AWQMS_Results] a
    LEFT JOIN [deqlead-lims].[Stations].[dbo].[VWStationsFinal] s ON a.MLocID = s.MLocID"
  } else {
    query = "SELECT distinct  a.[MLocID],
    a.[StationDes],
    a.[MonLocType],
    a.[EcoRegion3],
    a.[EcoRegion4],
    a.[HUC8],
    a.[HUC8_Name],
    a.[HUC10],
    a.[HUC12],
    a.[HUC12_Name],
    a.[Lat_DD],
    a.[Long_DD],
    a.[Reachcode],
    a.[Measure],
    a.[AU_ID]
    FROM  [deqlead-lims\\awqms].[awqms].[dbo].[VW_AWQMS_Results] a"

  }


  if (length(project) > 0) {
    query <- paste0(query, "\n WHERE (a.Project1 in ({project*}) OR a.Project2 in ({project*}))")

  }




  # Station Filter ----------------------------------------------------------


  if (length(char) > 0) {

    if (length(project) > 0) {
      query = paste0(query, "\n AND a.Char_Name IN ({char*})")
    } else {
      query <- paste0(query, "\n WHERE a.Char_Name IN ({char*})")
    }

    }


# HUC8 Filter -------------------------------------------------------------


   if(length(HUC8) > 0){

     if(length(project) > 0 | length(char > 0) ){
       query = paste0(query, "\n AND a.HUC8 IN ({HUC8*})")

     }  else {
       query <- paste0(query, "\n WHERE a.HUC8 IN ({HUC8*})")
       }

   }


  #HUC8_Name

  if(length(HUC8_Name) > 0){

    if(length(project) > 0 |
       length(char > 0) |
       length(HUC8) > 0){

    query = paste0(query,"\n AND a.HUC8_Name in ({HUC8_Name*}) " )

    } else {
      query <- paste0(query, "\n WHERE a.HUC8_Name IN ({HUC8_Name*})")
    }
  }

  #HUC8_Name

  if(length(org) > 0){

    if(length(project) > 0 |
       length(char > 0) |
       length(HUC8) > 0 |
       length(HUC8_Name) > 0){

      query = paste0(query,"\n AND a.OrganizationID in ({org*}) " )

    } else {
      query <- paste0(query, "\n WHERE a.OrganizationID in ({org*}) " )
    }
  }


# Put query language together ---------------------------------------------


  qry <- glue::glue_sql(query, .con = con)



# Send query ot database --------------------------------------------------


  data_fetch <- DBI::dbGetQuery(con, qry)


# Disconnect fron database ------------------------------------------------


  DBI::dbDisconnect(con)


# Return dataframe --------------------------------------------------------


  return(data_fetch)

}
