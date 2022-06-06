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
  function(startdate = '1949-09-15',
           enddate = NULL,
           station = NULL,
           AU_ID = NULL,
           char = NULL,
           media = NULL,
           org = NULL,
           HUC8 = NULL,
           HUC8_Name = NULL,
           HUC10 = NULL,
           HUC12 = NULL,
           HUC12_Name = NULL,
           Result_Status = NULL,
           crit_codes = FALSE
  ) {

    AWQMS_server <- Sys.getenv('AWQMS_SERVER')
    Stations_server <- Sys.getenv('STATIONS_SERVER')

  if(crit_codes == TRUE){
    query <- paste0("SELECT a.*
  ,s.FishCode
  ,s.SpawnCode
  ,s.WaterTypeCode
  ,s.WaterBodyCode
  ,s.BacteriaCode
  ,s.DO_code
  ,s.ben_use_code
  ,s.pH_code
  ,s.DO_SpawnCode
  FROM  ",AWQMS_server,"[VW_AWQMS_Cont_Results] a
  LEFT JOIN ", Stations_server,"[VWStationsFinal] s ON a.MLocID = s.MLocID
  WHERE Result_Date >= Convert(datetime, {startdate})")
  } else {
    query <- paste0("SELECT a.*
  FROM  ",AWQMS_server,"[VW_AWQMS_Cont_Results] a
  WHERE Result_Date >= Convert(datetime, {startdate})")

  }


  # add end date
  if (length(enddate) > 0) {
    query = paste0(query, "\n AND a.Result_Date <= Convert(datetime, {enddate})" )
  }


  # station
  if (length(station) > 0) {

    query = paste0(query, "\n AND a.MLocID IN ({station*})")
  }

  # AU
  if (length(AU_ID) > 0) {

    query = paste0(query, "\n AND a.AU_ID IN ({AU_ID*})")
  }



  # characteristic
  if (length(char) > 0) {
    query = paste0(query, "\n AND a.Char_Name in ({char*}) ")

  }


  # sample media
  if (length(media) > 0) {
    query = paste0(query, "\n AND a.SampleMedia in ({media*}) ")

  }

  # organization
  if (length(org) > 0){
    query = paste0(query,"\n AND a.OrganizationID in ({org*}) " )

  }

  #HUC8

  if(length(HUC8) > 0){
    query = paste0(query,"\n AND a.HUC8 in ({HUC8*}) " )

  }


  #HUC8_Name

  if(length(HUC8_Name) > 0){
    query = paste0(query,"\n AND a.HUC8_Name in ({HUC8_Name*}) " )

  }

  if(length(HUC10) > 0){
    query = paste0(query,"\n AND a.HUC10 in ({HUC10*}) " )

  }

  if(length(HUC12) > 0){
    query = paste0(query,"\n AND a.HUC12 in ({HUC12*}) " )

  }


  if(length(HUC12_Name) > 0){
    query = paste0(query,"\n AND a.HUC12_Name in ({HUC12_Name*}) " )

  }

    if(length(Result_Status) > 0){
      query = paste0(query,"\n AND a.Result_Status in ({Result_Status*}) " )

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


