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


AWQMS_Bio_Indexes <-   function(startdate = NULL,
                                enddate = NULL,
                                MLocID = NULL,
                                AU_ID = NULL,
                                HUC12_Name = NULL,
                                project = NULL,
                                OrganizationID = NULL,
                                ReferenceSite = NULL,
                                Index_Name = NULL,
                                DQL = NULL,
                                return_query = FALSE){



# Testing ---------------------------------------------------------------------------------------------------------
  # startdate = NULL
  # enddate = NULL
  # MLocID = NULL
  # AU_ID = 'OR_WS_171200050206_05_106661'
  # HUC12_Name = NULL
  # project = NULL
  # OrganizationID = NULL
  # ReferenceSite = NULL
  # Index_Name = NULL
  # DQL = NULL
  # return_query = FALSE



  # Build base query language ---------------------------------------------------------------------------------------


  ## Get environment variables ----------------------------------------------------------------------------------------



  # Get environment variables
  readRenviron("~/.Renviron")
  assert_AWQMS()

  # AWQMS_usr <- Sys.getenv('AWQMS_usr')
  # AWQMS_pass <- Sys.getenv('AWQMS_pass')



# Initial stations hit, if needed ---------------------------------------------------------------------------------

  if(!is.null(c(AU_ID, HUC12_Name, ReferenceSite))){

    print("Query stations database...")
    tic("Station Database Query")

    # connect to stations database
    station_con <- DBI::dbConnect(odbc::odbc(), "STATIONS")

    stations_filter <- tbl(station_con, "VWStationsFinal") |>
      select(MLocID, EcoRegion2, HUC12_Name,AU_ID, GNIS_Name,ReferenceSite)

    # Add appropriate filters

    if(!is.null(HUC12_Name)){
      stations_filter <- stations_filter |>
        filter(HUC12_Name %in% {{HUC12_Name}})

    }

    if(!is.null(AU_ID )){
      stations_filter <- stations_filter |>
        filter(AU_ID  %in% {{AU_ID}})

    }

    if(!is.null(ReferenceSite )){
      stations_filter <- stations_filter |>
        filter(ReferenceSite  %in% {{ReferenceSite}})

    }



    stations_filter <- stations_filter |>
      collect()

    mlocs_filtered <- stations_filter$MLocID

    DBI::dbDisconnect(station_con)

    print("Query stations database- Complete")
    toc()

    }

  ## Build base query language ---------------------------------------------------------------------------------------


  con <- DBI::dbConnect(odbc::odbc(), 'AWQMS-cloud',
                        UID      =   Sys.getenv('AWQMS_usr'),
                        PWD      =  Sys.getenv('AWQMS_pass'))

  AWQMS_data <- tbl(con, 'indexes_deq_vw')

  #if HUC filter, filter on resultant mlocs
  if(exists('mlocs_filtered')){

    AWQMS_data <- AWQMS_data |>
      filter(MLocID %in% mlocs_filtered)
  }

  # add start date
  if (length(startdate) > 0) {
    AWQMS_data <- AWQMS_data |>
      filter(SampleStartDate >= startdate)
  }



  # add end date
  if (length(MLocID) > 0) {
    AWQMS_data <- AWQMS_data |>
      filter(MLocID %in% {{MLocID}})
  }

  if (length(project) > 0) {
    AWQMS_data <- AWQMS_data |>
      filter(Project1 %in% project)
  }

  if (length(project) > 0) {
    AWQMS_data <- AWQMS_data |>
      filter(Project1 %in% project)
  }

  if (length(OrganizationID) > 0) {
    AWQMS_data <- AWQMS_data |>
      filter(OrganizationID %in% {{OrganizationID}} )
  }

  if (length(Index_Name) > 0) {
    AWQMS_data <- AWQMS_data |>
      filter(Index_Name %in% {{Index_Name}} )
  }

  if (length(DQL) > 0) {
    AWQMS_data <- AWQMS_data |>
      filter(DQL %in% {{DQL}} )
  }

  if(return_query){
    AWQMS_data <- AWQMS_data |>
      show_query()

  } else {

    # Query the database

    print("Query AWQMS database...")
    tic("AWQMS database query")
    AWQMS_data <- AWQMS_data |>
      collect()
    print("Query AWQMS database- Complete")
    toc()


    if(exists('stations_filter')){
      AWQMS_data <- AWQMS_data |>
        left_join(stations_filter, by = 'MLocID' )



    } else {

      stations <- AWQMS_data$MLocID
      tic("Station Database Query")

      print("Query stations database...")
      station_con <- DBI::dbConnect(odbc::odbc(), "STATIONS")

      stations_filter <- tbl(station_con, "VWStationsFinal") |>
        select(MLocID, EcoRegion2, HUC12_Name,AU_ID, GNIS_Name,ReferenceSite)|>
        filter(MLocID %in% stations) |>
        collect()

      print("Query stations database- Complete")
      toc()

      AWQMS_data <- AWQMS_data |>
        left_join(stations_filter, by = 'MLocID' )

    }


    # Disconnect
    DBI::dbDisconnect(con)
  }
  return(AWQMS_data)

}







#
#
#   # Conditionally add additional parameters -----------------------------------------------------------------------------
#
#   # add end date
#   if (length(enddate) > 0) {
#     query = paste0(query, "\n AND Sample_Date <= Convert(datetime, {enddate})" )
#   }
#
#
#   # station
#   if (length(station) > 0) {
#
#     query = paste0(query, "\n AND MLocID IN ({station*})")
#   }
#
#   # AU
#   if (length(AU_ID) > 0) {
#
#     query = paste0(query, "\n AND AU_ID IN ({AU_ID*})")
#   }
#
#
#   #Project
#
#   if (length(project) > 0) {
#     query = paste0(query, "\n AND (Project1 in ({project*}) OR Project2 in ({project*})) ")
#
#   }
#
#   # organization
#   if (length(org) > 0){
#     query = paste0(query,"\n AND OrganizationID in ({org*}) " )
#
#   }
#
#   if(length(HUC12_Name) > 0){
#     query = paste0(query,"\n AND HUC12_Name in ({HUC12_Name*}) " )
#
#   }
#
#   #reference
#
#   if(length(ReferenceSite) > 0){
#     query = paste0(query,"\n AND ReferenceSite in ({ReferenceSite*}) " )
#
#   }
#
#   #metric
#
#   if(length(Index_Name) > 0){
#     query = paste0(query,"\n AND Index_Name in ({Index_Name*}) " )
#
#   }
#
#
#   #Connect to database
#   con <- DBI::dbConnect(odbc::odbc(), "AWQMS")
#
#   # Create query language
#   qry <- glue::glue_sql(query, .con = con)
#
#
#   if(return_query){
#     data_fetch <- qry
#
#   } else {
#
#     # Query the database
#     data_fetch <- DBI::dbGetQuery(con, qry)
#
#
#     # Disconnect
#     DBI::dbDisconnect(con)
#   }
#   return(data_fetch)
#
# }
