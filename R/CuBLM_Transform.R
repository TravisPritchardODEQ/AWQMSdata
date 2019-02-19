#' CuBLM
#'
#' A function that converts data from AWQMS long table format into the wide table format that
#  is used by the copper BLM model and the NPDES Copper BLM templates. if you get warnings with
#' res saying that multiple rows match, look for duplicates in data. Written by Aliana Britson
#'
#' @param x table output from AWQMS query
#' @return Dataframe with input file for BLM
#' @export
#'
#'

CuBLM<-function(x) {
  #x is table output from AWQMS query

  #Remove rejected data
  x <- x[x$Result_status != 'Rejected',]

  #Need to check units and make sure they are converted properly
  x<-unit_conv(x,"Temperature, water","deg F","deg C")
  x<-unit_conv(x,c("Calcium","Chloride","Magnesium","Potassium","Sodium","Sulfate","Organic carbon","Total Sulfate","Sulfide"),"ug/l","mg/l")
  x<-unit_conv(x,"Copper","mg/l","ug/l")


  # Analytes of interest for Copper BLM
  char<-c("Alkalinity, total","Calcium","Chloride","Copper","Magnesium","pH","Potassium","Sodium","Sulfate","Organic carbon",
          "Temperature, water","Total Sulfate","Sulfide","Salinity","Conductivity")

  #Only want to keep analytes of interest, and remove any samples that are calculated from continuous data (eg. 7 day min)
  y<-subset(x,x$Char_Name %in% char & is.na(x$Statistical_Base)) #&

  #combine name and sample fraction, otherwise we get a bunch of rows we don't need
  #mostly interested in whether an analyte is Total Recoverable or Dissolved, and only for metals
  #can leave out the other Sample Fractions
  y$Char_Name<-
    dplyr::case_when(y$Char_Name %in% c("Calcium","Copper","Magnesium","Potassium","Sodium","Organic carbon")
              ~paste0(y$Char_Name,",",y$Sample_Fraction),
              y$Char_Name %in% c("Alkalinity, total","Chloride","pH","Sulfate","Temperature, water","Total Sulfate","Sulfide","Salinity","Conductivity")
              ~y$Char_Name)


  #just want a subset of the columns, too many columns makes reshape very complicated
  x<-subset(y,select=c("Char_Name","Result_Numeric","SampleStartDate","SampleStartTime","OrganizationID","MLocID","Project1"))

  colnames(x) <- c("Char_Name","Result","SampleStartDate","SampleStartTime","OrganizationID","MLocID","Project1")

  res<-reshape(x, timevar="Char_Name",
               idvar=c("MLocID","SampleStartDate","SampleStartTime","OrganizationID","Project1"),
               direction="wide")

  #note, if you get warnings with res saying that multiple rows match, look for duplicates in data

  return(res)
}



