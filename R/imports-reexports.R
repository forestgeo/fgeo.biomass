#' @importFrom dplyr group_by ungroup filter select summarize mutate left_join
#' @importFrom dplyr arrange
#' @importFrom tidyselect matches
#' @importFrom fgeo.tool check_crucial_names
#' @importFrom glue glue glue_collapse
#' @importFrom rlang abort warn inform %||%
#' @importFrom usethis ui_info ui_done ui_field ui_code ui_warn
NULL

globalVariables(c(".data", "."))
