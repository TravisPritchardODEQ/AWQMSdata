#' AWQMS_Chars
#'
#' This function will return a list of characterustucs found in OregonDEQ AWQMS
#' @param project Optional vector of projects to be filtered on
#' @param MLocID Optional vector of stations to be filtered on
#' @return Dataframe of available characteristics
#' @examples AWQMS_Chars(project = 'Total Maximum Daily Load Sampling', station = c('10591-ORDEQ', '29542-ORDEQ'))
#' @export


AWQMS_Chars <- function(project = NULL, MLocID = NULL) {

  # Get environment variables
  readRenviron("~/.Renviron")
  assert_AWQMS()


  AWQMS_server <- Sys.getenv('AWQMS_SERVER')



  con <- DBI::dbConnect(odbc::odbc(), 'AWQMS-cloud',
                        UID      =   Sys.getenv('AWQMS_usr'),
                        PWD      =  Sys.getenv('AWQMS_pass'))


  AWQMS_data <- dplyr::tbl(con, 'results_deq_vw')

  if (length(project) > 0) {
    AWQMS_data <- AWQMS_data |>
      dplyr::filter(Project1 %in% project)
  }


  if (length(MLocID) > 0) {
    AWQMS_data <- AWQMS_data |>
      dplyr::filter(MLocID %in% {{MLocID}})
  }


  AWQMS_data <- AWQMS_data |>
    dplyr::select(Char_Name) |>
    dplyr::distinct() |>
    dplyr::collect()


  # Disconnect
  DBI::dbDisconnect(con)

  return(AWQMS_data)

}
