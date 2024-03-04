#' AWQMS_Raw_Macros
#'
#' Thus function will retrieve raw macroinvertebrate data from Oregon DEQ AWQMS
#' @param startdate Required parameter setting the startdate of the data being fetched. Format 'yyyy-mm-dd'. Defaults to
#' '1949-09-15'
#' @param enddate Optional parameter setting the enddate of the data being fetched. Format 'yyyy-mm-dd'
#' @param station Optional vector of stations to be fetched
#' @param AU_ID Optional vector of Assessment Units to be fetched
#' @param project Optional vector of projects to be fetched
#' @param org optional vector of Organizations to be fetched
#' @param Wade_Boat option for filtering wadeable or boat samples. Options are: 'wadeable', 'boatable', or NULL.
#' @param ReferenceSite filter for reference or non reference streams. Options are: NULL, '<Null>', 'YES', 'Not Loaded',
#' "".
#'@param HUC8 Optional vector of HUC8s to be fetched
#' @param HUC8_Name Optional vector of HUC8 names to be fetched
#' @param HUC10 Optional vector of HUC10s to be fetched
#' @param HUC12 Optional vector of HUC12s to be fetched
#' @param HUC12_Name Optional vector of HUC12 names to be fetched
#' @param Char_Name Optional vector or characteristic names. Options are: 'Count', 'Density'
#' @param Bio_Intent Optional vector or Bio_intent. Options are: 'Population Census', 'Species Density'
#' @param Taxonomic_Name Optional vector of taxa
#' @param StageID Optional vector of stages. Options are: NULL, 'Adult', 'Larva', 'Pupa'
#' @param UniqueTaxon Optioal vector. Options are: 'UniqueTaxon', 'AmbiguousTaxon'
#' @param return_query If FALSE, fetches data from AWQMS. If TRUE, returns string of query language.
#' @return Dataframe of data from AWQMS
#' @export


AWQMS_Raw_Macros <-
  function(startdate = NULL,
           enddate = NULL,
           MLocID = NULL,
           AU_ID = NULL,
           project = NULL,
           OrganizationID = NULL,
           Wade_Boat = NULL,
           ReferenceSite = NULL,
           HUC8 = NULL,
           HUC8_Name = NULL,
           HUC10 = NULL,
           HUC12 = NULL,
           HUC12_Name = NULL,
           Char_Name = NULL,
           Bio_Intent = NULL,
           Taxonomic_Name = NULL,
           StageID = NULL,
           UniqueTaxon = NULL,
           Analytical_method = NULL,
           return_query = FALSE
           ){



# Error checking --------------------------------------------------------------------------------------------


    if(!(is.character(HUC8) | is.null(HUC8))){

      stop('HUC8 value must be a character')
    }

    if(!(is.character(HUC10) | is.null(HUC10))){

      stop('HUC10 value must be a character')
    }

    if(!(is.character(HUC12) | is.null(HUC12))){

      stop('HUC12 value must be a character')
    }





# Initial STATIONS database pull ---------------------------------------------------------------------------------------------

    #If needed to filter on info stored in stations database, query stations and get a list of mlocs to filter




    # If information from stations is needed to filter AWQMS, we need to pull from stations first
    if(!is.null(c(HUC8, HUC8_Name, HUC10, HUC12, HUC12_Name, AU_ID, ReferenceSite, Wade_Boat))){

      print("Query stations database...")
      tic("Station Database Query")

      # connect to stations database
      station_con <- DBI::dbConnect(odbc::odbc(), "STATIONS")

      stations_filter <- tbl(station_con, "VWStationsFinal") |>
        select(MLocID, EcoRegion3, EcoRegion4, EcoRegion2, HUC12_Name, Lat_DD, Long_DD,
               Reachcode, Measure, ELEV_Ft, GNIS_Name, Conf_Score, QC_Comm, COMID, precip_mm, temp_Cx10,
               Predator_WorE, AU_ID, GNIS_Name,ReferenceSite, Wade_Boat)

      # Add appropriate filters

      if(!is.null(HUC8)){
        stations_filter <- stations_filter |>
          filter(HUC8 %in% {{HUC8}})

      }

      if(!is.null(HUC8_Name)){
        stations_filter <- stations_filter |>
          filter(HUC8_Name %in% {{HUC8_Name}})

      }

      if(!is.null(HUC10)){
        stations_filter <- stations_filter |>
          filter(HUC10 %in% {{HUC10}})

      }

      if(!is.null(HUC12)){
        stations_filter <- stations_filter |>
          filter(HUC12 %in% {{HUC12}})

      }

      if(!is.null(HUC12_Name)){
        stations_filter <- stations_filter |>
          filter(HUC12_Name %in% {{HUC12_Name}})

      }

      if(!is.null(AU_ID)){
        stations_filter <- stations_filter |>
          filter(AU_ID %in% {{AU_ID}})

      }


      if(!is.null(GNIS_Name)){
        stations_filter <- stations_filter |>
          filter(GNIS_Name %in% {{GNIS_Name}})

      }


      if(!is.null(ReferenceSite)){
        stations_filter <- stations_filter |>
          filter(ReferenceSite %in% {{ReferenceSite}})

      }

      if(!is.null(Wade_Boat)){
        stations_filter <- stations_filter |>
          filter(Wade_Boat %in% {{Wade_Boat}})

      }



      stations_filter <- stations_filter |>
        collect()

      mlocs_filtered <- stations_filter$MLocID

      DBI::dbDisconnect(station_con)

      print("Query stations database- Complete")
      toc()

    }



# Build base query language ---------------------------------------------------------------------------------------


## Get environment variables ----------------------------------------------------------------------------------------



    # Get environment variables
    readRenviron("~/.Renviron")

    assert_AWQMS()



    con <- DBI::dbConnect(odbc::odbc(), 'AWQMS-cloud',
                          UID      =   Sys.getenv('AWQMS_usr'),
                          PWD      =  Sys.getenv('AWQMS_pass'))

    AWQMS_data <- tbl(con, 'results_macro_deq_vw')


    #if HUC filter, filter on resultant mlocs
    if(exists('mlocs_filtered')){

      AWQMS_data <- AWQMS_data |>
        filter(MLocID %in% mlocs_filtered)
    }

    # add start date
    if (length(startdate) > 0) {
      AWQMS_data <- AWQMS_data |>
        filter(SampleStart_Date >= {{startdate}})
    }



    # add end date


    if (length(enddate) > 0) {
      AWQMS_data <- AWQMS_data |>
        filter(SampleStart_Date<= {{enddate}})
    }

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

    if (length(Char_Name) > 0) {
      AWQMS_data <- AWQMS_data |>
        filter(Char_Name  %in% {{Char_Name}} )
    }

    if (length(Bio_Intent) > 0) {
      AWQMS_data <- AWQMS_data |>
        filter(Bio_Intent  %in% {{Bio_Intent}} )
    }

    if (length(Taxonomic_Name) > 0) {
      AWQMS_data <- AWQMS_data |>
        filter(Taxonomic_Name  %in% {{Taxonomic_Name}} )
    }

    if (length(StageID) > 0) {
      AWQMS_data <- AWQMS_data |>
        filter(StageID  %in% {{StageID}} )
    }

    if (length(UniqueTaxon) > 0) {
      AWQMS_data <- AWQMS_data |>
        filter(UniqueTaxon  %in% {{UniqueTaxon}} )
    }

    if (length(Analytical_method) > 0) {
      AWQMS_data <- AWQMS_data |>
        filter(Analytical_method  %in% {{Analytical_method}} )
    }



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
        select(MLocID, EcoRegion3, EcoRegion4, EcoRegion2, HUC12_Name, Lat_DD, Long_DD,
               Reachcode, Measure, ELEV_Ft, GNIS_Name, Conf_Score, QC_Comm, COMID, precip_mm, temp_Cx10,
               Predator_WorE, AU_ID, GNIS_Name,ReferenceSite, Wade_Boat)|>
        filter(MLocID %in% stations) |>
        collect()

      print("Query stations database- Complete")
      toc()

      AWQMS_data <- AWQMS_data |>
        left_join(stations_filter, by = 'MLocID' )

    }


    # Disconnect
    DBI::dbDisconnect(con)

return(AWQMS_data)

  }





