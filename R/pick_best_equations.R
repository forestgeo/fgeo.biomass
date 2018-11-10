#' Find the best equations given a priority order.
#'
#' This function orders the output of [get_equations()] by equation type, then
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
#'   census_species(allodb::scbi_species, "scbi") %>%
#'   get_equations() %>%
#'   pick_best_equations()
pick_best_equations <- function(.data,
  order = c(
    "species",
    "genus",
    "family",
    "mixed_hardwood",
    "woody_species"
  )) {
  .data %>%
    dplyr::pull(.data$data) %>%
    rlang::set_names(.data$eqn_type) %>%
    rowbind_inorder(order = order)
}
