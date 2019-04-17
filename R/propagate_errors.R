propagete_errors <- function(data,
                             n = 1000,
                             dbh_sd = NULL,
                             height_model = NULL) {
  check_crucial_names(data, c("dbh", "wd_mean", "wd_sd"))

  use_coordinates <- FALSE
  if (is.null(height_model) &&
      suppressWarnings(has_coordinates(data$latitude, data$longitude))) {
    use_coordinates <- TRUE
  }

  use_model <- FALSE
  if (!is.null(height_model) &&
      !suppressWarnings(has_coordinates(data$latitude, data$longitude))) {
    use_model <- TRUE
  }

  if (!is.null(height_model) &&
      suppressWarnings(has_coordinates(data$latitude, data$longitude))) {
    usethis::ui_yeah(
      "Either coordinates or a height-diameter model can be used.
      Okay to ignore coordinates in your data? (If not, use \\
      {ui_code('height_model = NULL')})"
    )
    use_model <- TRUE
  }

  if (use_coordinates) {
    check_crucial_names(data, c("wd_mean", "wd_sd", "latitude", "longitude"))
    out <- BIOMASS::AGBmonteCarlo(
      n = n,
      D = data$dbh,
      WD = data$wd_mean,
      errWD = data$wd_sd,
      coord = data[c("longitude", "latitude")],
      Dpropag = dbh_sd
    )
  }

  if (use_model) {
    if (!identical(length(height_model$method), 1L)) {
      ui_stop(
        "{ui_code('height_model')} must have only 1 method (found: \\
         {glue_collapse(height_model$method, sep = ', ')})."
      )
    }

    out <- BIOMASS::AGBmonteCarlo(
      n = n,
      D = data$dbh,
      WD = data$wd_mean,
      errWD = data$wd_sd,
      HDmodel = height_model,
      Dpropag = dbh_sd
    )
  }

  if (all(is.na(out$AGB_simu))) {
    ui_warn("Invalid simulations")
  }

  out
}

