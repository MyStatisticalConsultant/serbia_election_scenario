plot_vote_intervals <- function(result) {
  d <- result$share_summary
  d$name <- factor(d$name, levels = rev(d$name))
  ggplot2::ggplot(d, ggplot2::aes(y = name, x = median)) +
    ggplot2::geom_errorbar(ggplot2::aes(xmin = q025, xmax = q975), orientation = "y", width = .18, linewidth = .6) +
    ggplot2::geom_errorbar(ggplot2::aes(xmin = q25, xmax = q75), orientation = "y", width = .32, linewidth = 1.5) +
    ggplot2::geom_point(size = 2.5) +
    ggplot2::labs(x = "Udeo važećih glasova (%)", y = NULL,
                  title = "Simulirana raspodela podrške po listama",
                  subtitle = "Tačka = medijana; deblji interval = 50%; tanji interval = 95%") +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(panel.background = ggplot2::element_rect(fill = "white", colour = NA),
                   plot.background = ggplot2::element_rect(fill = "white", colour = NA))
}

plot_seat_intervals <- function(result) {
  d <- result$seat_summary
  d$name <- factor(d$name, levels = rev(d$name))
  ggplot2::ggplot(d, ggplot2::aes(y = name, x = median)) +
    ggplot2::geom_errorbar(ggplot2::aes(xmin = q025, xmax = q975), orientation = "y", width = .18, linewidth = .6) +
    ggplot2::geom_errorbar(ggplot2::aes(xmin = q25, xmax = q75), orientation = "y", width = .32, linewidth = 1.5) +
    ggplot2::geom_point(size = 2.5) +
    ggplot2::labs(x = "Broj mandata", y = NULL,
                  title = "Simulirana raspodela mandata",
                  subtitle = "Tačka = medijana; intervali prikazuju modelski raspon scenarija") +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(panel.background = ggplot2::element_rect(fill = "white", colour = NA),
                   plot.background = ggplot2::element_rect(fill = "white", colour = NA))
}

plot_threshold <- function(result) {
  d <- result$threshold_summary
  d <- d[!d$minority & is.finite(d$share_above_threshold), , drop = FALSE]
  if (!nrow(d)) return(ggplot2::ggplot() + ggplot2::theme_void() + ggplot2::labs(title = "Nema običnih lista za prikaz cenzusa"))
  d$name <- factor(d$name, levels = rev(d$name))
  ggplot2::ggplot(d, ggplot2::aes(x = share_above_threshold, y = name)) +
    ggplot2::geom_col(width = .65) +
    ggplot2::geom_text(ggplot2::aes(label = sprintf("%.1f%%", share_above_threshold)), hjust = -0.1, size = 3.5) +
    ggplot2::coord_cartesian(xlim = c(0, 105), clip = "off") +
    ggplot2::labs(x = "Udeo simulacija iznad izbornog cenzusa (%)", y = NULL,
                  title = "Prelazak izbornog cenzusa u simulacijama") +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(panel.background = ggplot2::element_rect(fill = "white", colour = NA),
                   plot.background = ggplot2::element_rect(fill = "white", colour = NA))
}

plot_turnout <- function(result) {
  d <- data.frame(turnout = result$turnout * 100)
  ggplot2::ggplot(d, ggplot2::aes(x = turnout)) +
    ggplot2::geom_histogram(bins = 40, boundary = 0) +
    ggplot2::labs(x = "Izlaznost (%)", y = "Broj simulacija", title = "Simulirana raspodela izlaznosti") +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(panel.background = ggplot2::element_rect(fill = "white", colour = NA),
                   plot.background = ggplot2::element_rect(fill = "white", colour = NA))
}

plot_tactical_curve <- function(params, baseline = .50, upper = .70) {
  x <- seq(0, 6, length.out = 250)
  y <- baseline + params$threshold_gamma * (upper - baseline) * plogis((3 - x) / params$threshold_width)
  d <- data.frame(support = x, transfer = y * 100)
  ggplot2::ggplot(d, ggplot2::aes(support, transfer)) +
    ggplot2::geom_line(linewidth = .9) +
    ggplot2::geom_vline(xintercept = 3, linetype = 2) +
    ggplot2::labs(x = "Simulirana podrška izvornoj listi (%)", y = "Efektivni transfer (%)",
                  title = "Kako blizina cenzusa menja taktički transfer",
                  subtitle = "Ilustracija za bazni transfer 50% i gornju granicu 70%") +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(panel.background = ggplot2::element_rect(fill = "white", colour = NA),
                   plot.background = ggplot2::element_rect(fill = "white", colour = NA))
}

plot_scenario_compare <- function(result, reference) {
  cur <- result$share_summary[, c("list_id", "name", "median")]
  names(cur)[3] <- "current"
  d <- merge(cur, reference[, c("list_id", "vote_share")], by = "list_id", all.x = TRUE)
  names(d)[names(d) == "vote_share"] <- "reference"
  d$delta <- d$current - d$reference
  d$name <- factor(d$name, levels = rev(d$name))
  ggplot2::ggplot(d, ggplot2::aes(x = delta, y = name)) +
    ggplot2::geom_col(width = .65) +
    ggplot2::geom_vline(xintercept = 0, linewidth = .5) +
    ggplot2::labs(x = "Razlika u procentnim poenima", y = NULL,
                  title = "Trenutni scenario u odnosu na referentni scenario",
                  subtitle = "Medijana trenutne simulacije minus deterministička centralna vrednost reference") +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(panel.background = ggplot2::element_rect(fill = "white", colour = NA),
                   plot.background = ggplot2::element_rect(fill = "white", colour = NA))
}
