apply_tactical_transfers <- function(shares, active_lists, params) {
  ids <- colnames(shares)
  n <- nrow(shares)
  transfer_log <- list()

  for (i in seq_len(nrow(active_lists))) {
    src <- active_lists$list_id[i]
    tgt <- active_lists$tactical_target[i]
    if (is.na(tgt) || !nzchar(tgt) || !(src %in% ids) || !(tgt %in% ids)) next

    lo <- active_lists$lower_transfer[i] / 100
    hi <- active_lists$upper_transfer[i] / 100
    mu <- active_lists$baseline_transfer[i] / 100
    if (hi <= lo || mu <= 0) next

    base_draw <- scaled_beta_draw(n, lo, hi, mu, params$tactical_kappa)
    support_pct <- shares[, src] * 100
    pressure <- plogis((3 - support_pct) / params$threshold_width)
    eff <- base_draw + params$threshold_gamma * (hi - base_draw) * pressure
    eff <- clamp(eff, lo, hi)

    amount <- shares[, src] * eff
    shares[, src] <- shares[, src] - amount
    shares[, tgt] <- shares[, tgt] + amount
    transfer_log[[src]] <- eff
  }

  # Anti-government/change-oriented undecided pool is not the entire 4.28% residual.
  if ("student" %in% ids && params$resid_change > 0) {
    lo <- params$undecided_transfer_low / 100
    hi <- params$undecided_transfer_high / 100
    mu <- params$undecided_transfer_base / 100
    rate <- scaled_beta_draw(n, lo, hi, mu, params$tactical_kappa)
    add <- (params$resid_change / 100) * rate
    shares[, "student"] <- shares[, "student"] + add
    shares <- shares / rowSums(shares)
    transfer_log[["undecided_change"]] <- rate
  }

  list(shares = shares, transfer_log = transfer_log)
}
