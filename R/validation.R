validate_scenario_inputs <- function(params, polls, lists) {
  errors <- character()

  numeric_params <- c(
    "pollster_correction_strength", "election_cycle_sd", "turnout_mean",
    "turnout_sd", "reference_turnout", "turnout_min", "turnout_max",
    "invalid_share", "undecided_transfer_base", "undecided_transfer_low",
    "undecided_transfer_high", "youth_pool", "youth_mobilised_pct",
    "youth_student", "youth_sns", "youth_sps", "youth_other",
    "resid_change", "resid_other", "resid_minority", "resid_abstain",
    "resid_unclassified", "current_poll_weight", "registered_voters",
    "historical_anchor_votes", "historical_anchor_low", "historical_anchor_high",
    "historical_kappa", "tactical_kappa", "threshold_gamma", "threshold_width",
    "major_bloc_corr", "seed", "n_sims", "n_seats"
  )
  numeric_ok <- stats::setNames(vapply(numeric_params, function(nm) {
    is_finite_scalar(params[[nm]])
  }, logical(1)), numeric_params)
  if (any(!numeric_ok)) {
    errors <- c(
      errors,
      paste0(
        "Kontrole još nisu potpuno inicijalizovane ili sadrže nevažeću vrednost: ",
        paste(names(numeric_ok)[!numeric_ok], collapse = ", "),
        ". Sačekajte da se izabrani scenario učita i pokušajte ponovo."
      )
    )
  }
  all_numeric_ok <- function(...) all(numeric_ok[c(...)])

  central_source_ok <- is.character(params$central_source) &&
    length(params$central_source) == 1L &&
    params$central_source %in% c("reconstructed", "updated")
  if (!central_source_ok) {
    errors <- c(errors, "Izvor centralne podrške nije pravilno izabran.")
  }

  poll_active <- suppressWarnings(as.logical(polls$active))
  if (anyNA(poll_active)) errors <- c(errors, "Kolona active u tabeli anketa mora sadržati TRUE/FALSE ili 1/0.")
  poll_active[is.na(poll_active)] <- FALSE
  if (anyDuplicated(polls$poll_id)) errors <- c(errors, "Identifikatori anketa u koloni poll_id moraju biti jedinstveni.")
  if (any(is.na(polls$weight)) || any(polls$weight < 0, na.rm = TRUE)) errors <- c(errors, "Ponderi anketa moraju biti nenegativni brojevi.")
  estimate_cols <- intersect(c("student_list", "sns", "sps"), names(polls))
  if (length(estimate_cols)) {
    estimate_values <- unlist(polls[estimate_cols], use.names = FALSE)
    if (any(estimate_values < 0 | estimate_values > 100, na.rm = TRUE)) {
      errors <- c(errors, "Sve raspoložive anketne procene moraju biti između 0 i 100%.")
    }
  }
  if (identical(params$central_source, "updated")) {
    active_polls <- poll_active & is.finite(polls$weight) & polls$weight > 0
    if (isTRUE(params$exclude_nacija)) active_polls[grepl("Nacija", polls$pollster, ignore.case = TRUE)] <- FALSE
    if (!any(active_polls)) {
      errors <- c(errors, "Za izvor ‘Ažurirane ankete i model’ potrebna je najmanje jedna aktivna anketa sa pozitivnim ponderom.")
    } else {
      for (cc in c("student_list", "sns", "sps")) {
        if (!cc %in% names(polls) || !any(is.finite(polls[[cc]][active_polls]))) {
          errors <- c(errors, paste0("Za ažurirani anketni model potrebna je najmanje jedna aktivna procena u koloni ", cc, "."))
        }
      }
    }
  }
  list_active <- suppressWarnings(as.logical(lists$active))
  minority_flag <- suppressWarnings(as.logical(lists$minority))
  if (anyNA(list_active)) errors <- c(errors, "Kolona active u tabeli lista mora sadržati TRUE/FALSE ili 1/0.")
  if (anyNA(minority_flag)) errors <- c(errors, "Kolona minority u tabeli lista mora sadržati TRUE/FALSE ili 1/0.")
  list_active[is.na(list_active)] <- FALSE
  if (!any(list_active)) errors <- c(errors, "Najmanje jedna izborna lista mora biti aktivna.")
  if (anyDuplicated(lists$list_id)) errors <- c(errors, "Identifikatori izbornih lista moraju biti jedinstveni.")
  if (any(lists$central_support < 0, na.rm = TRUE) || any(lists$central_support > 100, na.rm = TRUE)) errors <- c(errors, "Početna podrška mora biti između 0 i 100%.")
  active_support <- lists$central_support[list_active]
  if (!any(is.finite(active_support) & active_support > 0)) errors <- c(errors, "Aktivne liste moraju imati najmanje jednu pozitivnu centralnu podršku.")
  if (any(lists$uncertainty_sd_pp < 0, na.rm = TRUE)) errors <- c(errors, "Neizvesnost podrške ne može biti negativna.")

  transfer_cols <- c("baseline_transfer", "lower_transfer", "upper_transfer")
  for (cc in transfer_cols) {
    if (any(lists[[cc]] < 0, na.rm = TRUE) || any(lists[[cc]] > 100, na.rm = TRUE)) {
      errors <- c(errors, "Stope taktičkog transfera moraju biti između 0 i 100%.")
      break
    }
  }
  idx <- which(!is.na(lists$tactical_target) & nzchar(lists$tactical_target))
  if (length(idx)) {
    bad <- lists$lower_transfer[idx] > lists$baseline_transfer[idx] | lists$baseline_transfer[idx] > lists$upper_transfer[idx]
    if (any(bad, na.rm = TRUE)) errors <- c(errors, "Za taktičke transfere mora važiti donja granica ≤ bazna vrednost ≤ gornja granica.")
    bad_target <- !lists$tactical_target[idx] %in% lists$list_id[list_active]
    if (any(bad_target)) errors <- c(errors, "Svaki cilj taktičkog transfera mora biti aktivna lista sa postojećim list_id identifikatorom.")
  }

  if (all_numeric_ok("turnout_mean") && (params$turnout_mean < 0 || params$turnout_mean > 100)) errors <- c(errors, "Očekivana izlaznost mora biti između 0 i 100%.")
  if (all_numeric_ok("turnout_sd") && params$turnout_sd < 0) errors <- c(errors, "SD izlaznosti ne može biti negativan.")
  if (all_numeric_ok("turnout_min", "turnout_max") && params$turnout_min >= params$turnout_max) errors <- c(errors, "Minimalna dozvoljena izlaznost mora biti manja od maksimalne.")
  if (all_numeric_ok("invalid_share") && (params$invalid_share < 0 || params$invalid_share > 100)) errors <- c(errors, "Udeo nevažećih listića mora biti između 0 i 100%.")
  if (all_numeric_ok("invalid_share", "turnout_mean") && params$invalid_share >= params$turnout_mean && params$turnout_mean > 0) errors <- c(errors, "Udeo nevažećih listića ne može biti veći od očekivane izlaznosti.")
  if (all_numeric_ok("n_sims") && params$n_sims < 1) errors <- c(errors, "Broj simulacija mora biti pozitivan.")
  if (all_numeric_ok("n_seats") && params$n_seats != 250) errors <- c(errors, "Model je podešen za 250 poslaničkih mandata.")
  if (all_numeric_ok("tactical_kappa") && params$tactical_kappa <= 0) errors <- c(errors, "Koncentracija Beta distribucije mora biti veća od nule.")
  if (all_numeric_ok("historical_anchor_low", "historical_anchor_high", "historical_anchor_votes") && (params$historical_anchor_low >= params$historical_anchor_high || params$historical_anchor_votes < params$historical_anchor_low || params$historical_anchor_votes > params$historical_anchor_high)) errors <- c(errors, "Centralna vrednost istorijskog sidra mora biti između donje i gornje granice.")
  if (all_numeric_ok("threshold_width") && params$threshold_width <= 0) errors <- c(errors, "Širina zone oko cenzusa mora biti veća od nule.")

  youth_names <- c("youth_student", "youth_sns", "youth_sps", "youth_other")
  if (all_numeric_ok(youth_names)) {
    youth_sum <- sum(vapply(youth_names, function(nm) params[[nm]], numeric(1)))
    if (abs(youth_sum - 100) > 1e-6) errors <- c(errors, "Učešća u raspodeli dodatno mobilisanih mladih moraju ukupno iznositi 100%.")
  }

  residual_names <- c("resid_change", "resid_other", "resid_minority", "resid_abstain", "resid_unclassified")
  if (central_source_ok && identical(params$central_source, "reconstructed") && all_numeric_ok(residual_names)) {
    residual_sum <- sum(vapply(residual_names, function(nm) params[[nm]], numeric(1)))
    if (abs(residual_sum - 4.28) > 0.01) {
      errors <- c(errors, "Kod rekonstruisane početne procene komponente nerazvrstanog ostatka treba da daju 4,28%.")
    }
  }

  unique(errors)
}
