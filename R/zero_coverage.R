#' Extends [covr::zero_package()] so that it also works with [filecovrunit::file_coverage_runit] outputs
#'
#' @description Almost identical to [covr::zero_package()] with the only difference that it also works if your
#' working directory is not set to the directory where the temporary package created with [filecovrunit::file_coverage_runit]
#' is located.
#'
#' @param x a coverage object returned [package_coverage()]
#' @param ... additional arguments passed to
#' [tally_coverage()]
#' @return A `data.frame` with coverage data where the coverage is 0.
#' @details if used within RStudio this function outputs the results using the
#' Marker API.
#' @export

zero_coverage <- function(x, ...) {
  #wd_orig <- getwd()
  #setwd(attributes(x)$package$path)
  rel <- attributes(x)$relative
  if(isTRUE(rel)) attributes(x)$relative <- FALSE
  res <- covr::zero_coverage(x, ... = ...)
  attributes(x)$relative <- rel
  #setwd(wd_orig)
  #return(res)
}

