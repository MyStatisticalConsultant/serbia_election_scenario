pollster_correction_pp <- function(pollster) {
  out <- rep(0, length(pollster))
  out[grepl("NSPM", pollster, ignore.case = TRUE)] <- 1.2
  out[grepl("Faktor", pollster, ignore.case = TRUE)] <- -4.4
  out
}

weighted_mean_na <- function(x, w) {
  ok <- is.finite(x) & is.finite(w) & w > 0
  if (!any(ok)) return(NA_real_)
  sum(x[ok] * w[ok]) / sum(w[ok])
}

weighted_sd_na <- function(x, w) {
  ok <- is.finite(x) & is.finite(w) & w > 0
  if (sum(ok) < 2) return(NA_real_)
  x <- x[ok]; w <- w[ok] / sum(w[ok])
  mu <- sum(w * x)
  sqrt(sum(w * (x - mu)^2))
}

aggregate_polls <- function(polls, correction_strength = 1, exclude_nacija = FALSE) {
  p <- polls
  p$active <- as.logical(p$active)
  if (exclude_nacija) p$active[grepl("Nacija", p$pollster, ignore.case = TRUE)] <- FALSE
  p <- p[p$active & is.finite(p$weight) & p$weight > 0, , drop = FALSE]
  if (!nrow(p)) stop("Nema aktivnih anketa sa pozitivnim ponderom.")
  p$weight_norm <- p$weight / sum(p$weight)

  gov <- p$sns + p$sps
  corr <- pollster_correction_pp(p$pollster) * correction_strength
  gov_adj <- pmax(gov + corr, 0.01)
  sns_frac <- ifelse(gov > 0, p$sns / gov, 0.9)
  p$sns_adj <- gov_adj * sns_frac
  p$sps_adj <- gov_adj * (1 - sns_frac)

  estimates <- c(
    student = weighted_mean_na(p$student_list, p$weight_norm),
    sns = weighted_mean_na(p$sns_adj, p$weight_norm),
    sps = weighted_mean_na(p$sps_adj, p$weight_norm)
  )
  dispersion <- c(
    student = weighted_sd_na(p$student_list, p$weight_norm),
    sns = weighted_sd_na(p$sns_adj, p$weight_norm),
    sps = weighted_sd_na(p$sps_adj, p$weight_norm)
  )
  dispersion[!is.finite(dispersion)] <- c(student = 2, sns = 2, sps = 0.7)[names(dispersion)][!is.finite(dispersion)]
  list(estimates = estimates, dispersion = dispersion, polls_used = p)
}

build_central_support <- function(params, polls, lists) {
  active <- lists[as.logical(lists$active), , drop = FALSE]
  central <- setNames(active$central_support + active$manual_shift_pp, active$list_id)
  base_sd <- setNames(active$uncertainty_sd_pp, active$list_id)
  poll_details <- NULL

  if (params$central_source == "updated") {
    ag <- aggregate_polls(polls, params$pollster_correction_strength, params$exclude_nacija)
    poll_details <- ag
    if ("student" %in% names(central)) {
      central["student"] <- ag$estimates["student"] + active$manual_shift_pp[match("student", active$list_id)]
      base_sd["student"] <- max(ag$dispersion["student"], 0.5)
    }
    if (all(c("sns", "sps") %in% names(central))) {
      current_gov <- ag$estimates["sns"] + ag$estimates["sps"]
      expected_valid <- params$registered_voters * (params$turnout_mean / 100) * (1 - params$invalid_share / 100)
      prior_share <- 100 * params$historical_anchor_votes / expected_valid
      w <- params$current_poll_weight / 100
      blended_gov <- w * current_gov + (1 - w) * prior_share
      sns_frac <- ifelse(current_gov > 0, ag$estimates["sns"] / current_gov, 0.9)
      central["sns"] <- blended_gov * sns_frac + active$manual_shift_pp[match("sns", active$list_id)]
      central["sps"] <- blended_gov * (1 - sns_frac) + active$manual_shift_pp[match("sps", active$list_id)]
      base_sd["sns"] <- max(ag$dispersion["sns"], 0.5)
      base_sd["sps"] <- max(ag$dispersion["sps"], 0.3)
    }
  }

  # Residual electoral components are explicit simulator inputs.
  if ("other" %in% names(central)) central["other"] <- params$resid_other + active$manual_shift_pp[match("other", active$list_id)]
  if ("minority" %in% names(central)) central["minority"] <- params$resid_minority + active$manual_shift_pp[match("minority", active$list_id)]

  central[!is.finite(central) | central <= 0] <- 0.001
  list(central = central, base_sd = base_sd, active_lists = active, poll_details = poll_details)
}
