make_parameter_snapshot <- function(result) {
  p <- result$params
  residual_total <- p$resid_change + p$resid_other + p$resid_minority + p$resid_abstain + p$resid_unclassified
  rows <- list()
  add <- function(parameter, value, provenance) {
    rows[[length(rows) + 1]] <<- data.frame(
      Parametar = parameter,
      Vrednost = value,
      Poreklo = provenance,
      stringsAsFactors = FALSE
    )
  }

  add("Scenario", p$scenario_name, "Korisnička vrednost / scenario")
  add("Datum poslednjeg ažuriranja podataka", p$data_updated, "Korisnička vrednost")
  add("Izvor centralne podrške", ifelse(p$central_source == "updated", "Ažurirane ankete i model", "Rekonstruisana početna procena"), "Korisnička vrednost")
  add("Isključi Nacija TV", ifelse(isTRUE(p$exclude_nacija), "DA", "NE"), "Pretpostavka scenarija")
  add("Jačina korekcije efekta anketara", paste0(fmt_num(100 * p$pollster_correction_strength, 0), "%"), "Rekonstruisana vrednost / korisnički intenzitet")
  add("Težina aktuelnih anketa", paste0(fmt_num(p$current_poll_weight, 0), "%"), "Rekonstruisana vrednost")
  add("Broj upisanih birača", fmt_int(p$registered_voters), "Rekonstruisana / korisnička vrednost")
  add("Očekivana izlaznost", paste0(fmt_num(p$turnout_mean, 1), "%"), "Podatak / scenario")
  add("SD izlaznosti", paste0(fmt_num(p$turnout_sd, 1), " pp"), "Podatak / scenario")
  add("Referentna izlaznost", paste0(fmt_num(p$reference_turnout, 1), "%"), "Rekonstruisana / scenario vrednost")
  add("Minimalna modelom dozvoljena izlaznost", paste0(fmt_num(p$turnout_min, 1), "%"), "Nova specifikacija simulatora")
  add("Maksimalna modelom dozvoljena izlaznost", paste0(fmt_num(p$turnout_max, 1), "%"), "Nova specifikacija simulatora")
  add("Udeo nevažećih među svim glasačkim listićima", paste0(fmt_num(p$invalid_share, 1), "%"), "Rekonstruisana vrednost")
  add("Greška anketa u izbornom ciklusu – SD", paste0(fmt_num(p$election_cycle_sd, 1), " pp"), "Nova specifikacija simulatora")
  add("Fond mladih birača", fmt_int(p$youth_pool), "Podatak iz rekonstrukcije / scenario")
  add("Dodatno mobilisani mladi", paste0(fmt_num(p$youth_mobilised_pct, 1), "% od fonda"), "Pretpostavka scenarija")
  add("Raspodela mladih: Studentska lista", paste0(fmt_num(p$youth_student, 1), "%"), "Pretpostavka scenarija")
  add("Raspodela mladih: SNS", paste0(fmt_num(p$youth_sns, 1), "%"), "Pretpostavka scenarija")
  add("Raspodela mladih: SPS", paste0(fmt_num(p$youth_sps, 1), "%"), "Pretpostavka scenarija")
  add("Raspodela mladih: ostale liste", paste0(fmt_num(p$youth_other, 1), "%"), "Pretpostavka scenarija")
  add("Ostatak: neopredeljeni koji preferiraju promenu", paste0(fmt_num(p$resid_change, 2), "%"), "Tehnička početna vrednost")
  add("Ostatak: ostale nemanjinske liste", paste0(fmt_num(p$resid_other, 2), "%"), "Tehnička početna vrednost")
  add("Ostatak: manjinske liste", paste0(fmt_num(p$resid_minority, 2), "%"), "Tehnička početna vrednost")
  add("Ostatak: verovatna apstinencija", paste0(fmt_num(p$resid_abstain, 2), "%"), "Tehnička početna vrednost")
  add("Ostatak: nerazvrstano", paste0(fmt_num(p$resid_unclassified, 2), "%"), "Tehnička početna vrednost")
  add("Ukupan razloženi ostatak", paste0(fmt_num(residual_total, 2), "%"), "Izračunato")
  add("Transfer neopredeljenih – bazno", paste0(fmt_num(p$undecided_transfer_base, 1), "%"), "Pretpostavka iz rekonstrukcije")
  add("Raspon transfera neopredeljenih", paste0(fmt_num(p$undecided_transfer_low, 1), "–", fmt_num(p$undecided_transfer_high, 1), "%"), "Pretpostavka iz rekonstrukcije")
  add("Istorijsko SNS+SPS sidro", fmt_int(p$historical_anchor_votes), "Podatak iz izvornog dokumenta")
  add("Donja granica istorijskog sidra", fmt_int(p$historical_anchor_low), "Analitički zadat raspon")
  add("Gornja granica istorijskog sidra", fmt_int(p$historical_anchor_high), "Analitički zadat raspon")
  add("Koncentracija Beta raspodele istorijskog sidra", fmt_num(p$historical_kappa, 1), "Nova specifikacija simulatora")
  add("Koncentracija distribucije taktičkog transfera", fmt_num(p$tactical_kappa, 1), "Nova specifikacija simulatora")
  add("Osetljivost transfera na cenzus", fmt_num(p$threshold_gamma, 2), "Nova specifikacija simulatora")
  add("Širina zone oko cenzusa", paste0(fmt_num(p$threshold_width, 2), " pp"), "Nova specifikacija simulatora")
  add("Korelacija latentnih grešaka Studentska lista – SNS/SPS", fmt_num(p$major_bloc_corr, 2), "Nova specifikacija simulatora")
  add("Seed", as.character(p$seed), "Korisnička vrednost")
  add("Broj simulacija", fmt_int(p$n_sims), "Korisnička vrednost")
  add("ID scenarija", result$scenario_id, "Izračunato")
  do.call(rbind, rows)
}

make_results_table <- function(result) {
  s <- result$share_summary
  v <- result$vote_summary
  m <- result$seat_summary
  t <- result$threshold_summary
  d <- data.frame(
    list_id = s$list_id,
    name = s$name,
    share_med = s$median,
    share_l95 = s$q025,
    share_u95 = s$q975,
    votes_med = v$median[match(s$list_id, v$list_id)],
    seats_med = m$median[match(s$list_id, m$list_id)],
    seats_l95 = m$q025[match(s$list_id, m$list_id)],
    seats_u95 = m$q975[match(s$list_id, m$list_id)],
    minority = t$minority[match(s$list_id, t$list_id)],
    threshold_share = t$share_above_threshold[match(s$list_id, t$list_id)],
    stringsAsFactors = FALSE
  )
  data.frame(
    Lista = d$name,
    `Medijana glasova (%)` = round(d$share_med, 2),
    `95% interval glasova` = sprintf("%.2f–%.2f", d$share_l95, d$share_u95),
    `Medijana broja glasova` = round(d$votes_med),
    `Medijana mandata` = round(d$seats_med),
    `95% interval mandata` = sprintf("%.0f–%.0f", d$seats_l95, d$seats_u95),
    `Udeo iznad cenzusa (%)` = ifelse(d$minority, NA, round(d$threshold_share, 1)),
    check.names = FALSE
  )
}


make_interpretation <- function(result) {
  d <- result$share_summary
  turnout <- result$turnout_summary
  pieces <- c(
    sprintf("U izabranom scenariju medijana simulirane izlaznosti iznosi %.1f%%, dok se centralnih 50%% simulacija nalazi između %.1f%% i %.1f%%.", turnout[3], turnout[2], turnout[4])
  )

  preferred <- c("student", "sns", "sps")
  for (id in preferred[preferred %in% d$list_id]) {
    row <- d[d$list_id == id, , drop = FALSE]
    pieces <- c(pieces, sprintf("Za listu %s medijana simulirane podrške iznosi %.1f%%, uz 95%% interval scenarija od %.1f%% do %.1f%%.", row$name, row$median, row$q025, row$q975))
  }
  if (!is.null(result$gov_share)) {
    q <- quantile(result$gov_share, c(.025, .5, .975), names = FALSE)
    pieces <- c(pieces, sprintf("Kombinovani analitički zbir SNS+SPS ima medijanu %.1f%% i 95%% interval od %.1f%% do %.1f%%. Ovaj zbir je analitička kategorija i ne znači da su liste spojene u D'Hondt obračunu.", q[2], q[1], q[3]))
  }
  th <- result$threshold_summary[!result$threshold_summary$minority & is.finite(result$threshold_summary$share_above_threshold), , drop = FALSE]
  th <- th[th$share_above_threshold > 1 & th$share_above_threshold < 99, , drop = FALSE]
  if (nrow(th)) {
    txt <- paste(sprintf("%s %.1f%%", th$name, th$share_above_threshold), collapse = "; ")
    pieces <- c(pieces, paste0("Za obične liste sa neizvesnim statusom oko cenzusa, udeo iteracija iznad cenzusa je: ", txt, "."))
  }
  pieces <- c(pieces, "Rezultati predstavljaju modelsku posledicu izabranih pretpostavki, a ne tvrdnju da će se baš takav ishod ostvariti na izborima.")
  paste(pieces, collapse = "\n\n")
}


save_plot_png <- function(plot, filename, width = 9, height = 5.5) {
  ggplot2::ggsave(filename, plot = plot, width = width, height = height, units = "in", dpi = 300, bg = "white", device = ragg::agg_png)
}

build_word_report <- function(result, reference, path) {
  doc <- officer::read_docx()
  doc <- officer::body_add_par(doc, "Simulacija scenarija parlamentarnih izbora u Srbiji", style = "heading 1")
  doc <- officer::body_add_par(doc, paste("Generisano:", format(Sys.time(), "%d.%m.%Y. %H:%M")))
  doc <- officer::body_add_par(doc, paste("Scenario:", result$params$scenario_name))
  doc <- officer::body_add_par(doc, "Rezultati su uslovni na izabrane pretpostavke i ne predstavljaju novi uzorak javnog mnjenja niti bezuslovnu prognozu izbora.")

  doc <- officer::body_add_par(doc, "Parametri scenarija", style = "heading 2")
  ft <- flextable::flextable(make_parameter_snapshot(result))
  ft <- flextable::autofit(ft)
  doc <- flextable::body_add_flextable(doc, ft)

  doc <- officer::body_add_par(doc, "Rezultati", style = "heading 2")
  ft2 <- flextable::flextable(make_results_table(result))
  ft2 <- flextable::autofit(ft2)
  doc <- flextable::body_add_flextable(doc, ft2)
  bloc <- make_bloc_table(result)
  if (nrow(bloc)) {
    doc <- officer::body_add_par(doc, "Analitički blokovi", style = "heading 2")
    ftb <- flextable::flextable(bloc)
    ftb <- flextable::autofit(ftb)
    doc <- flextable::body_add_flextable(doc, ftb)
  }

  plots <- list(
    "Podrška listama" = plot_vote_intervals(result),
    "Mandati" = plot_seat_intervals(result),
    "Cenzus" = plot_threshold(result),
    "Izlaznost" = plot_turnout(result),
    "Poređenje scenarija" = plot_scenario_compare(result, reference)
  )
  for (nm in names(plots)) {
    f <- tempfile(fileext = ".png")
    save_plot_png(plots[[nm]], f)
    doc <- officer::body_add_par(doc, nm, style = "heading 2")
    doc <- officer::body_add_img(doc, src = f, width = 6.4, height = 4.0)
  }

  doc <- officer::body_add_par(doc, "Tumačenje", style = "heading 2")
  for (para in strsplit(make_interpretation(result), "\n\n", fixed = TRUE)[[1]]) doc <- officer::body_add_par(doc, para)

  doc <- officer::body_add_par(doc, "Metodološka napomena", style = "heading 2")
  doc <- officer::body_add_par(doc, paste(
    "Aplikacija reprodukuje dokumentovanu logiku rekonstruisanog BIRODI modela, dok su logističko-normalna raspodela, skalirane Beta distribucije i deo korelacione strukture nove statističke specifikacije uvedene radi transparentnog i izvršivog simulatora.",
    "Prag, tretman manjinskih lista i raspodela 250 mandata implementirani su prema pravilima Republičke izborne komisije važećim u vreme izrade aplikacije."
  ))
  doc <- officer::body_add_par(doc, paste("Seed:", result$params$seed, "| Broj simulacija:", result$params$n_sims, "| ID scenarija:", result$scenario_id))
  print(doc, target = path)
  invisible(path)
}

make_bloc_table <- function(result) {
  blocks <- result$lists$analytic_bloc
  ids <- result$lists$list_id
  keep <- !is.na(blocks) & nzchar(blocks)
  if (!any(keep)) return(data.frame())
  groups <- split(ids[keep], blocks[keep])
  rows <- lapply(names(groups), function(g) {
    cols <- intersect(groups[[g]], colnames(result$shares))
    if (!length(cols)) return(NULL)
    sh <- rowSums(result$shares[, cols, drop = FALSE])
    st <- rowSums(result$seats[, cols, drop = FALSE])
    qs <- quantile(sh, c(.025, .5, .975), names = FALSE)
    qm <- quantile(st, c(.025, .5, .975), names = FALSE)
    data.frame(
      Blok = g,
      `Medijana glasova (%)` = round(qs[2], 2),
      `95% interval glasova` = sprintf("%.2f–%.2f", qs[1], qs[3]),
      `Medijana mandata` = round(qm[2]),
      `95% interval mandata` = sprintf("%.0f–%.0f", qm[1], qm[3]),
      check.names = FALSE
    )
  })
  do.call(rbind, rows)
}
