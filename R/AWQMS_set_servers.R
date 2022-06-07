#' Install AWQMS and the server database addresses in your `.Renviron` file for repeated use
#'
#' @description This function adds AWQMS and the server database addresses to your
#' `.Renviron` file so it can be called securely without being stored in
#' your code. After you have installed these two credentials, they can be
#' called any time with `Sys.getenv("AWQMS_SERVER")` or
#' `Sys.getenv("STATIONS_SERVER")`. If you do not have an
#' `.Renviron` file, the function will create one for you. If you already
#' have an `.Renviron` file, the function will append the key to your
#' existing file, while making a backup of your original file for disaster
#' recovery purposes. The point of this function is to not put SQL server address in public
#' spaces such as github. The parameters used in the function MUST be kept secret.
#' This code was very heavily borrowed from qualtRics by Julia Silge and Jasper Ginn
#' @param AWQMS_SERVER The first three brackets of the AWQMS server address formatted in quotes. must end with .
#' Example [SERVER].[database_name].[dbo].
#' @param STATIONS_SERVER The first three brackets of the STATIONS server address formatted in quotes. must end with .
#' Example [SERVER].[database_name].[dbo].
#' @param install If TRUE, will install the key in your `.Renviron` file
#' for use in future sessions.
#' @param overwrite If TRUE, will overwrite existing Qualtrics
#' credentials that you already have in your `.Renviron` file.
#' @examples
#'
#' \dontrun{
#' AWQMS_set_servers(
#'   AWQMS_SERVER = "[SERVER].[database_name].[dbo].",
#'   STATIONS_SERVER = "[SERVER].[database_name].[dbo].",
#'   install = TRUE
#' )
#' # Reload your environment so you can use the credentials without restarting R
#' readRenviron("~/.Renviron")
#' # You can check it with:
#' Sys.getenv("AWQMS_SERVER")
#'
#' # If you need to overwrite existing credentials:
#' AWQMS_set_servers(
#'   AWQMS_SERVER = "[SERVER].[database_name].[dbo].",
#'   STATIONS_SERVER = "[SERVER].[database_name].[dbo].",
#'   overwrite = TRUE,
#'   install = TRUE
#' )
#' # Reload your environment to use the credentials
#' }
#' @export


AWQMS_set_servers <- function(AWQMS_SERVER, STATIONS_SERVER,
                               overwrite = FALSE,
                               install = TRUE){

  if (install) {
    home <- Sys.getenv("HOME")
    renv <- file.path(home, ".Renviron")
    if (file.exists(renv)) {
      # Backup original .Renviron before doing anything else here.
      file.copy(renv, file.path(home, ".Renviron_backup"))
    }
    if (!file.exists(renv)) {
      file.create(renv)
    }
    else {
      if (isTRUE(overwrite)) {
        message("Your original .Renviron will be backed up and stored in your R HOME directory if needed.")
        oldenv <- readLines(renv)
        newenv <- oldenv[-grep("AWQMS_SERVER|STATIONS_SERVER", oldenv)]
        writeLines(newenv, renv)
      }
      else {
        tv <- readLines(renv)
        if (any(grepl("AWQMS_SERVER|STATIONS_SERVER", tv))) {
          stop("Server Addresses already exist. You can overwrite them with the argument overwrite=TRUE", call. = FALSE)
        }
      }
    }

    AWQMSconcat <- paste0("AWQMS_SERVER = '", AWQMS_SERVER, "'")
    Stationsconcat <- paste0("STATIONS_SERVER = '", STATIONS_SERVER, "'")
    # Append credentials to .Renviron file
    write(AWQMSconcat, renv, sep = "\n", append = TRUE)
    write(Stationsconcat, renv, sep = "\n", append = TRUE)
    message('The server addresses have been stored in your .Renviron.  \nTo use now, restart R or run `readRenviron("~/.Renviron")`')
  } else {
    message("To install the addresses for use in future sessions, run this function with `install = TRUE`.")
    Sys.setenv(
      AWQMS_SERVER = AWQMS_SERVER,
      STATIONS_SERVER = STATIONS_SERVER
    )
  }
}


