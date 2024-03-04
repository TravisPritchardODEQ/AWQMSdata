#' AWQMS_Data_Cont
#'
#' This function will retrive raw continuous data from OregonDEQ AWQMS
#' @param startdate Required parameter setting the startdate of the data being fetched. Format 'yyyy-mm-dd'
#' @param enddate Optional parameter setting the enddate of the data being fetched. Format 'yyyy-mm-dd'
#' @param station Optional vector of stations to be fetched
#' @param AU_ID Optional vector of Assessment units to be fetched
#' @param char Optional vector of characteristics to be fetched
#' @param media Optional vector of sample media to be fetched
#' @param org optional vector of Organizations to be fetched
#' @param HUC8 Optional vector of HUC8s to be fetched
#' @param HUC8_Name Optional vector of HUC8 names to be fetched
#' @param HUC10 Optional vector of HUC10s to be fetched
#' @param HUC12 Optional vector of HUC12s to be fetched
#' @param HUC12_Name Optional vector of HUC12 names to be fetched
#' @param Result_Status oprtion vector of result status to be fetched. Set to Result_Status = 'Final' if only data that has passed QAQC is included
#' @param crit_codes If true, include standard codes used in determining criteria
#' @return Dataframe of data from AWQMS
#' @examples
#' AWQMS_Data_Cont(station = '39446-ORDEQ', Result_Status = 'Final')
#' @export


AWQMS_Data_Cont <-
  function(startdate = NULL,
           enddate = NULL,
           MLocID = NULL,
           AU_ID = NULL,
           Char_Name = NULL,
           SampleMedia = NULL,
           OrganizationID = NULL,
           HUC8 = NULL,
           HUC8_Name = NULL,
           HUC10 = NULL,
           HUC12 = NULL,
           HUC12_Name = NULL,
           Result_Status = NULL,
           crit_codes = FALSE
  ) {




# Testing ---------------------------------------------------------------------------------------------------------

    startdate = NULL
    enddate = NULL
    MLocID = NULL
    AU_ID = NULL
    Char_Name = NULL
    SampleMedia = NULL
    OrganizationID = NULL
    HUC8 = NULL
    HUC8_Name = NULL
    HUC10 = NULL
    HUC12 = NULL
    HUC12_Name = NULL
    Result_Status = NULL
    crit_codes = FALSE


# Initial STATIONS database pull ---------------------------------------------------------------------------------------------

    #If needed to filter on info stored in stations database, query stations and get a list of mlocs to filter




    # If information from stations is needed to filter AWQMS, we need to pull from stations first
    if(!is.null(c(HUC8, HUC8_Name, HUC10, HUC12, HUC12_Name, AU_ID))){

      print("Query stations database...")
      tic("Station Database Query")

      # connect to stations database
      station_con <- DBI::dbConnect(odbc::odbc(), "STATIONS")

      stations_filter <- tbl(station_con, "VWStationsFinal") |>
        select(MLocID, EcoRegion3, EcoRegion4,HUC8, HUC8_Name, HUC10,
               HUC12, HUC12_Name, Reachcode, Measure,AU_ID, WaterTypeCode, WaterBodyCode,
               ben_use_code, FishCode, SpawnCode,DO_code,DO_SpawnCode,  BacteriaCode,
               pH_code)

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

      if(!is.null(AU_ID )){
        stations_filter <- stations_filter |>
          filter(AU_ID  %in% {{AU_ID}})

      }






      stations_filter <- stations_filter |>
        collect()

      mlocs_filtered <- stations_filter$MLocID

      DBI::dbDisconnect(station_con)

      print("Query stations database- Complete")
      toc()

    }






    # Get environment variables
    # Get environment variables


    readRenviron("~/.Renviron")

    con <- DBI::dbConnect(odbc::odbc(), 'AWQMS-cloud',
                          UID      =   Sys.getenv('AWQMS_usr'),
                          PWD      =  Sys.getenv('AWQMS_pass'))




    AWQMS_data <- dplyr::tbl(con, 'continuous_results_deq_vw')


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
    if (length(enddate) > 0) {
      AWQMS_data <- AWQMS_data |>
        filter(SampleStartDate <= enddate)
    }

    if (length(MLocID) > 0) {
      AWQMS_data <- AWQMS_data |>
        dplyr::filter(MLocID %in% {{MLocID}})
    }



    if (length(Char_Name) > 0) {
      AWQMS_data <- AWQMS_data |>
        filter(Char_Name %in% {{Char_Name}})
    }



    if (length(SampleMedia  ) > 0) {
      AWQMS_data <- AWQMS_data |>
        filter(SampleMedia   %in% {{SampleMedia}} )
    }


    if (length(OrganizationID) > 0) {
      AWQMS_data <- AWQMS_data |>
        filter(OrganizationID %in% {{OrganizationID}} )
    }

    if (length(Result_Status) > 0) {
      AWQMS_data <- AWQMS_data |>
        dplyr::filter(Result_Status %in% {{Result_Status}})
    }




    print("Query AWQMS database...")
    tic("AWQMS database query")
    AWQMS_data <- AWQMS_data |>
      dplyr::collect()
    print("Query AWQMS database- Complete")
    toc()



    # Add in stations info --------------------------------------------------------------------------------------------



    if(exists('stations_filter')){
      AWQMS_data <- AWQMS_data |>
        left_join(stations_filter, by = 'MLocID' )



    } else {

      stations <- AWQMS_data$MLocID
      tic("Station Database Query")

      print("Query stations database...")
      station_con <- DBI::dbConnect(odbc::odbc(), "STATIONS")

      stations_filter <- tbl(station_con, "VWStationsFinal") |>
        select(MLocID, EcoRegion3, EcoRegion4,HUC8, HUC8_Name, HUC10,
               HUC12, HUC12_Name, Reachcode, Measure,AU_ID, WaterTypeCode, WaterBodyCode,
               ben_use_code, FishCode, SpawnCode,DO_code,DO_SpawnCode,  BacteriaCode,
               pH_code) |>
        filter(MLocID %in% stations) |>
        collect()

      print("Query stations database- Complete")
      toc()

      AWQMS_data <- AWQMS_data |>
        left_join(stations_filter, by = 'MLocID' )

    }

    if(crit_codes == FALSE){

      AWQMS_data <- AWQMS_data |>
        select(-WaterTypeCode, -WaterBodyCode, -ben_use_code, -FishCode,
               -SpawnCode, -DO_code, -DO_SpawnCode,-BacteriaCode, -pH_code )
    }




    # Disconnect
    DBI::dbDisconnect(con)
  }
return(AWQMS_data)

}

