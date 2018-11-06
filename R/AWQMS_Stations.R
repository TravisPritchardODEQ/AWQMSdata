#' AWQMS_Station
#'
#' This function will return a list of monitoring locations with data found in OregonDEQ AWQMS
#' @param project Optional vector of projects to be filtered on
#' @param station Optional vector of stations to be filtered on
#' @param HUC8 Optional vector of HUC8s to be filtered on
#' @return Dataframe of monitoring locations
#' @examples AWQMS_Station(project = 'Total Maximum Daily Load Sampling', station = c('29820-ORDEQ', '10724-ORDEQ'), HUC8 = )
#' @export


AWQMS_Station <- function(project = NULL, char = NULL, HUC8 = NULL) {


# Connect to database -----------------------------------------------------


  con <- DBI::dbConnect(odbc::odbc(), "AWQMS")

  query = "SELECT distinct [Char_Name]
  FROM [awqms].[dbo].[VW_AWQMS_Results]"

  if (length(project) > 0) {
    query <- paste0(query, "\n WHERE (Project1 in ({project*}) OR Project2 in ({project*}))")

  }


# Station Filter ----------------------------------------------------------


  if (length(char) > 0) {

    if (length(project) > 0) {
      query = paste0(query, "\n AND Char_Name IN ({char*})")
    } else {
      query <- paste0(query, "\n WHERE Char_Name IN ({char*})")
    }

    }


# HUC8 Filter -------------------------------------------------------------


   if(length(HUC8) > 0){

     if(length(project) > 0 | length(station > 0) ){
       query = paste0(query, "\n AND HUC8 IN ({HUC8*})")

     }  else {
       query <- paste0(query, "\n WHERE HUC8 IN ({HUC8*})")
       }

   }


# Put query language together ---------------------------------------------


  qry <- glue::glue_sql(query, .con = con)



# Send query ot database --------------------------------------------------


  data_fetch <- DBI::dbGetQuery(con, qry)


# Disconnect fron database ------------------------------------------------


  DBI::dbDisconnect(con)


# Return dataframe --------------------------------------------------------


  return(data_fetch)

}
