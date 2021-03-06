#' Extends the [covr::file_coverage()] function to also accept test files based on RUnit
#' @description Extends the [covr::file_coverage()] function to also accept test files based on RUnit
#' @param source_files Character vector of pathes to source files with function definitions to measure coverage
#' @param test_files Character vector of pathes to test files with code to test the functions
#' @param load_package Boolean. If \code{TRUE} all \code{source_files} need to be located within the directory of the same package. Set \code{TRUE} if your \code{source_files} depend on other functions from your package.
#' @param testFileRegexp Regular expression for matching test files. See [covr::runTestSuite()].
#' @param testFuncRegexp Regular expression for matching test functions. See [covr::runTestSuite()].
#' @param unlink_tmp_dir Boolean. When running [filecovrunit::package_coverage()] a package is created in R's temp directory. If \code{TRUE} the directory where the temporary pacakge is stored is unlinked after each function call. If \code{FALSE} the directory is only deleted when you quit your R-session. Note: When the temp package directory is deleted [filecovrunit::zero_coverage()] does not work anymore!
#' @param ... Additional arguments passed to [covr::package_coverage()]
#' @return an covr object (identital to [covr::package_coverage()])
#' @examples
#' # load test data
#' src <- c(system.file(file.path("extdata", "functions.R"), package = "filecovrunit"),
#' system.file(file.path("extdata", "functions2.R"), package = "filecovrunit"))
#' test <- c(system.file(file.path("extdata", "test_1.R"), package = "filecovrunit"),
#' system.file(file.path("extdata", "test_2.R"), package = "filecovrunit"))
#'
#' # check file coverage of the files
#' cov <- filecovrunit::file_coverage_runit(source_files = src,
#' test_files = test,
#' load_package = FALSE)
#' cov
#' covr::report(cov)
#' filecovrunit::zero_coverage(cov)
#' @export

file_coverage_runit <- function(source_files,
                                test_files,
                                load_package = FALSE,
                                testFileRegexp = "^test.+\\\\.R$",
                                testFuncRegexp = "^test.+",
                                unlink_tmp_dir = FALSE,
                                ...) {

  if(load_package) {
    root <- vector(mode = "character", length = length(source_files))
    for(i in 1:length(source_files)){
      # find root directory of source files
      root[i] <- tryCatch(rprojroot::find_root(rprojroot::is_r_package,
                                               path = source_files[i]),
                          error = function(e) return(FALSE))
      if(root[i] == FALSE) {
        # throw error if the file is not from a package
        stop("source file ", source_files[i], " is not from a package")
      }
    }
    if(length(unique(root)) > 1) {
      # throw error if the files are not frome the same package
      stop("source files are not from the same package")
    }
    root <- root[1]
    package_name <- basename(root)

  } else { # load_package == FALSe
    root <- NULL
    package_name <- "temppkg"
  }


  # create temporary package in temporary directory
  temp_dir <- tempfile()
  dir.create(file.path(temp_dir))
  suppressMessages(devtools::create(file.path(temp_dir, package_name), quiet = T))
  dir.create(file.path(temp_dir, package_name, "tests"))
  dir.create(file.path(temp_dir, package_name, "inst", "unitTests"), recursive = T)

  for(i in 1:length(source_files)){
    # copy the files to new package
    file.copy(from = test_files[i], to = file.path(temp_dir, package_name,"inst", "unitTests"))
    file.copy(from = source_files[i], to = file.path(temp_dir, package_name,"R"))
  }
  if(load_package){
    # find all .R files from package
    all_files <- list.files(file.path(root, "R"), recursive = T, pattern = "\\.[rR]$", full.names = T)
    # remove the source_files
    all_files <- all_files[!(all_files %in% source_files)]
    for(i in 1:length(all_files)){
      # copy files to temp package
      file.copy(all_files[i], file.path(temp_dir, package_name, "R"), recursive = T)
    }
    all_files <- gsub(pattern = paste0(root, "/"),
                      replacement = "",
                      x = normalizePath(all_files, winslash = "/"))

    # write to .covrignore
    writeLines(text = all_files, con = file.path(temp_dir, package_name, ".covrignore"))
  }

  # create a runit testsuite from template
  .create_testsuite_template(package_name = package_name,
                             package_path = file.path(temp_dir, package_name),
                             testFileRegexp = testFileRegexp,
                             testFuncRegexp = testFuncRegexp)

  # check coverage of the new package
  wd_orig <- getwd()
  setwd(file.path(temp_dir, package_name)) # wd needs to be set to root dir of temp package, otherwise .covrignore is ignored (for some reason)
  cov <- covr::package_coverage(file.path(temp_dir, package_name), ...)
  setwd(wd_orig)

  if(file.exists(file.path(temp_dir, package_name, "output.txt"))){
    # interrupt if at least one test function failed and print text protocol
    txt <- readLines(file.path(temp_dir, package_name, "output.txt"))
    txt_new <- as.character(sapply(txt, function(x) paste(x, "\n")))
    stop(txt_new)
  }

  # removing unecessary attributes from output
  attr(cov, "package")$package <- ""
  #attr(cov, "package")$path <- root
  attributes(cov)$package <- attributes(cov)$package[names(attributes(cov)$package) %in% c("package", "path")]
  if(unlink_tmp_dir){
    # delete temporary package directory if required
    unlink(file.path(temp_dir, package_name), recursive = T)
  }
  gc()
  return(cov)
}





