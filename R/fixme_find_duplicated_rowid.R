#' Handle multiple `rowid`s: find duplicates and pick a single row.
#'
#' @inherit allo_evaluate
#' @family internal functions that flag issues to be fixed
#' @name handle_multiple_rowid
NULL

#' @rdname handle_multiple_rowid
#' @export
fixme_find_duplicated_rowid <- function(.data) {
  check_crucial_names(.data, c("sp", "site", "eqn", "equation_id"))

  .data %>%
    unique() %>%
    dplyr::add_count(.data$rowid, sort = TRUE) %>%
    dplyr::filter(.data$n > 1)
}


#' @rdname handle_multiple_rowid
#' @export
fixme_pick_one_row_by_rowid <- function(.data) {
  .data %>%
    dplyr::group_by(.data$rowid) %>%
    dplyr::filter(dplyr::row_number() == 1L) %>%
    dplyr::ungroup()
}
