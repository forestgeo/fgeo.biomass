#' Complement a dataframe with rows from another dataframe.
#'
#' Complement a dataframe with rows from another, identically structured
#' dataframe. This is the result of reducing multiple joins:
#' * `dplyr::semi_join(.data, complement)`.
#' * `dplyr::anti_join(.data, complement)`.
#' * `dplyr::anti_join(complement, .data)`.
#' Each dataframe must have a `rowid`
#'
#' @param .data Dataframes which rows to always keep.
#' @param complement Dataframe which rows will be used to complement `.data`.
#'
#' @seealso [dplyr::join()], [tibble::rowid_to_column()].
#'
#' @family helpers
#'
#' @return A dataframe.
#' @export
#'
#' @examples
#' library(dplyr)
#'
#' dfm <- tibble(rowid = 1, from = "dfm")
#' cmp <- tibble(rowid = 1:2, from = "cmp")
#' dfm %>% complement(cmp)
#'
#' dfm2 <- tibble(rowid = 1:2, x = "dfm2")
#' cmp2 <- tibble(rowid = 1:2, x = "cmp2")
#' complement(dfm2, cmp2)
#'
#' traffic_light <- tribble(
#' ~rowid, ~color,
#'      1, "red",
#'      2, "yellow"
#' )
#'
#' more_colors <- tribble(
#' ~rowid, ~color,
#'      1, "blue",
#'      2, "orange",
#'      3, "green"
#' )
#'
#' traffic_light %>% complement(more_colors)
complement <- function(.data, complement) {
  check_complement(.data, complement)

  # Handle 0-row dataframes
  .data0 <- nrow(.data) == 0
  compl0 <- nrow(complement) == 0
  # Both 0-row: return .data
  if (.data0 && compl0) {
    return(.data)
  }
  # One 0-row: Modify the 0-row one to use column types as the (non-empty) other
  if (.data0) .data <- modify_cols_as_ref(.data, complement)
  if (compl0) complement <- modify_cols_as_ref(complement, .data)

  list(
    w_and_l <- dplyr::semi_join(.data, complement, by = "rowid"),
    w_not_l <- dplyr::anti_join(.data, complement, by = "rowid"),
    l_not_w <- dplyr::anti_join(complement, .data, by = "rowid")
  ) %>%
    purrr::reduce(dplyr::bind_rows)
}

check_complement <- function(.data, complement) {
  check_crucial_names(.data, "rowid")
  check_crucial_names(complement, "rowid")

  missing_.data <- any(is.na(.data$rowid))
  missing_complement <- any(is.na(complement$rowid))
  if (missing_.data || missing_complement) {
    abort("`rowid` can't have missing values.")
  }

  invisible()
}

cols_expr <- function(.data) {
  types <- .data %>%
    purrr::map_chr(typeof) %>%
    strsplit("") %>%
    purrr::map_chr(1)
  .cols <- glue::glue_collapse(glue::glue("{names(types)} = \"{types}\""), ", ")
  rlang::parse_expr(glue::glue("readr::cols({.cols})"))
}

modify_cols_as_ref <- function(.data, ref) {
  .data <- purrr::modify(.data, as.character)
  readr::type_convert(.data, col_types = rlang::eval_tidy(cols_expr(ref)))
}

