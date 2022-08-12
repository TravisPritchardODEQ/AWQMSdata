#' AWQMS_Raw_Macros
#'
#' Thus function will retrieve raw macroinvertebrate data from Oregon DEQ AWQMS
#' @param startdate Required parameter setting the startdate of the data being fetched. Format 'yyyy-mm-dd'. Defaults to
#' '1949-09-15'
#' @param enddate Optional parameter setting the enddate of the data being fetched. Format 'yyyy-mm-dd'
#' @param station Optional vector of stations to be fetched
#' @param AU_ID Optional vector of Assessment Units to be fetched
#' @param project Optional vector of projects to be fetched
#' @param org optional vector of Organizations to be fetched
#' @param Wade_Boat option for filtering wadeable or boat samples. Options are: 'wadeable', 'boatable', or NULL.
#' @param ReferenceSite filter for reference or non reference streams. Options are: NULL, '<Null>', 'YES', 'Not Loaded',
#' "".
#'@param HUC8 Optional vector of HUC8s to be fetched
#' @param HUC8_Name Optional vector of HUC8 names to be fetched
#' @param HUC10 Optional vector of HUC10s to be fetched
#' @param HUC12 Optional vector of HUC12s to be fetched
#' @param HUC12_Name Optional vector of HUC12 names to be fetched
#' @param Char_Name Optional vector or characteristic names. Options are: 'Count', 'Density'
#' @param Bio_Intent Optional vector or Bio_intent. Options are: 'Population Census', 'Species Density'
#' @param Taxonomic_Name Optional vector of taxa
#' @param StageID Optional vector of stages. Options are: NULL, 'Adult', 'Larva', 'Pupa'
#' @param UniqueTaxon Optioal vector. Options are: 'UniqueTaxon', 'AmbiguousTaxon'
#' @param return_query If FALSE, fetches data from AWQMS. If TRUE, returns string of query language.
#' @return Dataframe of data from AWQMS
#' @export


AWQMS_Raw_Macros <-
  function(startdate = '1949-09-15',
           enddate = NULL,
           station = NULL,
           AU_ID = NULL,
           project = NULL,
           org = NULL,
           Wade_Boat = NULL,
           ReferenceSite = NULL,
           HUC8 = NULL,
           HUC8_Name = NULL,
           HUC10 = NULL,
           HUC12 = NULL,
           HUC12_Name = NULL,
           Char_Name = NULL,
           Bio_Intent = NULL,
           Taxonomic_Name = NULL,
           StageID = NULL,
           UniqueTaxon = NULL,
           Analytical_method = NULL,
           return_query = FALSE,

           ){



# Error checking --------------------------------------------------------------------------------------------


    if(!(is.character(HUC8) | is.null(HUC8))){

      stop('HUC8 value must be a character')
    }

    if(!(is.character(HUC10) | is.null(HUC10))){

      stop('HUC10 value must be a character')
    }

    if(!(is.character(HUC12) | is.null(HUC12))){

      stop('HUC12 value must be a character')
    }



# Build base query language ---------------------------------------------------------------------------------------


## Get environment variables ----------------------------------------------------------------------------------------



    # Get environment variables
    readRenviron("~/.Renviron")
    assert_STATIONS()
    assert_AWQMS()

    AWQMS_server <- Sys.getenv('AWQMS_SERVER')
    Stations_server <- Sys.getenv('STATIONS_SERVER')


## Build base query language ---------------------------------------------------------------------------------------

    query <- paste0("SELECT [org_id]
      ,[Project1]
      ,[Project2]
      ,[MLocID]
      ,[StationDes]
      ,[MonLocType]
      ,[EcoRegion3]
      ,[EcoRegion4]
      ,[EcoRegion2]
      ,[HUC8]
      ,[HUC8_Name]
      ,[HUC10]
      ,[HUC12]
      ,[HUC12_Name]
      ,[Lat_DD]
      ,[Long_DD]
      ,[Reachcode]
      ,[Measure]
      ,[AU_ID]
      ,[ELEV_Ft]
      ,[GNIS_Name]
      ,[Conf_Score]
      ,[QC_Comm]
      ,[COMID]
      ,[precip_mm]
      ,[temp_Cx10]
      ,[Predator_WorE]
      ,[ReferenceSite]
      ,[act_id]
      ,[act_comments]
      ,[Activity_Type]
      ,[SampleStart_Date]
      ,[SampleStart_Time]
      ,[Sample_Media]
      ,[Sample_Method]
      ,[Assemblage]
      ,[chr_uid]
      ,[Char_Name]
      ,[Result_UID]
      ,[Result_Status]
      ,[Result_Numeric]
      ,[Result_Unit]
      ,[Bio_Intent]
      ,[Taxonomic_Name]
      ,[tax_uid]
      ,[DEQ_Taxon]
      ,[StageID]
      ,[UniqueTaxon]
      ,[Analytical_method]
      ,[Result_Comments]
      ,[DQL]
      ,[Result_Qualifier_Code]
      ,[Result_Qualifier_Description]
      ,[WQX_submit_date]
      ,[Wade_Boat]
        FROM  ",AWQMS_server,"[VW_Raw_Macros]
          WHERE SampleStart_Date >= Convert(datetime, {startdate})")


# Conditionally add additional parameters -----------------------------------------------------------------------------

    # add end date
    if (length(enddate) > 0) {
      query = paste0(query, "\n AND SampleStart_Date <= Convert(datetime, {enddate})" )
    }


    # station
    if (length(station) > 0) {

      query = paste0(query, "\n AND MLocID IN ({station*})")
    }

    # AU
    if (length(AU_ID) > 0) {

      query = paste0(query, "\n AND AU_ID IN ({AU_ID*})")
    }


    #Project

    if (length(project) > 0) {
      query = paste0(query, "\n AND (Project1 in ({project*}) OR Project2 in ({project*})) ")

    }

    # organization
    if (length(org) > 0){
      query = paste0(query,"\n AND OrganizationID in ({org*}) " )

    }
    #HUCs

    if(length(HUC8) > 0){
      query = paste0(query,"\n AND HUC8 in ({HUC8*}) " )

    }



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

  #wade or boat
    if(length(Wade_Boat ) > 0){
      query = paste0(query,"\n AND Wade_Boatin ({Wade_Boat*}) " )

    }

    #reference

    if(length(ReferenceSite) > 0){
      query = paste0(query,"\n AND ReferenceSite in ({ReferenceSite*}) " )

    }

    #Bio_Intent

    if(length(Bio_Intent) > 0){
      query = paste0(query,"\n AND Bio_Intent in ({Bio_Intent*}) " )

    }

    #taxa
    if(length(Taxonomic_Name) > 0){
      query = paste0(query,"\n AND Taxonomic_Name in ({Taxonomic_Name*}) " )

    }

    #stage
    if(length(StageID) > 0){
      query = paste0(query,"\n AND StageID in ({StageID*}) " )

    }

    #unique taxa
    if(length(UniqueTaxon) > 0){
      query = paste0(query,"\n AND UniqueTaxon in ({UniqueTaxon*}) " )

    }


    #analytical method
    if(length(Analytical_method) > 0){
      query = paste0(query,"\n AND Analytical_method in ({Analytical_method*}) " )

    }

    #characteristic
    if(length(Char_Name) > 0){
      query = paste0(query,"\n AND Char_Name in ({Char_Name*}) " )

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



