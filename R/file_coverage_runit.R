#' Extends the [covr::file_coverage()] function to also accept test files based on RUnit
#' @description So far only works if the test-functions from the \code{test_files} are explicitally called within the same file.
#' @param source_files Character vector of pathes to source files with function definitions to measure coverage
#' @param test_files Character vector of pathes to test files with code to test the functions
#' @param package_name Character with the name of the package the \code{source_files} and \code{test_files} come from
#' @param ... Additional arguments passed to [covr::package_coverage()]
#' @return an covr object (identital to [covr::package_coverage()])
#' @examples
#' # load test data
#' src <- c(system.file(file.path("inst", "extdata", "functions.R"), package = "filecovrunit"),
#' system.file(file.path("inst", "extdata", "functions2.R"), package = "filecovrunit"))
#' test <- c(system.file(file.path("inst", "extdata", "test_1.R"), package = "filecovrunit"),
#' system.file(file.path("inst", "extdata", "test_2.R"), package = "filecovrunit"))
#' pkg_name <- "testpackage3"
#'
#' # check file coverage of the files
#' cov <- filecovrunit::file_coverage_runit(source_files = src,
#' test_files = test,
#' package_name = pkg_name)
#' cov
#' covr::report(cov)
#' @export

file_coverage_runit <- function(source_files,
                                test_files,
                                #run_test,
                                package_name,
                                ...){
  #source_files <- src
  #test_files <- test
  #package_name <- pkg_name

  # create temporary directory
  temp_dir <- tempfile()
  dir.create(file.path(temp_dir))
  # create temporary package with the same name as the package the test and source files come from
  suppressMessages(devtools::create(file.path(temp_dir, package_name), quiet = T))
  dir.create(file.path(temp_dir, package_name, "tests"))
  #dir.create(file.path(temp_dir, package_name, "inst"))
  #file.copy(from = run_test, to = file.path(temp_dir, package_name, "test"))
  devtools::load_all(file.path(temp_dir, package_name))
  env <- new.env()
  for(i in 1:length(source_files)){
    # copy the files to new package
    file.copy(from = test_files[i], to = file.path(temp_dir, package_name,"tests"))
    file.copy(from = source_files[i], to = file.path(temp_dir, package_name,"R"))
    if(TRUE){
      # load test file
      source(test_files[i], local = env)
      # read all objects from test file into temporary environment
      testfuns <- ls(envir = env)#[c(8,9)]
      rm(list = ls(envir = env), envir = env)
      for(j in 1:length(testfuns)){
        testfuns[j] <- paste0(testfuns[j], "()")
      }
      # append function call to test files (e.g. test.sum())
      write(testfuns,
            file.path(temp_dir, package_name,"tests",
                      basename(test_files[i])),
            append = T)
    }
  }

  devtools::load_all(file.path(temp_dir, package_name))
  # check coverage of the new package
  cov <- covr::package_coverage(file.path(temp_dir, package_name))
  attr(cov, "package")$package <- ""
  # delete temporary package directory
  unlink(file.path(temp_dir, package_name), recursive = T)
  return(cov)
}






