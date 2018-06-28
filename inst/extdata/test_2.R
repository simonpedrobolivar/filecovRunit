library(RUnit)
#devtools::load_all()
library(testpackage3)

test.exp <- function(){
  checkIdentical(my_exp(2,3), 8)
  checkIdentical(my_exp_broken(2,3), 8)
}


#test.exp()
