#' AWQMS_Data
#'
#' This function will retrive data from OregonDEQ AWQMS
#' @param startdate Required parameter setting the startdate of the data being fetched. Format 'yyyy-mm-dd'
#' @param enddate Optional parameter setting the enddate of the data being fetched. Format 'yyyy-mm-dd'
#' @param station Optional vector of stations to be fetched
#' @param AU_ID Optional vector of Assessment Units to be fetched
#' @param project Optional vector of projects to be fetched
#' @param char Optional vector of characteristics to be fetched
#' @param casnumber Optional vector of CAS numbers to be fetched
#' @param stat_base Optional vector of Result Stattistical Bases to be fetched ex. Maximum
#' @param media Optional vector of sample media to be fetched
#' @param org optional vector of Organizations to be fetched
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
#' AWQMS_Data(startdate = '2017-1-1', enddate = '2000-12-31', station = c('10591-ORDEQ', '29542-ORDEQ'),
#' project = 'Total Maximum Daily Load Sampling', filterQC = FALSE, crit_codes = FALSE)
#' @export
#'
#'


AWQMS_Data <-
  function(startdate = '1949-09-15',
           enddate = NULL,
           station = NULL,
           AU_ID = NULL,
           project = NULL,
           char = NULL,
           casnumber = NULL,
           stat_base = NULL,
           media = NULL,
           submedia = NULL,
           org = NULL,
           HUC8 = NULL,
           HUC8_Name = NULL,
           HUC10 = NULL,
           HUC12 = NULL,
           HUC12_Name = NULL,
           crit_codes = FALSE,
           filterQC = TRUE,
           return_query = FALSE) {



    #testing
    # startdate = '1949-09-15'
    # enddate = NULL
    # station = c('30143-ORDEQ', '30147-ORDEQ')
    # AU_ID = NULL
    # project = NULL
    # char = c('Temperature, water')
    # stat_base = NULL
    # media = NULL
    # submedia = NULL
    # org = NULL
    # HUC8 = NULL
    # HUC8_Name = NULL
    # HUC10 = NULL
    # HUC12 = NULL
    # HUC12_Name = NULL
    # crit_codes = FALSE
    # filterQC = TRUE



    # Get environment variables
    readRenviron("~/.Renviron")
    assert_STATIONS()
    assert_AWQMS()

    AWQMS_server <- Sys.getenv('AWQMS_SERVER')
    Stations_server <- Sys.getenv('STATIONS_SERVER')


     # Build base query language
  if(crit_codes == TRUE){
query <- paste0("SELECT a.[OrganizationID]
, a.[Org_Name]
, a.[Project1]
, a.[Project2]
, a.[Project3]
, a.[MLocID]
, a.[StationDes]
, a.[MonLocType]
, a.[EcoRegion3]
, a.[EcoRegion4]
, a.[HUC8]
, a.[HUC8_Name]
, a.[HUC10]
, a.[HUC12]
, a.[HUC12_Name]
, a.[Lat_DD]
, a.[Long_DD]
, a.[Reachcode]
, a.[Measure]
, a.[AU_ID]
, a.[act_id]
, a.[Activity_Type]
, a.[SampleStartDate]
, cast(a.[SampleStartTime] AS time(0)) as [SampleStartTime]
, a.[SampleStartTZ]
, a.[SampleMedia]
, a.[SampleSubmedia]
, a.[SamplingMethod]
, a.[chr_uid]
, a.[Char_Name]
, a.[Char_Speciation]
, a.[Sample_Fraction]
, a.[CASNumber]
, a.[Result_UID]
, a.[Result_status]
, a.[Result_Type]
, a.[Result_Text]
, a.[Result_Numeric]
, a.[Result_Operator]
, a.[Result_Unit]
, a.[Unit_UID]
, a.[ResultCondName]
, a.[RelativeDepth]
, a.[Result_Depth]
, a.[Result_Depth_Unit]
, a.[Result_Depth_Reference]
, a.[act_depth_height]
, a.[ActDepthUnit]
, a.[Act_depth_Reference]
, a.[Act_Depth_Top]
, a.[Act_Depth_Top_Unit]
, a.[Act_Depth_Bottom]
, a.[Act_Depth_Bottom_Unit]
, a.[Time_Basis]
, a.[Statistical_Base]
, a.[Statistic_N_Value]
, a.[act_sam_compnt_name]
, a.[stant_name]
, a.[Bio_Intent]
, a.[Taxonomic_Name]
, a.[Analytical_method]
, a.[Method_Code]
, a.[Method_Context]
, a.[Analytical_Lab]
, a.[Activity_Comment]
, a.[Result_Comment]
, a.[DQL]
, a.[QualifierAbbr]
, a.[QualifierTxt]
, a.[IDLType]
, a.[IDLValue]
, a.[IDLUnit]
, a.[MDLType]
, a.[MDLValue]
, a.[MDLUnit]
, a.[MRLType]
, a.[MRLValue]
, a.[MRLUnit]
, a.[URLType]
, a.[URLValue]
, a.[URLUnit]
, a.[WQX_submit_date]
  ,s.FishCode
  ,s.SpawnCode
  ,s.WaterTypeCode
  ,s.WaterBodyCode
  ,s.BacteriaCode
  ,s.DO_code
  ,s.ben_use_code
  ,s.pH_code
  ,s.DO_SpawnCode
  FROM  ",AWQMS_server,"[VW_AWQMS_Results] a
  LEFT JOIN ", Stations_server,"[VWStationsFinal] s ON a.MLocID = s.MLocID
  WHERE SampleStartDate >= Convert(datetime, {startdate})")
} else {
  query <- paste0("SELECT a.[OrganizationID]
, a.[Org_Name]
, a.[Project1]
, a.[Project2]
, a.[Project3]
, a.[MLocID]
, a.[StationDes]
, a.[MonLocType]
, a.[EcoRegion3]
, a.[EcoRegion4]
, a.[HUC8]
, a.[HUC8_Name]
, a.[HUC10]
, a.[HUC12]
, a.[HUC12_Name]
, a.[Lat_DD]
, a.[Long_DD]
, a.[Reachcode]
, a.[Measure]
, a.[AU_ID]
, a.[act_id]
, a.[Activity_Type]
, a.[SampleStartDate]
, cast(a.[SampleStartTime] AS time(0)) as [SampleStartTime]
, a.[SampleStartTZ]
, a.[SampleMedia]
, a.[SampleSubmedia]
, a.[SamplingMethod]
, a.[chr_uid]
, a.[Char_Name]
, a.[Char_Speciation]
, a.[Sample_Fraction]
, a.[CASNumber]
, a.[Result_UID]
, a.[Result_status]
, a.[Result_Type]
, a.[Result_Text]
, a.[Result_Numeric]
, a.[Result_Operator]
, a.[Result_Unit]
, a.[Unit_UID]
, a.[ResultCondName]
, a.[RelativeDepth]
, a.[Result_Depth]
, a.[Result_Depth_Unit]
, a.[Result_Depth_Reference]
, a.[act_depth_height]
, a.[ActDepthUnit]
, a.[Act_depth_Reference]
, a.[Act_Depth_Top]
, a.[Act_Depth_Top_Unit]
, a.[Act_Depth_Bottom]
, a.[Act_Depth_Bottom_Unit]
, a.[Time_Basis]
, a.[Statistical_Base]
, a.[Statistic_N_Value]
, a.[act_sam_compnt_name]
, a.[stant_name]
, a.[Bio_Intent]
, a.[Taxonomic_Name]
, a.[Analytical_method]
, a.[Method_Code]
, a.[Method_Context]
, a.[Analytical_Lab]
, a.[Activity_Comment]
, a.[Result_Comment]
, a.[DQL]
, a.[QualifierAbbr]
, a.[QualifierTxt]
, a.[IDLType]
, a.[IDLValue]
, a.[IDLUnit]
, a.[MDLType]
, a.[MDLValue]
, a.[MDLUnit]
, a.[MRLType]
, a.[MRLValue]
, a.[MRLUnit]
, a.[URLType]
, a.[URLValue]
, a.[URLUnit]
, a.[WQX_submit_date]
FROM  ",AWQMS_server,"[VW_AWQMS_Results] a
  WHERE SampleStartDate >= Convert(datetime, {startdate})")

}

  # Conditially add addional parameters

  # add end date
  if (length(enddate) > 0) {
    query = paste0(query, "\n AND a.SampleStartDate <= Convert(datetime, {enddate})" )
  }


  # station
  if (length(station) > 0) {

    query = paste0(query, "\n AND a.MLocID IN ({station*})")
  }

    # AU
    if (length(AU_ID) > 0) {

      query = paste0(query, "\n AND a.AU_ID IN ({AU_ID*})")
    }


  #Project

  if (length(project) > 0) {
    query = paste0(query, "\n AND (a.Project1 in ({project*}) OR a.Project2 in ({project*})) ")

  }

  # characteristic
  if (length(char) > 0) {
    query = paste0(query, "\n AND a.Char_Name in ({char*}) ")

  }

    # CAS number
    if (length(casnumber) > 0) {
      query = paste0(query, "\n AND a.CASNumber in ({casnumber*}) ")

    }

  #statistical base
  if(length(stat_base) > 0){
    query = paste0(query, "\n AND a.Statistical_Base in ({stat_base*}) ")

  }

  # sample media
  if (length(media) > 0) {
    query = paste0(query, "\n AND a.SampleMedia in ({media*}) ")

  }


    # sample submedia
    if (length(submedia) > 0) {
      query = paste0(query, "\n AND a.SampleSubmedia in ({submedia*}) ")

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

  if(filterQC){
    query = paste0(query,"\n AND a.MLocID <> '10000-ORDEQ'
                   \n AND a.activity_type NOT LIKE 'Quality Control%'" )

  }

  #Connect to database
  con <- DBI::dbConnect(odbc::odbc(), "AWQMS")

  # Create query language
  qry <- glue::glue_sql(query, .con = con)


  if(return_query){
    data_fetch <- qry

  } else {

  # Query the database
  data_fetch <- DBI::dbGetQuery(con, qry)


  # Disconnect
  DBI::dbDisconnect(con)
}
  return(data_fetch)

}
