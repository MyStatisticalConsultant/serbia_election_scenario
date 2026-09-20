build_latent_correlation <- function(list_ids, rho_student_gov = -0.45) {
  k <- length(list_ids)
  R <- diag(k)
  rownames(R) <- colnames(R) <- list_ids
  if (all(c("student", "sns") %in% list_ids)) R["student", "sns"] <- R["sns", "student"] <- rho_student_gov
  if (all(c("student", "sps") %in% list_ids)) R["student", "sps"] <- R["sps", "student"] <- rho_student_gov
  if (all(c("sns", "sps") %in% list_ids)) R["sns", "sps"] <- R["sps", "sns"] <- 0.50
  nearest_psd_correlation(R)
}

summarise_matrix <- function(mat, names_map = NULL) {
  qs <- apply(mat, 2, quantile, probs = c(.025, .25, .5, .75, .975), na.rm = TRUE, names = FALSE)
  out <- data.frame(
    list_id = colnames(mat),
    q025 = qs[1, ], q25 = qs[2, ], median = qs[3, ], q75 = qs[4, ], q975 = qs[5, ],
    stringsAsFactors = FALSE
  )
  if (!is.null(names_map)) out$name <- unname(names_map[out$list_id])
  out
}

simulate_scenario <- function(params, polls, lists) {
  set.seed(params$seed)
  n <- as.integer(params$n_sims)

  built <- build_central_support(params, polls, lists)
  active_lists <- built$active_lists
  ids <- active_lists$list_id
  nm <- setNames(active_lists$name, ids)
  k <- length(ids)

  turnout <- simulate_turnout(n, params)

  central <- built$central
  p0 <- normalize_vector(central, 1)
  P <- matrix(rep(p0, each = n), nrow = n, ncol = k, dimnames = list(NULL, ids))

  # New simulator specification: uncertainty in the historical SNS+SPS anchor.
  if (params$central_source == "updated" && all(c("sns", "sps") %in% ids) && params$current_poll_weight < 100) {
    anchor_draw <- scaled_beta_draw(
      n,
      params$historical_anchor_low,
      params$historical_anchor_high,
      params$historical_anchor_votes,
      params$historical_kappa
    )
    expected_valid_mid <- params$registered_voters * (params$turnout_mean / 100) * (1 - params$invalid_share / 100)
    midpoint_prior <- params$historical_anchor_votes / expected_valid_mid
    sim_valid_approx <- params$registered_voters * turnout * (1 - params$invalid_share / 100)
    prior_share_draw <- anchor_draw / pmax(sim_valid_approx, 1)
    delta <- (1 - params$current_poll_weight / 100) * (prior_share_draw - midpoint_prior)
    gov0 <- P[, "sns"] + P[, "sps"]
    sns_frac <- P[, "sns"] / pmax(gov0, 1e-9)
    new_gov <- pmax(gov0 + delta, 1e-5)
    P[, "sns"] <- new_gov * sns_frac
    P[, "sps"] <- new_gov * (1 - sns_frac)
    P <- P / rowSums(P)
  }

  base_sd <- built$base_sd[ids]
  total_sd_pp <- sqrt(base_sd^2 + params$election_cycle_sd^2)
  latent_sd <- pp_sd_to_logit_sd(p0, total_sd_pp)
  R <- build_latent_correlation(ids, params$major_bloc_corr)
  Sigma <- outer(latent_sd, latent_sd) * R
  eps <- MASS::mvrnorm(n = n, mu = rep(0, k), Sigma = Sigma)
  if (is.null(dim(eps))) eps <- matrix(eps, nrow = n, ncol = k)
  if (n == 1 && nrow(eps) != 1) eps <- matrix(eps, nrow = 1)
  colnames(eps) <- ids

  z <- log(pmax(P, 1e-10)) + eps
  shares <- row_softmax(z)
  colnames(shares) <- ids

  tactical <- apply_tactical_transfers(shares, active_lists, params)
  shares <- tactical$shares

  counted <- apply_youth_mobilisation(shares, turnout, params, ids)
  votes <- counted$votes
  colnames(votes) <- ids
  vote_share <- votes / counted$valid_votes * 100
  colnames(vote_share) <- ids

  minority_flags <- as.logical(active_lists$minority)
  seats <- allocate_dhondt_batch(votes, counted$ballots, minority_flags, params$n_seats, .03)
  colnames(seats) <- ids

  threshold_votes <- counted$ballots * .03
  threshold_cross <- sweep(votes, 1, threshold_votes, FUN = ">=")
  colnames(threshold_cross) <- ids

  share_summary <- summarise_matrix(vote_share, nm)
  vote_summary <- summarise_matrix(votes, nm)
  seat_summary <- summarise_matrix(seats, nm)

  threshold_summary <- data.frame(
    list_id = ids,
    name = unname(nm[ids]),
    minority = minority_flags,
    share_above_threshold = ifelse(minority_flags, NA_real_, colMeans(threshold_cross) * 100),
    stringsAsFactors = FALSE
  )

  turnout_summary <- quantile(turnout * 100, c(.025, .25, .5, .75, .975), names = FALSE)

  if (all(c("sns", "sps") %in% ids)) {
    gov_share <- vote_share[, "sns"] + vote_share[, "sps"]
    gov_votes <- votes[, "sns"] + votes[, "sps"]
    gov_seats <- seats[, "sns"] + seats[, "sps"]
  } else {
    gov_share <- gov_votes <- gov_seats <- NULL
  }

  list(
    params = params,
    polls = polls,
    lists = active_lists,
    central = central,
    poll_details = built$poll_details,
    turnout = turnout,
    ballots = counted$ballots,
    invalid = counted$invalid,
    valid_votes = counted$valid_votes,
    youth_ballots = counted$youth_ballots,
    shares = vote_share,
    votes = votes,
    seats = seats,
    threshold_cross = threshold_cross,
    share_summary = share_summary,
    vote_summary = vote_summary,
    seat_summary = seat_summary,
    threshold_summary = threshold_summary,
    turnout_summary = turnout_summary,
    gov_share = gov_share,
    gov_votes = gov_votes,
    gov_seats = gov_seats,
    tactical_log = tactical$transfer_log,
    correlation = R,
    scenario_id = scenario_hash(list(params = params, polls = polls, lists = active_lists))
  )
}

deterministic_reference <- function(params, polls, lists) {
  p <- params
  p$turnout_sd <- 0
  p$election_cycle_sd <- 0
  p$n_sims <- 1L
  p$seed <- 1L
  l <- lists
  l$uncertainty_sd_pp <- 0
  # Deterministic transfer draw is approximated by very high concentration.
  p$tactical_kappa <- 1e6
  r <- simulate_scenario(p, polls, l)
  data.frame(
    list_id = colnames(r$shares),
    vote_share = as.numeric(r$shares[1, ]),
    seats = as.integer(r$seats[1, ]),
    stringsAsFactors = FALSE
  )
}
