#' Find the best equations given a priority order.
#'
#' This function orders the output of [allo_find()] by equation type, then
#' reduces it in order, by overwriting equations of each type with the
#' equations of a higher-priority type.
#'
#' @param .data List of dataframes. Each should have a `rowid` column giving the
#'   index of each row. Otherwise, `rowid` will be added with a warning.
#' @param order String giving the name or index of the list elements in the
#'   order they should be row-bind, with elements on the left winning over
#'   elements on the right.
#'
#' @family functions to manipulate equations
#'
#' @seealso [rowbind_inorder()].
#'
#' @return A dataframe.
#' @export
#'
#' @examples
#' allodb::scbi_tree1 %>%
#'   add_species(allodb::scbi_species, "scbi") %>%
#'   allo_find() %>%
#'   pick_best_equations()
pick_best_equations <- function(.data, order = NULL) {
  check_pick_best_equations(.data)

  unnst <- tidyr::unnest(.data)
  .x <- split(unnst, unnst$eqn_type)

  order <- order %||% names(.x)

  rowbind_inorder(.x, order = order)
}

check_pick_best_equations <- function(.data) {
  if (!is.data.frame(.data)) {
    abort("`.data` must be a dataframe.")
  }

  check_crucial_names(.data, "data")

  invisible(.data)
}
