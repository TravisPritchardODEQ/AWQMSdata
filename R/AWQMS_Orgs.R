#' AWQMS_ORGS
#'
#' This function will return a dataframe of organizations with data in AWQMS found in OregonDEQ AWQMS
#' @param project Optional vector of projects to be filtered on
#' @param MLocID Optional vector of stations to be filtered on
#' @return Dataframe of organizations with available data
#' @examples AWQMS_Orgs(project = 'Total Maximum Daily Load Sampling', c('10591-ORDEQ', '29542-ORDEQ'))
#' @export


AWQMS_Orgs <- function(project = NULL, MLocID = NULL) {

  # Get environment variables
  readRenviron("~/.Renviron")
  assert_AWQMS()


  AWQMS_server <- Sys.getenv('AWQMS_SERVER')



  con <- DBI::dbConnect(odbc::odbc(), 'AWQMS-cloud',
                        UID      =   Sys.getenv('AWQMS_usr'),
                        PWD      =  Sys.getenv('AWQMS_pass'))


  AWQMS_data <- tbl(con, 'results_deq_vw')

  if (length(project) > 0) {
    AWQMS_data <- AWQMS_data |>
      filter(Project1 %in% project)
  }


  if (length(MLocID) > 0) {
    AWQMS_data <- AWQMS_data |>
      filter(MLocID %in% {{MLocID}})
  }


  AWQMS_data <- AWQMS_data |>
    select(OrganizationID, org_name) |>
    distinct() |>
    collect()


  # Disconnect
  DBI::dbDisconnect(con)

  return(AWQMS_data)

}
