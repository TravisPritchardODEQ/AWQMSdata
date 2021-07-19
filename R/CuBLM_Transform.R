#' CuBLM
#'
#' A function that converts data from AWQMS long table format into the wide table format that
#' is used by the copper BLM model and the NPDES Copper BLM templates. Ancillary data is
#' the first data found in the calendar day. This is the same method used in 2018IR.
#'
#' Output includes the method detection and method reporting limit for Copper, as well as result
#' value and also the "Result_Type" for each characteristic so that
#' user can better judge the quality of the data. This function does not return data that has
#' a "Rejected" status in AWQMS.
#'
#' Written by Aliana Britson, some modifications by Travis Pritchard
#'
#' @param x table output from AWQMS query
#' @return Dataframe with input file for BLM
#' @importFrom magrittr "%>%"
#' @export
#'
#'


CuBLM <- function(x) {
  #x is table output from AWQMS query

  #Remove rejected data
  x <- x[x$Result_status != 'Rejected',]

  #Need to check units and make sure they are converted properly
  x <- AWQMSdata::unit_conv(x,"Temperature, water","deg F","deg C")
  x <- AWQMSdata::unit_conv(x,c("Calcium","Chloride","Magnesium","Potassium","Sodium","Sulfate","Organic carbon","Total Sulfate","Sulfide"),"ug/l","mg/l")
  x <- AWQMSdata::unit_conv(x,"Copper","mg/l","ug/l")


  # Analytes of interest for Copper BLM
  char<-c("Alkalinity, total","Calcium","Chloride","Copper","Magnesium","pH","Potassium","Sodium","Sulfate","Organic carbon",
          "Temperature, water","Total Sulfate","Sulfide","Salinity","Conductivity")

  #Only want to keep analytes of interest, and remove any samples that are calculated from continuous data (eg. 7 day min)
  y<-subset(x,x$Char_Name %in% char & is.na(x$Statistical_Base))

  #there were some special projects at one point that looked at "dissolved alkalinity" in Oregon DEQ data
  #what they did was take two samples, one was filtered (dissolved alkalinity) and the other one wasn't (total alkalinity)
  #usually alkalinity is taken on a non-filtered sample, so we shall remove the "dissolved alkalinity" samples, but just for DEQ,
  #some NPDES permittees have been measuring alkalinity off of a filtered sample as part of their Copper BLM monitoring
  y<-subset(y,!(y$Char_Name=="Alkalinity, total" & y$Sample_Fraction=="Dissolved" & y$OrganizationID=='OREGONDEQ'))

  #combine name and sample fraction, otherwise we get a bunch of rows we don't need
  #interested in whether an analyte is Total Recoverable or Dissolved, and only for metals
  #can leave out the other Sample Fractions
  y$Char_Name<-
    dplyr::case_when(y$Char_Name %in% c("Calcium","Copper","Magnesium","Potassium","Sodium","Organic carbon")
                     ~paste0(y$Char_Name,",",y$Sample_Fraction),
                     y$Char_Name %in% c("Alkalinity, total","Chloride","pH","Sulfate","Temperature, water","Total Sulfate","Sulfide","Salinity","Conductivity")
                     ~y$Char_Name)

  # Get only ancillary data
  ancillary <- y[!grepl("Copper", y$Char_Name), ]
  #Set date
  ancillary$date <- as.Date(ancillary$SampleStartDate)

  ancillary<-subset(ancillary,select=c("Char_Name","Result_Text","date","OrganizationID","MLocID", "Project1","Result_Type"))

  type<-subset(ancillary,select=c("Char_Name","date","OrganizationID","MLocID", "Project1","Result_Type"))

  #get ancillary data into wide table format
  ancillary <- ancillary %>%
    dplyr::group_by(Char_Name, date, OrganizationID, MLocID,Project1) %>%
    dplyr::summarise(Result_Text = dplyr::first(Result_Text)) %>%
    dplyr::ungroup() %>%
    tidyr::spread(key = Char_Name, value =Result_Text )

  #get result type data into wide table format
  type<- type %>%
    dplyr::group_by(Char_Name, date, OrganizationID, MLocID,Project1) %>%
    dplyr::summarise(Result_Type = dplyr::first(Result_Type)) %>%
    dplyr::ungroup() %>%
    tidyr::spread(key = Char_Name, value =Result_Type )

  Copper <- y[grepl("Copper", y$Char_Name), ]



  Copper<-subset(Copper,select=c("OrganizationID","Project1", "MLocID",  "SampleStartDate","SampleStartTime", "Char_Name","Result_Text","MDLValue",
                                 "MRLValue","Result_Type"))

  Copper_joined <- Copper %>%
    dplyr::mutate(date = as.Date(SampleStartDate)) %>%
    dplyr::left_join(ancillary, by = c('date', 'OrganizationID', 'MLocID',  "Project1")) %>%
    dplyr::left_join(type, by = c('date', 'OrganizationID', 'MLocID',  "Project1"))

  #column names are a bit weird now, rename a bit
  names(Copper_joined)<-stringr::str_replace(names(Copper_joined),"\\.x","")
  names(Copper_joined)<-stringr::str_replace(names(Copper_joined),"\\.y"," Result_Type")

  return(Copper_joined)
}

#library(AWQMSdata)
#library(tidyverse)
#x<-AWQMS_Data(startdate='2019-12-02',enddate='2019-12-02')


