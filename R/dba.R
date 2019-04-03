basal_diameter <- function(x) {
  sqrt(sum(x^2, na.rm = TRUE))
}

contribution_to_basal_area <- function(x) {
  basal_area(x) / sum(basal_area(x), na.rm = TRUE)
}

basal_area <- function(dbh) {
  pi / 4 * dbh^2
}
