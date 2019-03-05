#' Reduce a list of dataframes complementing each one with the following one.
#'
#' Reduce a list of dataframes complementing each dataframe of the list with
#' rows from the next dataframe in the list. You can optionally set the `order`
#' to specify which elements to include, and in which order they will be
#' reduced.
#'
#' @param .x List of dataframes. Each should have a `rowid` column giving the
#'   index of each row, or `rowid` will be added with a warning.
#' @param order The order to use when reducing the list of dataframes given
#'   either as a numeric vector of the index of list elements, or as a string
#'   giving the names of the list elements. Missing elements are excluded.
#'
#' @family helpers
#'
#' @return A dataframe.
#' @export
#'
#' @examples
#' suppressPackageStartupMessages(
#'   library(dplyr)
#' )
#'
#' game <- tibble::tribble(
#'   ~round, ~player,            ~result,
#'        1, "Ana",              "piedra",
#'        1, "Maria",            "papel",
#'        1, "Jose",             "tijera",
#'
#'        2, "Maria; Jose",      "papel",
#'        2, "Ana",              "tijera",
#'
#'        3, "Ana; Maria; Jose", "tijera"
#' )
#'
#' # Who wins each round?
#' game %>%
#'   split(.$result) %>%
#'   reduce_complement()
reduce_complement <- function(.x, order = NULL) {
  order <- order %||% names(.x)

  add_rowid_if_needed <- function(.x) {
    lacks_rowid <- !purrr::map_lgl(.x, ~rlang::has_name(.x, "rowid"))

    nms <- glue::glue_collapse(
      rlang::expr_label(names(.x)[lacks_rowid]),
      sep = ", ", last = " and "
    )
    if (any(lacks_rowid)) {
      warn(glue("Adding `rowid` to {nms}"))
    }

    purrr::modify_if(.x, lacks_rowid, tibble::rowid_to_column)
  }

  .x <- add_rowid_if_needed(.x)

  purrr::reduce(.x[order], complement)
}
