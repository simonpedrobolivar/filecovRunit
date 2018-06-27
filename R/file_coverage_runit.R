#' Extends the covr::file_coverage function to also accept test files based on RUnit
#' @param source_files Character vector of pathes to source files with function definitions to measure coverage
#' @param test_files Character vector of pathes to test files with code to test the functions
#' @param package_name Character with the name of the package the \code{source_files} and \code{test_files} come from
#' @param ... Additional arguments passed to \code{\link[covr]{package_coverage}}
#' @return asdf
#' @export

file_coverage_runit <- function(source_files,
                                test_files,
                                package_name,
                                ...){

  temp_dir <- tempfile() #"C:/User/temp" #tempfile()
  #print(temp_dir)

  dir.create(file.path(temp_dir))
  # create temporary package with the same name as the package the test and source files come from
  suppressMessages(devtools::create(file.path(temp_dir, package_name), quiet = T))
  dir.create(file.path(temp_dir, package_name, "tests"))
  # copy the files to new package
  for(i in 1:length(source_files)){
    file.copy(from = source_files[i], to = file.path(temp_dir, package_name,"R"))
    file.copy(from = test_files[i], to = file.path(temp_dir, package_name, "tests"))
  }
  # check coverage of the new package
  cov <- covr::package_coverage(file.path(temp_dir, package_name))
  attr(cov, "package")$package <- ""
  # delete temporary package directory
  unlink(file.path(temp_dir, package_name), recursive = T)
  return(cov)
}






