# internal function
.create_testsuite_template <- function(package_name,
                                       package_path,
                                       rel_template_path = file.path("inst", "extdata", "template.R")){

  package_path <- normalizePath(package_path,
                                winslash = "/")

  template_out <- whisker::whisker.render(readLines(rel_template_path),
                                          data = list("package_name" = package_name,
                                                      "package_path" = package_path))
  writeLines(template_out, (file.path(package_path, "tests", "test_runit.R")))
  return(NULL)

}

