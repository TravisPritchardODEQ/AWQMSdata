#' AWQMS_Bio_Indexes
#'
#' Thus function will retrieve Bio_Indexes data from Oregon DEQ AWQMS
#' @param startdate Required parameter setting the startdate of the data being fetched. Format 'yyyy-mm-dd'. Defaults to
#' '1949-09-15'
#' @param enddate Optional parameter setting the enddate of the data being fetched. Format 'yyyy-mm-dd'
#' @param station Optional vector of stations to be fetched
#' @param AU_ID Optional vector of Assessment Units to be fetched
#' @param project Optional vector of projects to be fetched
#' @param org optional vector of Organizations to be fetched
#' @param ReferenceSite filter for reference or non reference streams. NOT CURRENTLY POPULATED
#' @param Index_Name Optional vector of metrics to filter
#' @param DQL Optional vector of DQLs to fetch
#' @param return_query If FALSE, fetches data from AWQMS. If TRUE, returns string of query language.
#' @export


AWQMS_Bio_Indexes <-   function(startdate = '1949-09-15',
                                enddate = NULL,
                                station = NULL,
                                AU_ID = NULL,
                                HUC12_Name = NULL,
                                project = NULL,
                                org = NULL,
                                ReferenceSite = NULL,
                                Index_Name = NULL,
                                DQL = NULL,
                                return_query = FALSE){


  # Build base query language ---------------------------------------------------------------------------------------


  ## Get environment variables ----------------------------------------------------------------------------------------



  # Get environment variables
  readRenviron("~/.Renviron")
  assert_STATIONS()
  assert_AWQMS()

  AWQMS_server <- Sys.getenv('AWQMS_SERVER')
  Stations_server <- Sys.getenv('STATIONS_SERVER')


  ## Build base query language ---------------------------------------------------------------------------------------

  query <- paste0("SELECT [org_id]
      ,[MLocID]
      ,[StationDes]
      ,[MonLocType]
      ,[EcoRegion2]
      ,[HUC12_Name]
      ,[AU_ID]
      ,[GNIS_Name]
      ,[ReferenceSite]
      ,[Project]
      ,[Act_id]
      ,[Sample_Date]
      ,[Index_Name]
      ,[Score]
      ,[DQL]
      ,[Qualifier]
      ,[Comment]
   FROM ",AWQMS_server,"[VW_Bio_Indexes]
    WHERE Sample_Date >= Convert(datetime, {startdate})")





  # Conditionally add additional parameters -----------------------------------------------------------------------------

  # add end date
  if (length(enddate) > 0) {
    query = paste0(query, "\n AND Sample_Date <= Convert(datetime, {enddate})" )
  }


  # station
  if (length(station) > 0) {

    query = paste0(query, "\n AND MLocID IN ({station*})")
  }

  # AU
  if (length(AU_ID) > 0) {

    query = paste0(query, "\n AND AU_ID IN ({AU_ID*})")
  }


  #Project

  if (length(project) > 0) {
    query = paste0(query, "\n AND (Project1 in ({project*}) OR Project2 in ({project*})) ")

  }

  # organization
  if (length(org) > 0){
    query = paste0(query,"\n AND OrganizationID in ({org*}) " )

  }

  if(length(HUC12_Name) > 0){
    query = paste0(query,"\n AND HUC12_Name in ({HUC12_Name*}) " )

  }

  #reference

  if(length(ReferenceSite) > 0){
    query = paste0(query,"\n AND ReferenceSite in ({ReferenceSite*}) " )

  }

  #metric

  if(length(Index_Name) > 0){
    query = paste0(query,"\n AND Index_Name in ({Index_Name*}) " )

  }


  #Connect to database
  con <- DBI::dbConnect(odbc::odbc(), "AWQMS")

  # Create query language
  qry <- glue::glue_sql(query, .con = con)


  if(return_query){
    data_fetch <- qry

  } else {

    # Query the database
    data_fetch <- DBI::dbGetQuery(con, qry)


    # Disconnect
    DBI::dbDisconnect(con)
  }
  return(data_fetch)

}
