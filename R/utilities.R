`%||%` <- function(x, y) if (is.null(x) || length(x) == 0 || (length(x) == 1 && is.na(x))) y else x

is_finite_scalar <- function(x) {
  is.numeric(x) && length(x) == 1L && !is.na(x) && is.finite(x)
}

clamp <- function(x, lo, hi) pmin(pmax(x, lo), hi)

normalize_vector <- function(x, target = 1) {
  x[!is.finite(x) | x < 0] <- 0
  s <- sum(x)
  if (s <= 0) stop("Nije moguće normalizovati vektor čiji je zbir nula.")
  x / s * target
}

row_softmax <- function(z) {
  mx <- apply(z, 1, max)
  ez <- exp(z - mx)
  ez / rowSums(ez)
}

rtruncnorm_base <- function(n, mean, sd, min, max) {
  if (sd <= 0) return(rep(clamp(mean, min, max), n))
  a <- pnorm((min - mean) / sd)
  b <- pnorm((max - mean) / sd)
  u <- runif(n, a, b)
  mean + sd * qnorm(u)
}

scaled_beta_draw <- function(n, lower, upper, mean_value, kappa = 20) {
  if (!is.finite(lower) || !is.finite(upper) || upper <= lower) return(rep(clamp(mean_value, 0, 1), n))
  m <- clamp((mean_value - lower) / (upper - lower), 1e-5, 1 - 1e-5)
  alpha <- max(m * kappa, 1e-4)
  beta <- max((1 - m) * kappa, 1e-4)
  lower + (upper - lower) * rbeta(n, alpha, beta)
}

nearest_psd_correlation <- function(R, eps = 1e-8) {
  original_dimnames <- dimnames(R)
  R <- (R + t(R)) / 2
  ev <- eigen(R, symmetric = TRUE)
  vals <- pmax(ev$values, eps)
  P <- ev$vectors %*% diag(vals, nrow = length(vals)) %*% t(ev$vectors)
  d <- sqrt(diag(P))
  P <- P / outer(d, d)
  diag(P) <- 1
  dimnames(P) <- original_dimnames
  P
}

pp_sd_to_logit_sd <- function(p, sd_pp) {
  p <- clamp(p, 1e-4, 1 - 1e-4)
  s <- pmax(sd_pp / 100, 1e-6)
  out <- s / (p * (1 - p))
  clamp(out, 0.01, 1.5)
}

scenario_hash <- function(x) {
  digest::digest(x, algo = "xxhash64")
}

fmt_pct <- function(x, digits = 1) sprintf(paste0("%.", digits, "f%%"), x)
fmt_int <- function(x) format(round(x), big.mark = ".", decimal.mark = ",", scientific = FALSE)
fmt_num <- function(x, digits = 2) format(round(x, digits), nsmall = digits, decimal.mark = ",", big.mark = ".")

make_tooltip_label <- function(label, tip) {
  shiny::tags$span(class = "has-tip", title = tip, label)
}

safe_filename <- function(x) {
  x <- iconv(x, to = "ASCII//TRANSLIT")
  x <- gsub("[^A-Za-z0-9_-]+", "_", x)
  gsub("_+", "_", x)
}

rebalance_composition <- function(values, changed, total = 100, digits = 1) {
  value_names <- names(values)
  values <- as.numeric(values)
  names(values) <- value_names
  if (
    length(values) < 2L ||
      length(changed) != 1L ||
      is.na(changed) ||
      !(changed %in% seq_along(values))
  ) {
    stop("Neispravna specifikacija raspodele.")
  }
  values[!is.finite(values)] <- 0
  values <- clamp(values, 0, total)
  remaining_idx <- setdiff(seq_along(values), changed)
  remaining_total <- total - values[changed]
  old_sum <- sum(values[remaining_idx])
  if (old_sum > 0) {
    values[remaining_idx] <- values[remaining_idx] / old_sum * remaining_total
  } else {
    values[remaining_idx] <- remaining_total / length(remaining_idx)
  }
  values <- round(values, digits)
  correction_idx <- tail(remaining_idx, 1)
  values[correction_idx] <- values[correction_idx] + total - sum(values)
  values
}

complete_composition_values <- function(values, expected_names) {
  if (!is.list(values) || !identical(names(values), expected_names)) return(NULL)
  valid <- vapply(values, function(x) {
    length(x) == 1L && is.numeric(x) && is.finite(x)
  }, logical(1))
  if (!all(valid)) return(NULL)
  out <- unlist(values, use.names = TRUE)
  names(out) <- expected_names
  out
}

hierarchical_youth_composition <- function(student, sns, sps, total = 100, digits = 1) {
  scalar_or_zero <- function(x) {
    if (is_finite_scalar(x)) as.numeric(x) else 0
  }
  requested <- c(
    student = scalar_or_zero(student),
    sns = scalar_or_zero(sns),
    sps = scalar_or_zero(sps)
  )

  student_value <- round(clamp(requested[["student"]], 0, total), digits)
  sns_max <- max(0, total - student_value)
  sns_value <- round(clamp(requested[["sns"]], 0, sns_max), digits)
  sps_max <- max(0, total - student_value - sns_value)
  sps_value <- round(clamp(requested[["sps"]], 0, sps_max), digits)
  other_value <- round(total - student_value - sns_value - sps_value, digits)

  c(
    student = student_value,
    sns = sns_value,
    sps = sps_value,
    other = other_value
  )
}

prepare_poll_upload <- function(d, template) {
  required <- c("poll_id", "pollster", "active", "weight")
  optional <- setdiff(names(template), required)
  missing_required <- setdiff(required, names(d))
  if (length(missing_required)) {
    return(list(data = NULL, error = paste0(
      "Nedostaju obavezne kolone: ", paste(missing_required, collapse = ", "), "."
    )))
  }
  for (nm in setdiff(optional, names(d))) d[[nm]] <- NA
  d <- d[, names(template), drop = FALSE]
  d$active <- suppressWarnings(as.logical(d$active))
  if (anyNA(d$active)) return(list(data = NULL, error = "Kolona active mora sadržati TRUE/FALSE ili 1/0."))
  if (anyDuplicated(d$poll_id)) return(list(data = NULL, error = "Kolona poll_id mora sadržati jedinstvene identifikatore."))
  list(data = d, error = NULL)
}

prepare_list_upload <- function(d, template) {
  required <- c("list_id", "name", "central_support", "active", "minority")
  defaults <- list(
    uncertainty_sd_pp = 1,
    tactical_target = "",
    baseline_transfer = 0,
    lower_transfer = 0,
    upper_transfer = 0,
    manual_shift_pp = 0,
    analytic_bloc = ""
  )
  missing_required <- setdiff(required, names(d))
  if (length(missing_required)) {
    return(list(data = NULL, error = paste0(
      "Nedostaju obavezne kolone: ", paste(missing_required, collapse = ", "), "."
    )))
  }
  for (nm in setdiff(names(defaults), names(d))) d[[nm]] <- defaults[[nm]]
  d <- d[, names(template), drop = FALSE]
  d$active <- suppressWarnings(as.logical(d$active))
  d$minority <- suppressWarnings(as.logical(d$minority))
  if (anyNA(d$active)) return(list(data = NULL, error = "Kolona active mora sadržati TRUE/FALSE ili 1/0."))
  if (anyNA(d$minority)) return(list(data = NULL, error = "Kolona minority mora sadržati TRUE/FALSE ili 1/0."))
  if (anyDuplicated(d$list_id)) return(list(data = NULL, error = "Kolona list_id mora sadržati jedinstvene identifikatore."))
  list(data = d, error = NULL)
}
