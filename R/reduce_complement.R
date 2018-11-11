#' Reduce a list of dataframes row-binding each dataframe in a given order.
#'
#' This function orders a list of dataframes then reduces the list in order, by
#' row-binding each dataframe with the following one and using
#' [complement()].
#'
#' @param .x List of dataframes. Each should have a `rowid` column giving the
#'   index of each row. Otherwise, `rowid` will be added with a warning.
#' @param order String giving the name or index of the list elements in the
#'   order they should be row-bind, with elements on the left winning over
#'   elements on the right.
#'
#' @family helpers
#'
#' @return A dataframe.
#' @export
#'
#' @examples
#' library(dplyr)
#'
#' prio <- list(
#'   prio1 = tibble(rowid = 1:1, x = "prio1"),
#'   prio2 = tibble(rowid = 1:2, x = "prio2"),
#'   prio3 = tibble(rowid = 1:3, x = "prio3")
#' )
#' reduce_complement(prio)
#' # Same
#' reduce_complement(prio, c(1, 2, 3))
#'
#' # 3 overwrites all other
#' reduce_complement(prio, c("prio3", "prio2", "prio1"))
#'
#' # 2 overwrites over 1
#' reduce_complement(prio, c(2, 1))
#'
#' # Adds `rowid` with a warning
#' prio <- list(
#'   prio1 = tibble(rowid = 1, x = "prio1"),
#'   prio2 = tibble(x = "prio2"),
#'   prio3 = tibble(x = "prio3")
#' )
#' reduce_complement(prio)
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
