#' missing_multiorg_sites
#'
#' This function will find monitoring locations that have multiple organizations
#' associated with the same MLocID. MLocIDs with more than 1 org associated with
#' it are passed to the monitoring_locations_vw view in the stations database to
#' see if they exist. Join failures are then written to an excel file at the
#' save_location identified in the function to be added to the
#' monitoring_locations_vw view in the stations database
#'
#' @param save_location
#'
#' @returns writes an excel file
#' @export
#'


missing_multiorg_sites <- function(save_location){


# Connect to AWQMS stations -----------------------------------------------


con <- DBI::dbConnect(odbc::odbc(), 'AWQMS-cloud',
                      UID      =   Sys.getenv('AWQMS_usr'),
                      PWD      =  Sys.getenv('AWQMS_pass'))

#Get stations with more than 1 org

AWQMS_stations_summary <- dplyr::tbl(con, 'monitoring_locations_vw') |>
  group_by(mloc_id) |>
  summarise(num_orgs = n_distinct(org_id)) |>
  filter(num_orgs > 1) |>
  collect()

stations <- unique(AWQMS_stations_summary$mloc_id)

AWQMS_station <- dplyr::tbl(con, 'monitoring_locations_vw') |>
  filter(mloc_id %in% stations) |>
  collect()


DBI::dbDisconnect(con)


# Connect to stations -----------------------------------------------------



print("Query stations database...")
station_con <- DBI::dbConnect(odbc::odbc(), "STATIONS")
stations_filter <- dplyr::tbl(station_con, "VW_StationsAllDataAllOrgs") |>
  dplyr::select(orgid, MLocID, EcoRegion3, EcoRegion4,HUC8, HUC8_Name, HUC10,
                HUC12, HUC12_Name, Reachcode, Measure,AU_ID, WaterTypeCode, WaterBodyCode,
                ben_use_code, FishCode, SpawnCode,DO_code,DO_SpawnCode, BacteriaCode,
                pH_code) |>
  dplyr::filter(MLocID %in% stations) |>
  dplyr::collect()



missing_station <- AWQMS_station |>
  dplyr::left_join(stations_filter,
                   by = dplyr::join_by('org_id' == 'orgid',
                                       'mloc_id' == 'MLocID') ) |>
  dplyr::filter(is.na(HUC8))


Oregon_multiorg_sites <- missing_station |>
  filter(str_detect(mloc_id, '-ORDEQ')) |>
  transmute(MLocID = mloc_id,
            orgid = org_id)


nonoregon_multiorg_sites <- missing_station |>
  filter(str_detect(mloc_id, '-ORDEQ', negate = TRUE)) |>
  transmute(MLocID = mloc_id,
            station_name = mloc_name,
            orgid = org_id)

print_list <- list('oregon_multiorg_sites' = Oregon_multiorg_sites,
                   'nonoregon_multiorg_sites' = nonoregon_multiorg_sites)



openxlsx::write.xlsx(print_list, file = paste0(save_location,"multi_org_station_to_add.xlsx"))
}



