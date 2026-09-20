scenario_presets <- function() {
  list(
    reconstructed = list(
      name = "Rekonstruisana početna procena",
      description = "Početne podrške iz metodološke rekonstrukcije. Ostatak od 4,28% ostaje eksplicitno razložen i ne tretira se kao jedinstven politički blok.",
      central_source = "reconstructed",
      turnout_mean = 63.0,
      turnout_sd = 1.5,
      reference_turnout = 62.3,
      election_cycle_sd = 2.5,
      pollster_correction_strength = 1.0,
      current_poll_weight = 91,
      threshold_gamma = 0.50,
      tactical_kappa = 20,
      youth_mobilised_pct = 0
    ),
    base_tactical = list(
      name = "Bazni taktički transferi",
      description = "Bazne stope taktičkog transfera iz beleške, uz umerenu izlaznost i novu statističku specifikaciju neizvesnosti simulatora.",
      central_source = "updated",
      turnout_mean = 63.0,
      turnout_sd = 1.5,
      reference_turnout = 58.8,
      election_cycle_sd = 2.5,
      pollster_correction_strength = 1.0,
      current_poll_weight = 91,
      threshold_gamma = 0.50,
      tactical_kappa = 20,
      youth_mobilised_pct = 10
    ),
    high_mob = list(
      name = "Visoka izlaznost i visoka konsolidacija",
      description = "Viša izlaznost, veća mobilizacija mladih i jači transfer ka Studentskoj listi kada manje liste ostaju blizu ili ispod cenzusa. Scenario opisuje pretpostavke, ne njihovu verovatnoću.",
      central_source = "updated",
      turnout_mean = 65.0,
      turnout_sd = 1.2,
      reference_turnout = 62.3,
      election_cycle_sd = 2.5,
      pollster_correction_strength = 1.0,
      current_poll_weight = 91,
      threshold_gamma = 0.95,
      tactical_kappa = 28,
      youth_mobilised_pct = 20
    ),
    low_tactical = list(
      name = "Niža taktička konsolidacija",
      description = "Niža osetljivost taktičkih transfera na cenzus i šira raspodela individualnih transfera.",
      central_source = "updated",
      turnout_mean = 62.0,
      turnout_sd = 1.5,
      reference_turnout = 58.8,
      election_cycle_sd = 2.5,
      pollster_correction_strength = 1.0,
      current_poll_weight = 91,
      threshold_gamma = 0.20,
      tactical_kappa = 14,
      youth_mobilised_pct = 8
    ),
    high_uncertainty = list(
      name = "Veća neizvesnost anketa",
      description = "Šira izborno-ciklična greška povećava raspon simuliranih ishoda bez ugrađenog sistematskog pomeranja ka bilo kojoj listi.",
      central_source = "updated",
      turnout_mean = 63.0,
      turnout_sd = 2.0,
      reference_turnout = 58.8,
      election_cycle_sd = 4.0,
      pollster_correction_strength = 0.75,
      current_poll_weight = 90,
      threshold_gamma = 0.50,
      tactical_kappa = 16,
      youth_mobilised_pct = 10
    )
  )
}

scenario_control_defaults <- function() {
  list(
    data_updated = as.Date("2026-09-19"),
    exclude_nacija = FALSE,
    undecided_transfer_base = 75,
    undecided_transfer_range = c(60, 90),
    youth_pool = 913000,
    youth_student = 70,
    youth_sns = 18,
    youth_sps = 2,
    youth_other = 10,
    resid_change = 1.00,
    resid_other = 1.28,
    resid_minority = 1.50,
    resid_abstain = 0.30,
    resid_unclassified = 0.20,
    registered_voters = 6440000,
    invalid_share = 1.5,
    historical_anchor = 2051996,
    historical_low = 1832000,
    historical_high = 2272000,
    historical_kappa = 20,
    threshold_width = 0.6,
    major_bloc_corr = -0.45,
    turnout_min = 45,
    turnout_max = 75,
    seed = 12345,
    n_sims = 10000
  )
}

apply_preset_to_lists <- function(lists, preset_id) {
  out <- lists
  if (preset_id == "high_mob") {
    out$baseline_transfer[out$list_id %in% c("narodna", "proeu")] <- 85
    out$lower_transfer[out$list_id %in% c("narodna", "proeu")] <- 80
    out$upper_transfer[out$list_id %in% c("narodna", "proeu")] <- 90
  } else {
    defaults <- read.csv(file.path("data", "default_lists.csv"), stringsAsFactors = FALSE, check.names = FALSE)
    idx <- match(out$list_id, defaults$list_id)
    ok <- !is.na(idx)
    out$baseline_transfer[ok] <- defaults$baseline_transfer[idx[ok]]
    out$lower_transfer[ok] <- defaults$lower_transfer[idx[ok]]
    out$upper_transfer[ok] <- defaults$upper_transfer[idx[ok]]
  }
  out
}
