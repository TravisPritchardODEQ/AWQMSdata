# Check if AWQMS_SERVER is stored
assert_AWQMS <- function() { # nolint start
  assertthat::assert_that(Sys.getenv("AWQMS_SERVER") != "",
                          msg = "You need to register the AWQMS and SERVER database addresses using the\n'AWQMS_set_servers()' function."
  )
}

# Check if STATIONS_SERVER is stored
assert_STATIONS <- function() { # nolint start
  assertthat::assert_that(Sys.getenv("STATIONS_SERVER") != "",
                          msg = "You need to register the AWQMS and SERVER database addresses using the\n'AWQMS_set_servers()' function."
  )
}

