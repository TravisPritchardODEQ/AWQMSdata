#' AWQMS_Station
#'
#' This function will return a list of monitoring locations with data found in OregonDEQ AWQMS
#' @param project Optional vector of projects to be filtered on
#' @param Char_Name Optional vector of characters to be filtered on
#' @param HUC8 Optional vector of HUC8s to be filtered on
#' @param HUC8_Name Optional vector of HUC8 names to be filtered on
#' @param OrganizationID Optional vector of organizations to be filtered on
#' @param crit_codes If true, include standard codes used in determining criteria
#' @return Dataframe of monitoring locations
#' @examples AWQMS_Station(project = 'Total Maximum Daily Load Sampling', char = "Temperature, water", HUC8 = "17090003", crit_codes = false)
#' @export


AWQMS_Stations <- function(project = NULL, MonLocType = NULL, Char_Name = NULL, HUC8 = NULL, HUC8_Name = NULL, OrganizationID = NULL, crit_codes = FALSE) {

  # Get environment variables
  readRenviron("~/.Renviron")
  assert_AWQMS()



  # Initial STATIONS database pull ---------------------------------------------------------------------------------------------

  #If needed to filter on info stored in stations database, query stations and get a list of mlocs to filter



  # If information from stations is needed to filter AWQMS, we need to pull from stations first
  if(!is.null(c(HUC8, HUC8_Name, MonLocType))){

    print("Query stations database...")
    tictoc::tic("Station Database Query")

    # connect to stations database
    station_con <- DBI::dbConnect(odbc::odbc(), "STATIONS")

    stations_filter <- dplyr::tbl(station_con, "VWStationsFinal") |>
      dplyr::select(MLocID,StationDes,GNIS_Name,AU_ID, Lat_DD,Long_DD, MonLocType,EcoRegion3,
                    EcoRegion4,HUC8,HUC8_Name,HUC10,HUC12,HUC12_Name,
                    Reachcode,Measure,COMID, OWRD_Basin, FishCode, SpawnCode,
                    WaterTypeCode, WaterBodyCode, BacteriaCode, DO_code,DO_SpawnCode, pH_code, ben_use_code  )

    # Add appropriate filters
    if(!is.null(HUC8)){
      stations_filter <- stations_filter |>
        dplyr::filter(HUC8 %in% {{HUC8}})

    }

    if(!is.null(HUC8_Name)){
      stations_filter <- stations_filter |>
        dplyr::filter(HUC8_Name %in% {{HUC8_Name}})

    }

    if(!is.null(MonLocType)){
      stations_filter <- stations_filter |>
        dplyr::filter(MonLocType %in% {{MonLocType}})

    }


    stations_filter <- stations_filter |>
      dplyr::collect()

    mlocs_filtered <- stations_filter$MLocID

    DBI::dbDisconnect(station_con)

    print("Query stations database- Complete")
    tictoc::toc()

  }




  # Connect to database -----------------------------------------------------

  con <- DBI::dbConnect(odbc::odbc(), 'AWQMS-cloud',
                        UID      =   Sys.getenv('AWQMS_usr'),
                        PWD      =  Sys.getenv('AWQMS_pass'))




  # Get query Language

  AWQMS_data <- dplyr::tbl(con, 'results_deq_vw')


  #if HUC filter, filter on resultant mlocs
  if(exists('mlocs_filtered')){

    AWQMS_data <- AWQMS_data |>
      dplyr::filter(MLocID %in% mlocs_filtered)
  }




  if (length(project) > 0) {
    AWQMS_data <- AWQMS_data |>
      dplyr::filter(Project1 %in% project)
  }


  if (length(Char_Name) > 0) {
    AWQMS_data <- AWQMS_data |>
      dplyr::filter(Char_Name %in% {{Char_Name}})
  }

  if (length(OrganizationID) > 0) {
    AWQMS_data <- AWQMS_data |>
      dplyr::filter(OrganizationID %in% {{OrganizationID}} )
  }

  print("Query AWQMS database...")

  AWQMS_data <- AWQMS_data |>
    dplyr::select(MLocID,OrganizationID) |>
    dplyr::distinct()


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

    if(length(stations) == 0){
      AWQMS_data <- AWQMS_data |>
        dplyr::mutate(StationDes = NA_character_,
                      MonLocType = NA_character_,
                      EcoRegion3 = NA_character_,
                      EcoRegion4 = NA_character_,
                      HUC8 = NA_character_,
                      HUC8_Name = NA_character_,
                      HUC10 = NA_character_,
                      HUC12 = NA_character_,
                      HUC12_Name = NA_character_,
                      Reachcode = NA_character_,
                      Measure = NA_character_,
                      AU_ID = NA_character_,
                      WaterTypeCode = NA_character_,
                      WaterBodyCode = NA_character_,
                      ben_use_code = NA_character_,
                      FishCode = NA_character_,
                      SpawnCode = NA_character_,
                      DO_code = NA_character_,
                      DO_SpawnCode = NA_character_,
                      BacteriaCode = NA_character_,
                      pH_code = NA_character_,

        )


    } else {



      tictoc::tic("Station Database Query")

      print("Query stations database...")
      station_con <- DBI::dbConnect(odbc::odbc(), "STATIONS")

      stations_filter <- dplyr::tbl(station_con, "VWStationsFinal") |>
        dplyr::select(MLocID,StationDes,GNIS_Name,AU_ID, Lat_DD,Long_DD, MonLocType,EcoRegion3,
                      EcoRegion4,HUC8,HUC8_Name,HUC10,HUC12,HUC12_Name,
                      Reachcode,Measure,COMID, OWRD_Basin, FishCode, SpawnCode,
                      WaterTypeCode, WaterBodyCode, BacteriaCode, DO_code,DO_SpawnCode, pH_code, ben_use_code ) |>
        dplyr::filter(MLocID %in% stations) |>
        dplyr::collect()

      print("Query stations database- Complete")
      tictoc::toc()

      AWQMS_data <- AWQMS_data |>
        dplyr::left_join(stations_filter, by = 'MLocID' )

    }

    if(crit_codes == FALSE){

      AWQMS_data <- AWQMS_data |>
        dplyr::select(-WaterTypeCode, -WaterBodyCode, -ben_use_code, -FishCode,
                      -SpawnCode, -DO_code, -DO_SpawnCode,-BacteriaCode, -pH_code )
    }



    # Disconnect
    DBI::dbDisconnect(con)
  }
  return(AWQMS_data)

}


