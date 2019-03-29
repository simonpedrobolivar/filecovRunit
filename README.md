# filecovRunit
filecovRunit is a small R-package which extends the file_coverage()-function from R's [covr](https://github.com/r-lib/covr)-Package.

# Installation #

```r
devtools::install_github("simschul/filecovRunit")
```

# Example # 
Load test data. One source file (src) which contains functions to be tested, and one test file containing Runit-tests. 
```r
src <- c(system.file(file.path("extdata", "functions.R"), package = "filecovrunit"),
system.file(file.path("extdata", "functions2.R"), package = "filecovrunit"))
test <- c(system.file(file.path("extdata", "test_1.R"), package = "filecovrunit"),
system.file(file.path("extdata", "test_2.R"), package = "filecovrunit"))
```

Now let's check the code coverage of the files:

```r
cov <- filecovrunit::file_coverage_runit(source_files = src, test_files = test, load_package = FALSE)
cov
covr::report(cov)
filecovrunit::zero_coverage(cov)
```

