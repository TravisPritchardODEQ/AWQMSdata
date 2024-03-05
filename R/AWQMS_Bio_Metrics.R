#' AWQMS_Bio_Metrics
#'
#' Thus function will retrieve Bio_Metrics data from Oregon DEQ AWQMS
#' @param startdate Required parameter setting the startdate of the data being fetched. Format 'yyyy-mm-dd'. Defaults to
#' '1949-09-15'
#' @param enddate Optional parameter setting the enddate of the data being fetched. Format 'yyyy-mm-dd'
#' @param station Optional vector of stations to be fetched
#' @param AU_ID Optional vector of Assessment Units to be fetched
#' @param project Optional vector of projects to be fetched
#' @param org optional vector of Organizations to be fetched
#' @param ReferenceSite filter for reference or non reference streams. NOT CURRENTLY POPULATED
#' @param Metric_Name Optional vector of metrics to filter
#' @param DQL Optional vector of DQLs to fetch
#' @param return_query If FALSE, fetches data from AWQMS. If TRUE, returns string of query language.
#' @export

AWQMS_Bio_Metrics <-
  function(startdate = NULL,
           enddate = NULL,
           MLocID = NULL,
           AU_ID = NULL,
           HUC12_Name = NULL,
           project = NULL,
           OrganizationID = NULL,
           ReferenceSite = NULL,
           Metric_Name = NULL,
           DQL = NULL,
           return_query = FALSE){



    # Build base query language ---------------------------------------------------------------------------------------


    ## Get environment variables ----------------------------------------------------------------------------------------



    # Get environment variables
    readRenviron("~/.Renviron")
    assert_AWQMS()




    if(!is.null(c(AU_ID, HUC12_Name, ReferenceSite))){

      print("Query stations database...")
      tictoc::tic("Station Database Query")

      # connect to stations database
      station_con <- DBI::dbConnect(odbc::odbc(), "STATIONS")

      stations_filter <- dplyr::tbl(station_con, "VWStationsFinal") |>
        dplyr::select(MLocID, EcoRegion2, HUC12_Name,AU_ID, GNIS_Name,ReferenceSite)

      # Add appropriate filters

      if(!is.null(HUC12_Name)){
        stations_filter <- stations_filter |>
          dplyr::filter(HUC12_Name %in% {{HUC12_Name}})

      }

      if(!is.null(AU_ID)){
        stations_filter <- stations_filter |>
          dplyr::filter(AU_ID  %in% {{AU_ID}})

      }

      if(!is.null(ReferenceSite)){
        stations_filter <- stations_filter |>
          dplyr::filter(ReferenceSite  %in% {{ReferenceSite}})

      }



      stations_filter <- stations_filter |>
        dplyr::collect()

      mlocs_filtered <- stations_filter$MLocID

      DBI::dbDisconnect(station_con)

      print("Query stations database- Complete")
      tictoc::toc()

    }



    ## Build base query language ---------------------------------------------------------------------------------------




    con <- DBI::dbConnect(odbc::odbc(), 'AWQMS-cloud',
                          UID      =   Sys.getenv('AWQMS_usr'),
                          PWD      =  Sys.getenv('AWQMS_pass'))

    AWQMS_data <- dplyr::tbl(con, 'metrics_deq_vw')

    #if HUC filter, filter on resultant mlocs
    if(exists('mlocs_filtered')){

      AWQMS_data <- AWQMS_data |>
        dplyr::filter(MLocID %in% mlocs_filtered)
    }

    # add start date
    if (length(startdate) > 0) {
      AWQMS_data <- AWQMS_data |>
        dplyr::filter(Sample_Date  >= startdate)
    }

    # add start date
    if (length(enddate) > 0) {
      AWQMS_data <- AWQMS_data |>
        dplyr::filter(Sample_Date <= enddate)
    }


    # add end date
    if (length(MLocID) > 0) {
      AWQMS_data <- AWQMS_data |>
        dplyr::filter(MLocID %in% {{MLocID}})
    }

    if (length(project) > 0) {
      AWQMS_data <- AWQMS_data |>
        dplyr::filter(Project1 %in% project)
    }


    if (length(OrganizationID) > 0) {
      AWQMS_data <- AWQMS_data |>
        dplyr::filter(OrganizationID %in% {{OrganizationID}} )
    }

    if (length(Metric_Name) > 0) {
      AWQMS_data <- AWQMS_data |>
        dplyr::filter(Metric_Name %in% {{Metric_Name}} )
    }

    if (length(DQL) > 0) {
      AWQMS_data <- AWQMS_data |>
        dplyr::filter(DQL %in% {{DQL}} )
    }

    if(return_query){
      AWQMS_data <- AWQMS_data |>
        dplyr::show_query()

    } else {

      # Query the database

      print("Query AWQMS database...")
      tictoc::tic("AWQMS database query")
      AWQMS_data <- AWQMS_data |>
        dplyr::collect()
      print("Query AWQMS database- Complete")
      tictoc::toc()


      if(exists('stations_filter')){
        AWQMS_data <- AWQMS_data |>
          dplyr::left_join(stations_filter, by = 'MLocID' )



      } else {

        stations <- AWQMS_data$MLocID
        tictoc::tic("Station Database Query")

        print("Query stations database...")
        station_con <- DBI::dbConnect(odbc::odbc(), "STATIONS")

        stations_filter <- dplyr::tbl(station_con, "VWStationsFinal") |>
          dplyr::select(MLocID, EcoRegion2, HUC12_Name,AU_ID, GNIS_Name,ReferenceSite)|>
          dplyr::filter(MLocID %in% stations) |>
          dplyr::collect()

        print("Query stations database- Complete")
        tictoc::toc()

        AWQMS_data <- AWQMS_data |>
          dplyr::left_join(stations_filter, by = 'MLocID' )

      }


      # Disconnect
      DBI::dbDisconnect(con)
    }
    return(AWQMS_data)

  }


