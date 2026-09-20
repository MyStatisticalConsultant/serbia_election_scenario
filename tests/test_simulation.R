if (!requireNamespace("testthat", quietly = TRUE)) stop("Instalirajte paket testthat.")

find_project_root <- function(start = getwd()) {
  current <- normalizePath(start, winslash = "/", mustWork = TRUE)

  repeat {
    has_project_files <- file.exists(file.path(current, "app.R")) &&
      dir.exists(file.path(current, "R")) &&
      dir.exists(file.path(current, "data"))

    if (has_project_files) return(current)

    parent <- dirname(current)
    if (identical(parent, current)) {
      stop("Nije pronađen korenski folder projekta.")
    }
    current <- parent
  }
}

project_root <- find_project_root()
project_file <- function(...) file.path(project_root, ...)

source_files <- list.files(project_file("R"), pattern = "\\.R$", full.names = TRUE)
for (f in source_files) source(f, local = FALSE)

default_polls <- read.csv(project_file("data", "default_polls.csv"), stringsAsFactors = FALSE, check.names = FALSE)
default_lists <- read.csv(project_file("data", "default_lists.csv"), stringsAsFactors = FALSE, check.names = FALSE)
default_polls$active <- as.logical(default_polls$active)
default_lists$active <- as.logical(default_lists$active)
default_lists$minority <- as.logical(default_lists$minority)

base_params <- function(seed = 123, n = 300) list(
  preset_id = "reconstructed", scenario_name = "Test", scenario_description = "Test",
  central_source = "reconstructed", exclude_nacija = FALSE, pollster_correction_strength = 1,
  election_cycle_sd = 2.5, turnout_mean = 63, turnout_sd = 1.5, reference_turnout = 62.3,
  turnout_min = 45, turnout_max = 75, invalid_share = 1.5,
  undecided_transfer_base = 75, undecided_transfer_low = 60, undecided_transfer_high = 90,
  youth_pool = 913000, youth_mobilised_pct = 0, youth_student = 70, youth_sns = 18, youth_sps = 2, youth_other = 10,
  resid_change = 1, resid_other = 1.28, resid_minority = 1.5, resid_abstain = .3, resid_unclassified = .2,
  current_poll_weight = 91, registered_voters = 6440000,
  historical_anchor_votes = 2051996, historical_anchor_low = 1832000, historical_anchor_high = 2272000, historical_kappa = 20,
  tactical_kappa = 20, threshold_gamma = .5, threshold_width = .6, major_bloc_corr = -.45,
  seed = seed, n_sims = n, n_seats = 250L, data_cutoff = "test", app_version = "test"
)

testthat::test_that("simulirane podrške su validne i zbir je 100%", {
  r <- simulate_scenario(base_params(), default_polls, default_lists)
  testthat::expect_true(all(r$shares >= 0))
  testthat::expect_equal(rowSums(r$shares), rep(100, nrow(r$shares)), tolerance = 1e-8)
  testthat::expect_equal(rowSums(r$seats), rep(250, nrow(r$seats)))
  testthat::expect_equal(rowSums(r$votes), r$valid_votes)
})

testthat::test_that("isti seed daje isti rezultat", {
  r1 <- simulate_scenario(base_params(777, 100), default_polls, default_lists)
  r2 <- simulate_scenario(base_params(777, 100), default_polls, default_lists)
  testthat::expect_identical(r1$shares, r2$shares)
  testthat::expect_identical(r1$seats, r2$seats)
})

testthat::test_that("drugačiji seed menja stohastički rezultat", {
  r1 <- simulate_scenario(base_params(777, 100), default_polls, default_lists)
  r2 <- simulate_scenario(base_params(778, 100), default_polls, default_lists)
  testthat::expect_false(identical(r1$shares, r2$shares))
})

testthat::test_that("obična lista ispod 3% se isključuje", {
  v <- matrix(c(60000, 38000, 2000), nrow = 1, dimnames = list(NULL, c("A", "B", "C")))
  s <- allocate_dhondt_batch(v, 100000, c(FALSE, FALSE, FALSE), n_seats = 10)
  testthat::expect_equal(unname(s[1, "C"]), 0)
  testthat::expect_equal(sum(s), 10)
})

testthat::test_that("manjinska lista ispod 3% dobija 35% tretman ali mandat nije garantovan", {
  v1 <- matrix(c(50000, 45000, 2900), nrow = 1, dimnames = list(NULL, c("A", "B", "M")))
  s1 <- allocate_dhondt_batch(v1, 100000, c(FALSE, FALSE, TRUE), n_seats = 250)
  testthat::expect_gt(s1[1, "M"], 0)
  v2 <- matrix(c(50000, 45000, 1), nrow = 1, dimnames = list(NULL, c("A", "B", "M")))
  s2 <- allocate_dhondt_batch(v2, 100000, c(FALSE, FALSE, TRUE), n_seats = 250)
  testthat::expect_equal(unname(s2[1, "M"]), 0)
})

testthat::test_that("taktički transfer čuva zbir podrške", {
  set.seed(1)
  m <- matrix(c(.5, .45, .05), nrow = 20, ncol = 3, byrow = TRUE, dimnames = list(NULL, c("student", "sns", "narodna")))
  l <- data.frame(list_id = c("student", "sns", "narodna"), tactical_target = c("", "", "student"), baseline_transfer = c(0,0,50), lower_transfer = c(0,0,30), upper_transfer = c(0,0,70))
  p <- list(tactical_kappa = 20, threshold_width = .6, threshold_gamma = .5, resid_change = 0, undecided_transfer_low = 60, undecided_transfer_high = 90, undecided_transfer_base = 75)
  out <- apply_tactical_transfers(m, l, p)$shares
  testthat::expect_equal(rowSums(out), rowSums(m), tolerance = 1e-10)
})

testthat::test_that("aplikacija ne pokreće simulaciju na promenu inputa", {
  txt <- paste(readLines(project_file("app.R"), warn = FALSE), collapse = "\n")
  testthat::expect_true(grepl("observeEvent\\(side\\$run\\(\\)", txt))
})

testthat::test_that("svi grafikoni se grade i izvoze u PNG", {
  r <- simulate_scenario(base_params(123, 100), default_polls, default_lists)
  ref <- deterministic_reference(base_params(123, 100), default_polls, default_lists)
  plots <- list(
    plot_vote_intervals(r),
    plot_seat_intervals(r),
    plot_threshold(r),
    plot_turnout(r),
    plot_scenario_compare(r, ref),
    plot_tactical_curve(base_params(123, 100))
  )

  for (p in plots) {
    testthat::expect_s3_class(p, "ggplot")
    testthat::expect_silent(ggplot2::ggplot_build(p))
    f <- tempfile(fileext = ".png")
    testthat::expect_silent(save_plot_png(p, f, width = 8, height = 5))
    testthat::expect_true(file.exists(f))
    testthat::expect_gt(file.info(f)$size, 0)
    unlink(f)
  }
})

testthat::test_that("horizontalni intervali ne koriste zastareli geom_errorbarh", {
  txt <- paste(readLines(project_file("R", "plotting.R"), warn = FALSE), collapse = "\n")
  testthat::expect_false(grepl("geom_errorbarh", txt, fixed = TRUE))
  testthat::expect_gte(length(gregexpr('orientation = "y"', txt, fixed = TRUE)[[1]]), 4)
})

testthat::test_that("hijerarhijska raspodela mladih čuva ranije unete udele", {
  out <- hierarchical_youth_composition(student = 60, sns = 25, sps = 10)
  testthat::expect_equal(out, c(student = 60, sns = 25, sps = 10, other = 5))
  testthat::expect_equal(sum(out), 100, tolerance = 1e-8)

  limited <- hierarchical_youth_composition(student = 60, sns = 30, sps = 20)
  testthat::expect_equal(limited, c(student = 60, sns = 30, sps = 10, other = 0))

  second_changed <- hierarchical_youth_composition(student = 60, sns = 35, sps = 2)
  testthat::expect_equal(unname(second_changed["student"]), 60)
  testthat::expect_equal(unname(second_changed["sns"]), 35)
  testthat::expect_equal(unname(second_changed["other"]), 3)
})

testthat::test_that("nepotpuna Shiny inicijalizacija vraća poruku umesto fatalne greške", {
  incomplete <- base_params()
  incomplete$youth_other <- NULL

  testthat::expect_error(
    errors <- validate_scenario_inputs(incomplete, default_polls, default_lists),
    NA
  )
  testthat::expect_true(any(grepl("nisu potpuno inicijalizovane", errors, fixed = TRUE)))
})

testthat::test_that("CSV uvoz prihvata dokumentovane opcione kolone", {
  minimal_polls <- data.frame(
    poll_id = "p1", pollster = "Test", active = TRUE, weight = 100,
    student_list = 40, sns = 40, sps = 5
  )
  pp <- prepare_poll_upload(minimal_polls, default_polls)
  testthat::expect_null(pp$error)
  testthat::expect_equal(names(pp$data), names(default_polls))
  testthat::expect_true(all(is.na(pp$data[c("fieldwork", "sample_size", "mode")])))

  minimal_lists <- data.frame(
    list_id = c("a", "b"), name = c("A", "B"), central_support = c(55, 45),
    active = c(TRUE, TRUE), minority = c(FALSE, FALSE)
  )
  pl <- prepare_list_upload(minimal_lists, default_lists)
  testthat::expect_null(pl$error)
  testthat::expect_equal(names(pl$data), names(default_lists))
  testthat::expect_equal(pl$data$uncertainty_sd_pp, c(1, 1))
  testthat::expect_equal(pl$data$manual_shift_pp, c(0, 0))
})

testthat::test_that("ankete su obavezne samo za ažurirani anketni izvor", {
  inactive <- default_polls
  inactive$active <- FALSE
  reconstructed_errors <- validate_scenario_inputs(base_params(), inactive, default_lists)
  testthat::expect_false(any(grepl("aktivna anketa", reconstructed_errors, ignore.case = TRUE)))

  updated_params <- base_params()
  updated_params$central_source <- "updated"
  updated_errors <- validate_scenario_inputs(updated_params, inactive, default_lists)
  testthat::expect_true(any(grepl("aktivna anketa", updated_errors, ignore.case = TRUE)))
})

testthat::test_that("Shiny grafički uređaji imaju stabilne dimenzije", {
  app_txt <- paste(readLines(project_file("app.R"), warn = FALSE), collapse = "\n")
  results_txt <- paste(readLines(project_file("R", "mod_results.R"), warn = FALSE), collapse = "\n")
  methodology_txt <- paste(readLines(project_file("R", "mod_methodology.R"), warn = FALSE), collapse = "\n")

  testthat::expect_true(grepl("fillable = FALSE", app_txt, fixed = TRUE))
  testthat::expect_gte(length(gregexpr("width = 1000", results_txt, fixed = TRUE)[[1]]), 5)
  testthat::expect_true(grepl("width = 1000", methodology_txt, fixed = TRUE))
})

testthat::test_that("DataTables izlazi imaju kontejner koji čisti podnožje", {
  files <- c(
    project_file("R", "mod_results.R"),
    project_file("R", "mod_parameters.R"),
    project_file("R", "mod_sidebar.R")
  )
  txt <- paste(unlist(lapply(files, readLines, warn = FALSE)), collapse = "\n")
  css <- paste(readLines(project_file("www", "app.css"), warn = FALSE), collapse = "\n")

  testthat::expect_equal(length(gregexpr('class = "table-frame"', txt, fixed = TRUE)[[1]]), 9)
  testthat::expect_true(grepl(".table-frame .dataTables_wrapper", css, fixed = TRUE))
  testthat::expect_true(grepl("clear: both", css, fixed = TRUE))
})

testthat::test_that("uputstva i tabela lista koriste tražene termine", {
  sidebar_txt <- paste(readLines(project_file("R", "mod_sidebar.R"), warn = FALSE), collapse = "\n")
  instructions_txt <- paste(readLines(project_file("R", "mod_instructions.R"), warn = FALSE), collapse = "\n")
  parameters_txt <- paste(readLines(project_file("R", "mod_parameters.R"), warn = FALSE), collapse = "\n")

  testthat::expect_true(grepl('"Lista", "ID liste"', sidebar_txt, fixed = TRUE))
  testthat::expect_true(grepl("Resetuj izabrani scenario", instructions_txt, fixed = TRUE))
  testthat::expect_true(grepl("Endogeni", paste(readLines(project_file("R", "mod_methodology.R"), warn = FALSE), collapse = "\n"), fixed = TRUE))
  testthat::expect_true(grepl("Korelaciona struktura latentnih grešaka", parameters_txt, fixed = TRUE))
})
