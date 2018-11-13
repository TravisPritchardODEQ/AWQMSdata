#' AWQMS_ORGS
#'
#' This function will return a list of organizations with data in AWQMS found in OregonDEQ AWQMS
#' @param project Optional vector of projects to be filtered on
#' @param station Optional vector of stations to be filtered on
#' @return Dataframe of organizations with available data
#' @examples AWQMS_Orgs(project = 'Total Maximum Daily Load Sampling', c('10591-ORDEQ', '29542-ORDEQ'))
#' @export


AWQMS_Orgs <- function(project = NULL, station = NULL) {

  #Connect to database
  con <- DBI::dbConnect(odbc::odbc(), "AWQMS")

  query = "SELECT distinct [OrganizationID]
  FROM [awqms].[dbo].[VW_AWQMS_Results]"

  if (length(project) > 0) {
    query <- paste0(query, "\n WHERE (Project1 in ({project*}) OR Project2 in ({project*}))")

  }

  # station
  if (length(station) > 0) {

    if (length(project) > 0) {
      query = paste0(query, "\n AND MLocID IN ({station*})")
    } else {
      query <- paste0(query, "\n WHERE MLocID IN ({station*})")
    }

  }



  # Create query language
  qry <- glue::glue_sql(query, .con = con)


  # Query the database
  data_fetch <- DBI::dbGetQuery(con, qry)

  # Disconnect
  DBI::dbDisconnect(con)

  return(data_fetch)

}
