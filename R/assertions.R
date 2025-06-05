# Check if AWQMS_SERVER is stored
assert_AWQMS <- function() { # nolint start
  assertthat::assert_that(Sys.getenv("AWQMS_pass") != "",
                          msg = "You need to register the AWQMS password using the\n'AWQMSdata::AWQMS_credentials()' function. See installation document."
  )
}

# Check if STATIONS_SERVER is stored
assert_STATIONS <- function() { # nolint start
  assertthat::assert_that(Sys.getenv("STATIONS_SERVER") != "",
                          msg = "You need to register STATIONS SERVER database addresses using the\n'AWQMS_set_password()' function. See installation document."
  )
}


