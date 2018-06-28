# functions
library(devtools)
library(covr)
library(RUnit)

#' @export
my_sum <- function(a, b) {
  return(a + b)
}

#' @export
my_sum_broken <- function(a, b) {
  if(is.character(a)) stop("a is character")
  return(a + b )
}

#' @export
my_dif <- function(a, b) {
  return(a - b)
}

#' @export
my_dif_broken <- function(a, b) {
  return(a - b)
}

