#' AWQMS_Station
#'
#' This function will return a list of monitoring locations with data found in OregonDEQ AWQMS
#' @param project Optional vector of projects to be filtered on
#' @param Char_Name Optional vector of characters to be filtered on
#' @param HUC8 Optional vector of HUC8s to be filtered on
#' @param HUC8_Name Optional vector of HUC8 names to be filtered on
#' @param org Optional vector of organizations to be filtered on
#' @param crit_codes If true, include standard codes used in determining criteria
#' @return Dataframe of monitoring locations
#' @examples AWQMS_Station(project = 'Total Maximum Daily Load Sampling', char = "Temperature, water", HUC8 = "17090003", crit_codes = false)
#' @export


AWQMS_Stations <- function(project = NULL, Char_Name = NULL, HUC8 = NULL, HUC8_Name = NULL,
                           HUC10 = NULL, HUC12 = NULL, HUC12_Name = NULL,  AU_ID = NULL, org = NULL,
                           crit_codes = FALSE) {

print("AWQMS_Stations() doesn't work with the new scheme. If this is important to your workflow, please email Travis Pritchard and I'll figure it out")
# # Testing ---------------------------------------------------------------------------------------------------------
# #
# #   project = NULL
# #   Char_Name = NULL
# #   HUC8 = NULL
# #   HUC8_Name = NULL
# #   HUC10 = NULL
# #   HUC12 = NULL
# #   HUC12_Name = NULL
# #   AU_ID = NULL
# #   org = NULL
# #   crit_codes = FALSE
#
#
#
#     if(!is.null(c(HUC8, HUC8_Name, HUC10, HUC12, HUC12_Name, AU_ID))){
#
#     print("Query stations database...")
#     tic("Station Database Query")
#
#     # connect to stations database
#     station_con <- DBI::dbConnect(odbc::odbc(), "STATIONS")
#
#     stations_filter <- tbl(station_con, "VWStationsFinal") |>
#       select(MLocID, EcoRegion3, EcoRegion4,HUC8, HUC8_Name, HUC10,
#              HUC12, HUC12_Name, Reachcode, Measure,AU_ID, WaterTypeCode, WaterBodyCode,
#              ben_use_code, FishCode, SpawnCode,DO_code,DO_SpawnCode,  BacteriaCode,
#              pH_code)
#
#     # Add appropriate filters
#     if(!is.null(HUC8)){
#       stations_filter <- stations_filter |>
#         filter(HUC8 %in% {{HUC8}})
#
#     }
#
#     if(!is.null(HUC8_Name)){
#       stations_filter <- stations_filter |>
#         filter(HUC8_Name %in% {{HUC8_Name}})
#
#     }
#
#     if(!is.null(HUC10)){
#       stations_filter <- stations_filter |>
#         filter(HUC10 %in% {{HUC10}})
#
#     }
#
#     if(!is.null(HUC12)){
#       stations_filter <- stations_filter |>
#         filter(HUC12 %in% {{HUC12}})
#
#     }
#
#     if(!is.null(HUC12_Name)){
#       stations_filter <- stations_filter |>
#         filter(HUC12_Name %in% {{HUC12_Name}})
#
#     }
#
#     if(!is.null(AU_ID )){
#       stations_filter <- stations_filter |>
#         filter(AU_ID  %in% {{AU_ID}})
#
#     }
#
#
#
#     stations_filter <- stations_filter |>
#       collect()
#
#     mlocs_filtered <- stations_filter$MLocID
#
#     DBI::dbDisconnect(station_con)
#
#     print("Query stations database- Complete")
#     toc()
#
#     }
#
#
#
#   # Get login credientials
#   readRenviron("~/.Renviron")
#   # AWQMS_usr <- Sys.getenv('AWQMS_usr')
#   # AWQMS_pass <- Sys.getenv('AWQMS_pass')
#
#
#
#   con <- DBI::dbConnect(odbc::odbc(), 'AWQMS-cloud',
#                         UID      =   Sys.getenv('AWQMS_usr'),
#                         PWD      =  Sys.getenv('AWQMS_pass'))
#
#   # Get query Language
#
#   AWQMS_data <- tbl(con, 'results_deq_vw')
#
#   #if HUC filter, filter on resultant mlocs
#   if(exists('mlocs_filtered')){
#
#     AWQMS_data <- AWQMS_data |>
#       filter(MLocID %in% mlocs_filtered)
#   }
#
#   if (length(Char_Name) > 0) {
#     AWQMS_data <- AWQMS_data |>
#       filter(Char_Name %in% {{Char_Name}})
#   }
#
#
#
#
#   AWQMS_data <- AWQMS_data |>
#     select(MLocID, Char_Name) |>
#     distinct() |>
#     collect()
#
#
#
#
#
#
#   if(exists('stations_filter')){
#     AWQMS_data <- AWQMS_data |>
#       left_join(stations_filter, by = 'MLocID' )
#
#
#
#   } else {
#
#     stations <- AWQMS_data$MLocID
#     tic("Station Database Query")
#
#     print("Query stations database...")
#     station_con <- DBI::dbConnect(odbc::odbc(), "STATIONS")
#
#     stations_filter <- tbl(station_con, "VWStationsFinal") |>
#       select(MLocID, EcoRegion3, EcoRegion4,HUC8, HUC8_Name, HUC10,
#              HUC12, HUC12_Name, Reachcode, Measure,AU_ID, WaterTypeCode, WaterBodyCode,
#              ben_use_code, FishCode, SpawnCode,DO_code,DO_SpawnCode,  BacteriaCode,
#              pH_code) |>
#       filter(MLocID %in% stations) |>
#       collect()
#
#     print("Query stations database- Complete")
#     toc()
#
#     AWQMS_data <- AWQMS_data |>
#       left_join(stations_filter, by = 'MLocID' )
#
#   }
#
#   if(crit_codes == FALSE){
#
#     AWQMS_data <- AWQMS_data |>
#       select(-WaterTypeCode, -WaterBodyCode, -ben_use_code, -FishCode,
#              -SpawnCode, -DO_code, -DO_SpawnCode,-BacteriaCode, -pH_code )
#   }
#
#
#
#
#   # Disconnect
#   DBI::dbDisconnect(con)
#
# return(AWQMS_data)

}



