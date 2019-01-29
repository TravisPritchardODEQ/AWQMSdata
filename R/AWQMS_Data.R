#' AWQMS_Data
#'
#' This function will retrive data from OregonDEQ AWQMS
#' @param startdate Required parameter setting the startdate of the data being fetched. Format 'yyyy-mm-dd'
#' @param enddate Optional parameter setting the enddate of the data being fetched. Format 'yyyy-mm-dd'
#' @param station Optional vector of stations to be fetched
#' @param project Optional vector of projects to be fetched
#' @param char Optional vector of characteristics to be fetched
#' @param stat_base Optional vector of Result Stattistical Bases to be fetched ex. Maximum
#' @param media Optional vector of sample media to be fetched
#' @param org optional vector of Organizations to be fetched
#' @param HUC8 Optional vector of HUC8s to be fetched
#' @param HUC8_Name Optional vector of HUC8 names to be fetched
#' @param HUC10 Optional vector of HUC10s to be fetched
#' @param HUC12 Optional vector of HUC12s to be fetched
#' @param HUC12_Name Optional vector of HUC12 names to be fetched
#' @param filterQC If true, do not return MLocID 10000-ORDEQ or sample replicates
#' @return Dataframe of data from AWQMS
#' @examples
#' AWQMS_Data(startdate = '2017-1-1', enddate = '2000-12-31', station = c('10591-ORDEQ', '29542-ORDEQ'),
#' project = 'Total Maximum Daily Load Sampling', filterQC = FALSE)
#' @export
#'
#'

AWQMS_Data <- function(startdate = '1949-09-15', enddate = NULL, station = NULL,
                       project = NULL, char = NULL, stat_base = NULL,
                       media = NULL, org = NULL, HUC8 = NULL, HUC8_Name = NULL,
                       HUC10 = NULL, HUC12 = NULL,  HUC12_Name = NULL,
                       filterQC = TRUE) {

  if(missing(startdate)) {
    stop("Need to input startdate")
  }



  # Build base query language
  query <- "SELECT *
  FROM [awqms].[dbo].[VW_AWQMS_Results]
  WHERE SampleStartDate >= Convert(datetime, {startdate})"



  # Conditially add addional parameters

  # add end date
  if (length(enddate) > 0) {
    query = paste0(query, "\n AND SampleStartDate <= Convert(datetime, {enddate})" )
  }


  # station
  if (length(station) > 0) {

    query = paste0(query, "\n AND MLocID IN ({station*})")
  }

  #Project

  if (length(project) > 0) {
    query = paste0(query, "\n AND (Project1 in ({project*}) OR Project2 in ({project*})) ")

  }

  # characteristic
  if (length(char) > 0) {
    query = paste0(query, "\n AND Char_Name in ({char*}) ")

  }

  #statistical base
  if(length(stat_base) > 0){
    query = paste0(query, "\n AND Statistical_Base in ({stat_base*}) ")

  }

  # sample media
  if (length(media) > 0) {
    query = paste0(query, "\n AND SampleMedia in ({media*}) ")

  }

  # organization
  if (length(org) > 0){
    query = paste0(query,"\n AND OrganizationID in ({org*}) " )

  }

  #HUC8

  if(length(HUC8) > 0){
    query = paste0(query,"\n AND HUC8 in ({HUC8*}) " )

  }


  #HUC8_Name

  if(length(HUC8_Name) > 0){
    query = paste0(query,"\n AND HUC8_Name in ({HUC8_Name*}) " )

  }

  if(length(HUC10) > 0){
    query = paste0(query,"\n AND HUC10 in ({HUC10*}) " )

  }

  if(length(HUC12) > 0){
    query = paste0(query,"\n AND HUC12 in ({HUC12*}) " )

  }


  if(length(HUC12_Name) > 0){
    query = paste0(query,"\n AND HUC12_Name in ({HUC12_Name*}) " )

  }

  if(filterQC){
    query = paste0(query,"\n AND MLocID <> '10000-ORDEQ'
                   \n AND activity_type NOT LIKE 'Quality Control%'" )

  }

  #Connect to database
  con <- DBI::dbConnect(odbc::odbc(), "AWQMS")

  # Create query language
  qry <- glue::glue_sql(query, .con = con)

  #
  # Query the database
  data_fetch <- DBI::dbGetQuery(con, qry)


  # Disconnect
  DBI::dbDisconnect(con)

  return(data_fetch)

}
