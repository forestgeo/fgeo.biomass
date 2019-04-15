propagete_errors <- function(data, n = 1000) {
  out <- BIOMASS::AGBmonteCarlo(
    n = n,
    D = data$dbh,
    WD = data$wd_mean,
    errWD = data$wd_sd,
    coord = data[c("latitude", "longitude")]
  )
  out
}

