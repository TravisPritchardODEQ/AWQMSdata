#' CuBLM
#'
#' A function that converts data from AWQMS long table format into the wide table format that
#  is used by the copper BLM model and the NPDES Copper BLM templates. Ancillary data is
#' the first data found in the calendar day. This is the same method used in 2018IR
#' Written by Aliana Britson
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
  y<-subset(x,x$Char_Name %in% char & is.na(x$Statistical_Base)) #&

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

  ancillary<-subset(ancillary,select=c("Char_Name","Result","date","OrganizationID","MLocID", "Project1"))


  ancillary <- ancillary %>%
    dplyr::group_by(Char_Name, date, OrganizationID, MLocID,Project1) %>%
    dplyr::summarise(Result = dplyr::first(Result)) %>%
    dplyr::ungroup() %>%
    tidyr::spread(key = Char_Name, value =Result )


  Copper <- y[grepl("Copper", y$Char_Name), ]



  Copper<-subset(Copper,select=c("OrganizationID","Project1", "MLocID",  "SampleStartDate","SampleStartTime", "Char_Name","Result"))

  Copper_joined <- Copper %>%
    dplyr::mutate(date = as.Date(SampleStartDate)) %>%
    dplyr::left_join(ancillary, by = c('date', 'OrganizationID', 'MLocID',  "Project1"))

  return(Copper_joined)
}




