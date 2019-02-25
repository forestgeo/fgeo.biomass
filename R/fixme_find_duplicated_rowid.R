#' Handle multiple `rowid`s: find duplicates and pick a single row.
#'
#' @inherit allo_evaluate
#' @family internal functions that flag issues to be fixed
#' @name handle_multiple_rowid
#'
#' @return
#'   * `fixme_find_duplicated_rowid()` returns a dataframe with the rows for
#'   which duplicated `rowid` values are found.
#'   * `fixme_pick_one_row_by_rowid()` returns a dataframe with a single row per
#'   rowid value.
#' @examples
#' best <- fgeo.biomass::scbi_tree1 %>%
#'   add_species(fgeo.biomass::scbi_species, "scbi") %>%
#'   allo_find() %>%
#'   allo_order()
#'
#' best %>%
#'   fixme_find_duplicated_rowid()
#'
#' best %>%
#'   fixme_pick_one_row_by_rowid()
#'
#' best %>%
#'   fixme_pick_one_row_by_rowid()
#'
#' # Should return 0-rows
#' best %>%
#'   fixme_pick_one_row_by_rowid() %>%
#'   fixme_find_duplicated_rowid()
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

fixme_pick_one_row_by_rowid <- function(.data) {
  .data %>%
    dplyr::group_by(.data$rowid) %>%
    dplyr::filter(dplyr::row_number() == 1L) %>%
    dplyr::ungroup()
}

#' @rdname handle_multiple_rowid
#' @export
fixme_drop_duplicated_rowid <- function(data) {
  dup_rowid <- data %>%
    fixme_find_duplicated_rowid() %>%
    dplyr::pull(rowid) %>%
    unique()
  n <- length(dup_rowid)
  warn(glue("Dropping {n} rows with duplicated `rowid` values."))

  data %>% dplyr::filter(!.data$rowid %in% dup_rowid)
}

