#' Query ODEQ's Stations database and return a table of siote specific criteria
#'
#' Retrieve station information from ODEQ's Stations database and joines with site specific criteria tables
#'
#' A vector of monitoring locations must be supplies.
#' This function will only work for employees of ODEQ. Requires read access permissions for internal odbc connections to
#' the AWQMS and Stations databases.
#'
#' @param mlocs Vector of unique monitoring location station IDs (MLocIDs).
#' @param stations_odbc Stations database ODBC system data source name (DSN) identifed in the ODBC data sources administrator. Default is "STATIONS".
#' @param mlocs Vector of unique monitoring location station IDs (MLocIDs).
#'#' @keywords stations, criteria
#' @export
#' @return Dataframe from the stations database joined with site specific criteria
#' @examples
#' library(AWQMSdata)
#'


Mlocs_crit <- function(mlocs = NULL,
                           stations_odbc = "STATIONS"
){

  if(is.null(mlocs)){
    stop("Must input at least one monitoring location")
  }

  query <- "SELECT Distinct [OrgID]
      ,[MLocID]
      ,[StationDes]
      ,[Lat_DD]
      ,[Long_DD]
      ,[Datum]
      ,[AU_ID]
      ,[MonLocType]
      ,[FishCode]
      ,[SpawnCode]
      ,[WaterTypeCode]
      ,[WaterBodyCode]
      ,[BacteriaCode]
      ,[DO_code]
      ,[ben_use_code]
      ,[pH_code]
      ,[DO_SpawnCode]

    FROM VWStationsFinal
    WHERE MLocID in ({mlocs*}) "



  con <- DBI::dbConnect(odbc::odbc(), stations_odbc)
  query <- glue::glue_sql(query,.con = con)
  stations <- DBI::dbGetQuery(con, query)
  DBI::dbDisconnect(con)


  joined_station_data <- dplyr::left_join(stations, dplyr::select(AWQMSdata::Temp_crit, -Comment), by = "FishCode" )
  joined_station_data <- dplyr::left_join(joined_station_data, AWQMSdata::DO_crit, by = "DO_code")

  joined_station_data <- dplyr::left_join(joined_station_data, AWQMSdata::LU_spawn, by = "SpawnCode")
  joined_station_data <- dplyr::left_join(joined_station_data, dplyr::rename(AWQMSdata::LU_spawn, DO_Spawn_dates = Spawn_dates,
                                                                      DO_SpawnStart = SpawnStart,
                                                                      DO_SpawnEnd = SpawnEnd), by = "SpawnCode")
  joined_station_data <- dplyr::left_join(joined_station_data, AWQMSdata::Chla_crit, by = "MonLocType")
  joined_station_data <- dplyr::left_join(joined_station_data, AWQMSdata::pH_crit, by = "pH_code")
  joined_station_data <- dplyr::left_join(joined_station_data, AWQMSdata::Bacteria_crit, by = "BacteriaCode")

column_order <- c("OrgID",
                  "MLocID",
                  "StationDes",
                  "Lat_DD",
                  "Long_DD",
                  "Datum",
                  "AU_ID",
                  "ben_use_code",
                  "MonLocType",
                  "WaterTypeCode",
                  "WaterBodyCode",
                  "FishCode",
                  "Temp_Criteria",
                  "SpawnCode",
                  "Spawn_dates",
                  "SpawnStart",
                  "SpawnEnd",
                  "BacteriaCode",
                  "Bacteria_SS_Crit",
                  "Bacteria_Geomean_Crit",
                  "Bacteria_Percentage_Crit",
                  "DO_code",
                  "DO_30D_crit",
                  "DO_7Mi_crit",
                  "DO_abs_min_crit",
                  "DO_Instant_crit",
                  "DO_SpawnCode",
                  "DO_Spawn_dates",
                  "DO_SpawnStart",
                  "DO_SpawnEnd",
                  "pH_code",
                  "pH_Min",
                  "pH_Max",
                  "Chla_Criteria")


joined_station_data <- joined_station_data[, column_order]

  return(joined_station_data)
}

