if (!requireNamespace("testthat", quietly = TRUE)) install.packages("testthat")

find_project_root <- function(start = getwd()) {
  current <- normalizePath(start, winslash = "/", mustWork = TRUE)

  repeat {
    has_project_files <- file.exists(file.path(current, "app.R")) &&
      dir.exists(file.path(current, "R")) &&
      dir.exists(file.path(current, "data")) &&
      dir.exists(file.path(current, "tests"))

    if (has_project_files) return(current)

    parent <- dirname(current)
    if (identical(parent, current)) {
      stop(
        "Nije pronađen korenski folder projekta. ",
        "Pokrenite testove iz foldera aplikacije ili njegovog podfoldera."
      )
    }
    current <- parent
  }
}

project_root <- find_project_root()
testthat::test_file(file.path(project_root, "tests", "test_simulation.R"))
