#' Query ODEQ's Stations database.
#'
#' Retrieve station information from ODEQ's Stations database based on a set of query paramaters.
#' If no query parameters are supplied to the function the entire stations database will be returned.
#' This function will only work for employees of ODEQ. Requires read access permissions for internal odbc connections to
#' the AWQMS and Stations databases.
#'
#' @param stations_odbc Stations database ODBC system data source name (DSN) identifed in the ODBC data sources administrator. Default is "STATIONS".
#' @param mlocs Vector of unique monitoring location station IDs (MLocIDs).
#' @param huc8_name Vector of unique huc8 names.
#' @param huc10_name Vector of unique huc10 names.
#' @param huc12_name Vector of unique huc12 names.
#' @param huc8 Vector of unique huc8 codes.
#' @param huc10 Vector of unique huc10 codes.
#' @param huc12 Vector of unique huc12 codes.
#' @param au_id Vector of unique assessment unit IDs.
#' @param gnis_name Vector of unique NHD GNIS names.
#' @param reachcode Vector of unique NHD reachcodes.
#' @param owrd_basin Vector of unique OWRD administrative Basins.
#' @param state Vector of unique two letter state codes. Defaults to c("OR", "ID", CA", "WA", "NV", "PACIFIC OCEAN")
#' @keywords stations
#' @export
#' @return Dataframe from the stations database
#' @examples
#' library(AWQMSdata)
#'
#' # Retreive AWQMS data
#' df.awqms <- AWQMSdata::AWQMS_Data(startdate = "1995-01-01",
#'                                   enddate = "2019-12-31",
#'                                   char = "Temperature, water",
#'                                   HUC10 = "1801020604",
#'                                   crit_codes = TRUE,
#'                                   filterQC = TRUE)
#'
#'df.stations <- query_stations(mlocs=unique(df.awqms$MLocID),
#'                              stations_odbc = "STATIONS")

query_stations <- function(stations_odbc="STATIONS", mlocs=NULL,
                           huc8_name=NULL, huc10_name=NULL, huc12_name=NULL,
                           huc8=NULL, huc10=NULL, huc12=NULL,
                           au_id=NULL, gnis_name=NULL, reachcode=NULL,
                           owrd_basin=NULL, state=c("OR", "ID", "CA", "WA", "NV", "PACIFIC OCEAN")){

  readRenviron("~/.Renviron")
  AWQMS_server <- Sys.getenv('AWQMS_SERVER')
  Stations_server <- Sys.getenv('STATIONS_SERVER')

  # Build base query
  query <- paste0("Select * from ",Stations_server,"[VWStationsFinal] where STATE in ({state*})")

  if(length(mlocs) > 0){
    query = paste0(query,"\n AND MLocID in ({mlocs*}) " )

  }

  if(length(huc8) > 0){
    query = paste0(query,"\n AND HUC8 in ({huc8*}) " )

  }

  if(length(huc8_name) > 0){
    query = paste0(query,"\n AND HUC8_Name in ({huc8_name*}) " )

  }

  if(length(huc10) > 0){
    query = paste0(query,"\n AND HUC10 in ({huc10*}) " )

  }

  if(length(huc10_name) > 0){
    query = paste0(query,"\n AND HUC10_Name in ({huc10_name*}) " )

  }

  if(length(huc12) > 0){
    query = paste0(query,"\n AND HUC12 in ({huc12*}) " )

  }

  if(length(huc12_name) > 0){
    query = paste0(query,"\n AND HUC12_Name in ({huc12_name*}) " )

  }

  if(length(au_id) > 0){
    query = paste0(query,"\n AND AU_ID in ({au_id*}) " )

  }

  if(length(gnis_name) > 0){
    query = paste0(query,"\n AND GNIS_Name in (gnis_name*}) " )

  }

  if(length(reachcode) > 0){
    query = paste0(query,"\n AND Reachcode in ({reachcode*}) " )

  }

  if(length(owrd_basin) > 0){
    query = paste0(query,"\n AND OWRD_Basin in ({owrd_basin*}) " )

  }


con <- DBI::dbConnect(odbc::odbc(), stations_odbc)
query <- glue::glue_sql(query,.con = con)
stations <- DBI::dbGetQuery(con, query)
DBI::dbDisconnect(con)

return(stations)

}
