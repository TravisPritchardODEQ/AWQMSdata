#' AWQMS_Projects
#'
#' This function will create a vector or projects from AWQMS Project1, project2, and project3 columns.
#'
#' @export
#' @return Dataframe of projects in AWQMS
#' @examples
#' AWQMS_Projects()
#'
#'
AWQMS_Projects <- function() {

#Connect to database
con <- DBI::dbConnect(odbc::odbc(), "AWQMS")

project1 <- DBI::dbGetQuery(con, "SELECT DISTINCT       Project1 AS 'Project'
                               FROM            [deqlead-lims\\awqms].[awqms].[dbo].[VW_AWQMS_Results]")

project2 <- DBI::dbGetQuery(con, "SELECT DISTINCT       Project2 AS 'Project'
                               FROM            [deqlead-lims\\awqms].[awqms].[dbo].[VW_AWQMS_Results]")

#project3 <- dbGetQuery(con, "SELECT DISTINCT       Project3 AS 'Project'
#                             FROM            [deqlead-lims\\awqms].[awqms].[dbo].[VW_AWQMS_Results]")


DBI::dbDisconnect(con)


projects <- rbind(project1, project2)

projects <- unique(projects)



return(projects)

}
