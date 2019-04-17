#' Fit a height-diameter model.
#'
#' This functions wraps [BIOMASS::modelHD()], which you can see for more
#' options and details.
#'
#' @inherit BIOMASS::modelHD
#' @inheritParams add_tropical_biomass
#' @param method A character string. One of these:
#'   * `log 1` (equivalent to a power model): log(H) = a + b * log(D)
#'   * `log 2`: log(H) = a + b * log(D) + c * log(D)^2
#'   * `weibull`: H = a * (1 - exp(-(D / b) ^ c))
#'   * `michaelis`: H = (A * D) / (B + D)
#'
#' @seealso [BIOMASS::modelHD()].
#'
#' @return A list with these elements:
#'   * `input`: list of the data used to construct the model (list(H, D)).
#'   * `model`: outputs of the model (same outputs as given by stats::lm(),
#'   stats::nls()).
#'   * `RSE`: Residual Standard Error of the model.
#'   * `RSElog`: Residual Standard Error of the log model (NULL if other model).
#'   * `residuals`: Residuals of the model.
#'   * `coefficients`: Coefficients of the model.
#'   * `R.squared`: R^2 of the model.
#'   * `formula`: Formula of the model.
#'   * `method`: Name of the method used to construct the model.
#'   * `predicted`: Predicted height values.
#'
#' @export
#'
#' @examples
#' data <- fgeo.biomass::scbi_tree1[1:30, ]
#'
#' str(model_height(data))
#'
#' out <- model_height(data, method = "log2")
#' # Avoid too much output
#' str(out[-2])
#' # Glimpse what wasn't shown above
#' lapply(out[2], names)
model_height <- function(data,
                         method = c("log1", "log2", "weibull", "michaelis")) {
  inform_method(match.arg(method))

  BIOMASS::modelHD(
    D = data$dbh,
    H = get_height_list(data)$H,
    method = match.arg(method)
  )
}

inform_method <- function(this_method) {
  all_methods <- c("log1", "log2", "weibull", "michaelis")
  more_methods <- setdiff(all_methods, this_method)
  ui_info(
    "Using {ui_code('method')} {this_method} \\
    (other methods: {glue_collapse(more_methods, ', ')})."
  )
}
