simulate_turnout <- function(n, params) {
  rtruncnorm_base(
    n = n,
    mean = params$turnout_mean,
    sd = params$turnout_sd,
    min = params$turnout_min,
    max = params$turnout_max
  ) / 100
}

apply_youth_mobilisation <- function(base_shares, turnout, params, list_ids) {
  n <- nrow(base_shares)
  registered <- params$registered_voters
  ballots <- round(registered * turnout)
  invalid <- round(ballots * params$invalid_share / 100)
  valid_votes <- pmax(ballots - invalid, 1)

  reference_ballots <- registered * params$reference_turnout / 100
  marginal_ballots <- pmax(ballots - reference_ballots, 0)
  youth_target <- params$youth_pool * params$youth_mobilised_pct / 100
  youth_ballots <- pmin(marginal_ballots, youth_target)
  youth_valid <- youth_ballots * (1 - params$invalid_share / 100)
  youth_valid <- pmin(youth_valid, valid_votes)
  general_valid <- valid_votes - youth_valid

  votes <- base_shares * general_valid

  youth_alloc <- matrix(0, nrow = n, ncol = length(list_ids), dimnames = list(NULL, list_ids))
  if ("student" %in% list_ids) youth_alloc[, "student"] <- params$youth_student / 100
  if ("sns" %in% list_ids) youth_alloc[, "sns"] <- params$youth_sns / 100
  if ("sps" %in% list_ids) youth_alloc[, "sps"] <- params$youth_sps / 100

  other_ids <- setdiff(list_ids, c("student", "sns", "sps"))
  if (length(other_ids)) {
    other_base <- base_shares[, other_ids, drop = FALSE]
    rs <- rowSums(other_base)
    rs[rs <= 0] <- 1
    other_norm <- other_base / rs
    youth_alloc[, other_ids] <- other_norm * (params$youth_other / 100)
  } else {
    youth_alloc <- youth_alloc / pmax(rowSums(youth_alloc), 1e-9)
  }

  # Numerical guard if some principal lists are absent.
  youth_alloc <- youth_alloc / pmax(rowSums(youth_alloc), 1e-9)
  votes <- votes + youth_alloc * youth_valid

  # D'Hondt se primenjuje na broj glasova. Zaokruživanje se koriguje tako da
  # zbir po iteraciji ostane tačno jednak broju važećih listića.
  votes <- round(votes)
  diff <- as.integer(valid_votes - rowSums(votes))
  if (any(diff != 0)) {
    winner <- max.col(votes, ties.method = "first")
    idx <- cbind(seq_len(n), winner)
    votes[idx] <- votes[idx] + diff
  }

  list(
    votes = votes,
    ballots = ballots,
    invalid = invalid,
    valid_votes = valid_votes,
    youth_ballots = youth_ballots,
    youth_valid = youth_valid
  )
}
