# functions

#' @export

my_exp <- function(a, b) {
  return(a^b)
}

#' @export

my_exp_broken <- function(a, b) {
  if(is.character(a)) stop("a is character")
  return(a^b)
}
