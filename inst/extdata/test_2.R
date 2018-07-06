library(RUnit)

test.exp <- function(){
  checkIdentical(my_exp(2,3), 8)
  checkIdentical(my_exp_broken(2,3), 8)
}


