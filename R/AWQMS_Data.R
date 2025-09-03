#' AWQMS_Data
#'
#' This function will retrieve data from OregonDEQ AWQMS
#' @param startdate Optional parameter setting the startdate of the data being fetched. Format 'yyyy-mm-dd'
#' @param enddate Optional parameter setting the enddate of the data being fetched. Format 'yyyy-mm-dd'
#' @param MLocID Optional vector of stations to be fetched
#' @param AU_ID Optional vector of Assessment Units to be fetched
#' @param project Optional vector of projects to be fetched
#' @param Char_Name Optional vector of characteristics to be fetched
#' @param CASNumber Optional vector of CAS numbers to be fetched
#' @param Statistical_Base Optional vector of Result Stattistical Bases to be fetched ex. Maximum
#' @param SampleMedia Optional vector of sample media to be fetched
#' @param SampleSubmedia Optional vector of sample submedia to be fetched
#' @param OrganizationID optional vector of Organizations to be fetched
#' @param HUC8 Optional vector of HUC8s to be fetched
#' @param HUC8_Name Optional vector of HUC8 names to be fetched
#' @param HUC10 Optional vector of HUC10s to be fetched
#' @param HUC12 Optional vector of HUC12s to be fetched
#' @param HUC12_Name Optional vector of HUC12 names to be fetched
#' @param crit_codes If true, include standard codes used in determining criteria
#' @param filterQC If true, do not return MLocID 10000-ORDEQ or sample replicates
#' @param return_query If true, return the query language that would have been sent to AWQMS. If TRUE, nothing is sent to AWQMS. This is useful for troubleshooting.
#' @return Dataframe of data from AWQMS
#' @examples
#' AWQMS_Data(startdate = '2000-1-1', enddate = '2000-12-31', MLocID = c('10591-ORDEQ', '29542-ORDEQ'),
#' project = 'Total Maximum Daily Load Sampling', filterQC = FALSE, crit_codes = FALSE)
#' @export
#'
#'


AWQMS_Data <-
  function(startdate = '1949-09-15',
           enddate = NULL,
           MLocID  = NULL,
           MonLocType = NULL,
           AU_ID = NULL,
           project = NULL,
           Char_Name  = NULL,
           CASNumber = NULL,
           Statistical_Base = NULL,
           SampleMedia = NULL,
           SampleSubmedia = NULL,
           OrganizationID = NULL,
           HUC8 = NULL,
           HUC8_Name = NULL,
           HUC10 = NULL,
           HUC12 = NULL,
           HUC12_Name = NULL,
           EcoRegion3 = NULL,
           last_change_start = NULL,
           last_change_end = NULL,
           crit_codes = FALSE,
           filterQC = TRUE,
           return_query = FALSE) {



    #testing
    # startdate = '1949-09-15'
    # enddate = NULL
    # MLocID = c('41440-ORDEQ', '41439-ORDEQ', '37108-ORDEQ')
    # AU_ID = NULL
    # project = NULL
    # Char_Name = c('Temperature, water')
    # stat_base = NULL
    # media = NULL
    # submedia = NULL
    # org = NULL
    # EcoRegion3 = NULL
    # HUC8 = NULL
    # HUC8_Name = NULL
    # HUC10 = NULL
    # HUC12 = NULL
    # HUC12_Name = NULL
    # crit_codes = FALSE
    # filterQC = TRUE


# Error Checking --------------------------------------------------------------------------------------------------



if(!(is.character(HUC8) | is.null(HUC8))){

  stop('HUC8 value must be a character')
}

    if(!(is.character(HUC10) | is.null(HUC10))){

      stop('HUC10 value must be a character')
    }

    if(!(is.character(HUC12) | is.null(HUC12))){

      stop('HUC12 value must be a character')
    }



    # Get environment variables
    readRenviron("~/.Renviron")
    assert_AWQMS()


# Initial STATIONS database pull ---------------------------------------------------------------------------------------------

    #If needed to filter on info stored in stations database, query stations and get a list of mlocs to filter




   # If information from stations is needed to filter AWQMS, we need to pull from stations first
    if(!is.null(c(HUC8, HUC8_Name, HUC10, HUC12, HUC12_Name, AU_ID, EcoRegion3))){

      print("Query stations database...")
      tictoc::tic("Station Database Query")

      # connect to stations database
      station_con <- DBI::dbConnect(odbc::odbc(), "STATIONS")

      stations_filter <- dplyr::tbl(station_con, "VW_StationsAllDataAllOrgs") |>
        dplyr::select(orgid, MLocID, EcoRegion3, EcoRegion4,HUC8, HUC8_Name, HUC10,
               HUC12, HUC12_Name, Reachcode, Measure,AU_ID, WaterTypeCode, WaterBodyCode,
               ben_use_code, FishCode, SpawnCode,DO_code,DO_SpawnCode,  BacteriaCode,
               pH_code)

      # Add appropriate filters
      if(!is.null(HUC8)){
        stations_filter <- stations_filter |>
          dplyr::filter(HUC8 %in% {{HUC8}})

      }

      if(!is.null(HUC8_Name)){
        stations_filter <- stations_filter |>
          dplyr::filter(HUC8_Name %in% {{HUC8_Name}})

      }

      if(!is.null(HUC10)){
        stations_filter <- stations_filter |>
          dplyr::filter(HUC10 %in% {{HUC10}})

      }

      if(!is.null(HUC12)){
        stations_filter <- stations_filter |>
          dplyr::filter(HUC12 %in% {{HUC12}})

      }

      if(!is.null(HUC12_Name)){
        stations_filter <- stations_filter |>
          dplyr::filter(HUC12_Name %in% {{HUC12_Name}})

      }

      if(!is.null(AU_ID )){
        stations_filter <- stations_filter |>
          dplyr::filter(AU_ID  %in% {{AU_ID}})

      }

      if(!is.null(EcoRegion3)){
        stations_filter <- stations_filter |>
          dplyr::filter(EcoRegion3  %in% {{EcoRegion3}})

      }



      stations_filter <- stations_filter |>
        dplyr::collect()

      mlocs_filtered <- stations_filter$MLocID

      DBI::dbDisconnect(station_con)

      print("Query stations database- Complete")
      tictoc::toc()

    }




# Connect to AWQMS ------------------------------------------------------------------------------------------------

    # Get login credientials
    readRenviron("~/.Renviron")
    # AWQMS_usr <- Sys.getenv('AWQMS_usr')
    # AWQMS_pass <- Sys.getenv('AWQMS_pass')



    con <- DBI::dbConnect(odbc::odbc(), 'AWQMS-cloud',
                          UID      =   Sys.getenv('AWQMS_usr'),
                          PWD      =  Sys.getenv('AWQMS_pass'))


    # Get query Language

    AWQMS_data_import <- dplyr::tbl(con, 'results_deq_vw')

    #if HUC filter, filter on resultant mlocs
    if(exists('mlocs_filtered')){

      AWQMS_data_import <- AWQMS_data_import |>
        dplyr::filter(MLocID %in% mlocs_filtered)
    }

    # add start date
    if (length(startdate) > 0) {
      AWQMS_data_import <- AWQMS_data_import |>
        dplyr::filter(SampleStartDate >= startdate)
    }

    # add end date
    if (length(enddate) > 0) {
      AWQMS_data_import <- AWQMS_data_import |>
        dplyr::filter(SampleStartDate <= enddate)
    }

    if (length(last_change_start) > 0) {
      AWQMS_data_import <- AWQMS_data_import |>
        dplyr::filter(res_last_change_date >= last_change_start)
    }
    if (length(last_change_end) > 0) {
      AWQMS_data_import <- AWQMS_data_import |>
        dplyr::filter(res_last_change_date <= last_change_end)
    }


    if (length(MLocID ) > 0) {
      AWQMS_data_import <- AWQMS_data_import |>
        dplyr::filter(MLocID %in% {{MLocID}})
    }

    if (length(MonLocType) > 0) {
      AWQMS_data_import <- AWQMS_data_import |>
        dplyr::filter(MonLocType %in% {{MonLocType}})
    }


    if (length(project) > 0) {
      AWQMS_data_import <- AWQMS_data_import |>
        dplyr::filter(Project1 %in% project)
    }

    if (length(Char_Name) > 0) {
      AWQMS_data_import <- AWQMS_data_import |>
        dplyr::filter(Char_Name %in% {{Char_Name}})
    }

    if (length(CASNumber) > 0) {
      AWQMS_data_import <- AWQMS_data_import |>
        dplyr::filter(CASNumber  %in% {{CASNumber}})
    }

    if (length(Statistical_Base ) > 0) {
      AWQMS_data_import <- AWQMS_data_import |>
        dplyr::filter(Statistical_Base  %in% {{Statistical_Base}} )
    }

    if (length(SampleMedia  ) > 0) {
      AWQMS_data_import <- AWQMS_data_import |>
        dplyr::filter(SampleMedia   %in% {{SampleMedia}} )
    }

    if (length(SampleSubmedia  ) > 0) {
      AWQMS_data_import <- AWQMS_data_import |>
        dplyr::filter(SampleSubmedia %in% {{SampleSubmedia}} )
    }

    if (length(OrganizationID) > 0) {
      AWQMS_data_import <- AWQMS_data_import |>
        dplyr::filter(OrganizationID %in% {{OrganizationID}} )
    }

    if (filterQC == TRUE) {
      AWQMS_data_import <- AWQMS_data_import |>
        dplyr::filter(!Activity_Type %like% "Quality Control%")
    }

    if(return_query){
      AWQMS_data_import <- AWQMS_data_import |>
        dplyr::show_query()

    } else {

      # Query the database

      print("Query AWQMS database...")
      tictoc::tic("AWQMS database query")
      AWQMS_data_import <- AWQMS_data_import |>
        dplyr::collect()
      print("Query AWQMS database- Complete")
      tictoc::toc()


# Add in stations info --------------------------------------------------------------------------------------------



      if(exists('stations_filter')){
        AWQMS_data_import <- AWQMS_data_import |>
          dplyr::left_join(stations_filter,
                           by = dplyr::join_by('OrganizationID' == 'orgid', 'MLocID' == 'MLocID'))



      } else {

        stations <- unique(AWQMS_data_import$MLocID)

        if(length(stations) == 0){
          AWQMS_data_import <- AWQMS_data_import |>
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

        stations_filter <- dplyr::tbl(station_con, "VW_StationsAllDataAllOrgs") |>
          dplyr::select(orgid, MLocID, EcoRegion3, EcoRegion4,HUC8, HUC8_Name, HUC10,
                 HUC12, HUC12_Name, Reachcode, Measure,AU_ID, WaterTypeCode, WaterBodyCode,
                 ben_use_code, FishCode, SpawnCode,DO_code,DO_SpawnCode, BacteriaCode,
                 pH_code) |>
          dplyr::filter(MLocID %in% stations) |>
          dplyr::collect()

        print("Query stations database- Complete")
        tictoc::toc()

        AWQMS_data_import <- AWQMS_data_import |>
          dplyr::left_join(stations_filter,
                           by = dplyr::join_by('OrganizationID' == 'orgid', 'MLocID' == 'MLocID') ) #make this include org also\

      }
      if(crit_codes == FALSE){

        AWQMS_data_import <- AWQMS_data_import |>
          dplyr::select(-WaterTypeCode, -WaterBodyCode, -ben_use_code, -FishCode,
                 -SpawnCode, -DO_code, -DO_SpawnCode,-BacteriaCode, -pH_code )
      }




      # Disconnect
      DBI::dbDisconnect(con)
    }
    return(AWQMS_data_import)

    }
  }
