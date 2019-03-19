#' Construct S3 objects of class "eqn".
#'
#' @param data A dataframe with the columns shown in the example.
#'
#' @return A dataframe of subclass "eqn".
#' @export
#'
#' @examples
#' # `as_eqn()` checks that the structure of your data isn't terriby wrong
#' try(as_eqn("really bad data"))
#' try(as_eqn(data.frame(1)))
#'
#' your_equations <- tibble::tibble(
#'   equation_id = c("000001"),
#'   site = c("scbi"),
#'   sp = c("paulownia tomentosa"),
#'   eqn = c("exp(-2.48 + 2.4835 * log(dbh))"),
#'   eqn_type = c("mixed_hardwood"),
#'   anatomic_relevance = c("total aboveground biomass"),
#'   dbh_unit = "cm",
#'   bms_unit = "g",
#'   dbh_min_cm = 0,
#'   dbh_max_cm = Inf
#' )
#'
#' class(as_eqn(your_equations))
as_eqn <- function(data) {
  out <- modify_eqn(validate_eqn(data))
  new_eqn(out)
}

validate_eqn <- function(data) {
  stopifnot(is.data.frame(data))

  crucial <- c(
    "equation_id",
    "site",
    "sp",
    "eqn",
    "eqn_type",
    "anatomic_relevance",
    "dbh_unit",
    "bms_unit",
    "dbh_min_cm",
    "dbh_max_cm"
  )
  check_crucial_names(data, crucial)

  invisible(data)
}

modify_eqn <- function(data) {
  data %>%
    tibble::add_column(eqn_source = "custom", .after = "eqn") %>%
    purrr::modify(~ tolower(as.character(.x)))
}

