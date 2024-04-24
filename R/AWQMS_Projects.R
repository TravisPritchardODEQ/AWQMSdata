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

  # Get environment variables
  readRenviron("~/.Renviron")
  assert_AWQMS()




  con <- DBI::dbConnect(odbc::odbc(), 'AWQMS-cloud',
                        UID      =   Sys.getenv('AWQMS_usr'),
                        PWD      =  Sys.getenv('AWQMS_pass'))

  project1 <- dplyr::tbl(con, 'results_deq_vw') |>
    dplyr::select(Project1) |>
    dplyr::distinct() |>
    dplyr::rename(Project = Project1) |>
    dplyr::collect()


  project2 <- dplyr::tbl(con, 'results_deq_vw') |>
    dplyr::select(Project2) |>
    dplyr::distinct() |>
    dplyr::rename(Project = Project2) |>
    dplyr::collect()



  DBI::dbDisconnect(con)


  projects <- rbind(project1, project2)

  projects <- unique(projects)



  return(projects)

}
