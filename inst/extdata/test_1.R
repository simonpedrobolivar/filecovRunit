library(RUnit)
#devtools::load_all()
library(testpackage3)


test.sum <- function(){
  checkIdentical(my_sum(2,3), 5)
  checkIdentical(my_sum_broken(2,3), 5)
}

test.dif <- function(){
  checkIdentical(my_dif(2,3), -1)
  checkIdentical(my_dif_broken(2,3), -1)
}


#test.sum()
#test.dif()
