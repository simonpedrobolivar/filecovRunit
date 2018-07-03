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

  # create temporary directory
  temp_dir <- tempfile()
  dir.create(file.path(temp_dir))
  # create temporary package with the same name as the package the test and source files come from
  suppressMessages(devtools::create(file.path(temp_dir, package_name), quiet = T))
  dir.create(file.path(temp_dir, package_name, "tests"))
  dir.create(file.path(temp_dir, package_name, "inst", "unitTests"),
             recursive = T)
#  devtools::load_all(file.path(temp_dir, package_name))
  env <- new.env()
  for(i in 1:length(source_files)){
    # copy the files to new package
    file.copy(from = test_files[i], to = file.path(temp_dir, package_name,"inst", "unitTests"))
    file.copy(from = source_files[i], to = file.path(temp_dir, package_name,"R"))
  }
  # create a runit testsuite from template
  .create_testsuite_template(package_name = package_name,
                            package_path = file.path(temp_dir, package_name))
  # check coverage of the new package
  cov <- suppressWarnings(covr::package_coverage(file.path(temp_dir, package_name), quiet = T))

  if(file.exists(file.path(temp_dir, package_name, "output.txt"))){
    # interrupt if at least one test function failed and print text protocol
    txt <- readLines(file.path(temp_dir, package_name, "output.txt"))
    txt_new <- as.character(sapply(txt, function(x) paste(x, "\n")))
    stop(txt_new)
  }

  attr(cov, "package")$package <- ""
  # delete temporary package directory
  unlink(file.path(temp_dir, package_name), recursive = T)
  gc()
  return(cov)
}





