mod_sidebar_ui <- function(id) {
  ns <- shiny::NS(id)
  bslib::sidebar(
    width = 430,
    shiny::dateInput(ns("data_updated"), make_tooltip_label("Datum poslednjeg ažuriranja podataka", "Datum do kog su korisnički polling i list podaci ažurirani. Izvorna metodološka rekonstrukcija ima presek 29.08.2026."), value = as.Date("2026-09-19"), format = "dd.mm.yyyy"),
    shiny::selectInput(ns("preset"), make_tooltip_label("Predefinisani scenario", "Skup transparentno definisanih početnih pretpostavki. Naziv scenarija opisuje pretpostavke, ne verovatnoću ishoda."),
      choices = c(
        "Rekonstruisana početna procena" = "reconstructed",
        "Bazni taktički transferi" = "base_tactical",
        "Visoka izlaznost i visoka konsolidacija" = "high_mob",
        "Niža taktička konsolidacija" = "low_tactical",
        "Veća neizvesnost anketa" = "high_uncertainty"
      ), selected = "reconstructed"
    ),
    shiny::uiOutput(ns("scenario_status")),
    shiny::uiOutput(ns("scenario_description")),
    shiny::p(class = "small-muted", "Izbor scenarija učitava njegove početne vrednosti. Ako ih ne želite menjati, odmah pritisnite ‘Pokreni simulaciju scenarija’. Detaljno objašnjenje svih kontrola nalazi se na tabu ‘Kako koristiti aplikaciju’."),
    shiny::actionButton(ns("reset_scenario"), "Resetuj izabrani scenario", width = "100%"),
    shiny::tags$hr(),
    bslib::accordion(
      open = c("Ankete i ponderi"),
      bslib::accordion_panel(
        "Ankete i ponderi",
        shiny::p(class = "small-muted", "Ova sekcija određuje da li centralne vrednosti dolaze iz rekonstrukcije ili iz aktivnih anketa. Tabelu menjate dvostrukim klikom na ćeliju."),
        shiny::radioButtons(ns("central_source"), make_tooltip_label("Izvor centralne podrške", "Birate da li se koriste rekonstruisane početne vrednosti ili ažurirana agregacija aktivnih anketa."),
          choices = c("Rekonstruisana početna procena" = "reconstructed", "Ažurirane ankete i model" = "updated"), selected = "reconstructed"
        ),
        shiny::checkboxInput(ns("exclude_nacija"), make_tooltip_label("Isključi Nacija TV", "Test osetljivosti. Ako je uključeno, ova anketa se izostavlja iz agregacije bez promene originalne tabele."), FALSE),
        shiny::sliderInput(ns("pollster_strength"), make_tooltip_label("Jačina korekcije efekta anketara", "0% = bez istorijske korekcije; 100% = puna rekonstruisana korekcija. Istorijska osnova je vrlo mala."), min = 0, max = 100, value = 100, step = 5, post = "%"),
        shiny::p(class = "small-muted", "Kolona active uključuje/isključuje anketu; weight određuje njen relativni uticaj. Procene za Studentsku listu, SNS i SPS ne moraju zajedno dati 100%, jer druge liste nisu prikazane u tabeli anketa. Ponderi se interno normalizuju među aktivnim anketama."),
        shiny::div(class = "table-frame", DT::DTOutput(ns("poll_table"))),
        shiny::uiOutput(ns("poll_weight_warning")),
        shiny::fluidRow(
          shiny::column(4, shiny::actionButton(ns("add_poll"), "Dodaj anketu", width = "100%")),
          shiny::column(4, shiny::actionButton(ns("delete_poll"), "Obriši izabranu", width = "100%")),
          shiny::column(4, shiny::actionButton(ns("norm_weights"), "Normalizuj pondere", width = "100%"))
        ),
        shiny::fileInput(ns("poll_upload"), "Uvezi ankete iz CSV", accept = ".csv"),
        shiny::downloadButton(ns("poll_template"), "Preuzmi CSV šablon")
      ),
      bslib::accordion_panel(
        "Podrška listama",
        shiny::p(class = "small-muted", "Tabela sadrži identitet liste, centralnu podršku, neizvesnost, status manjinske liste i taktičke transfere. Menja se dvostrukim klikom. Kod ažuriranih anketa vrednosti za Studentsku listu, SNS i SPS dolaze iz anketa, dok manual_shift_pp ostaje korisnička korekcija."),
        shiny::div(class = "table-frame", DT::DTOutput(ns("list_table"))),
        shiny::uiOutput(ns("list_support_note")),
        shiny::fluidRow(
          shiny::column(6, shiny::actionButton(ns("add_list"), "Dodaj listu", width = "100%")),
          shiny::column(6, shiny::actionButton(ns("delete_list"), "Obriši izabranu", width = "100%"))
        ),
        shiny::fileInput(ns("list_upload"), "Uvezi liste iz CSV", accept = ".csv"),
        shiny::downloadButton(ns("list_template"), "Preuzmi CSV šablon")
      ),
      bslib::accordion_panel(
        "Greška anketa i izborni ciklus",
        shiny::p(class = "small-muted", "Veća SD širi raspon mogućih ishoda, ali sama po sebi ne pomera centralni rezultat ka određenoj listi."),
        shiny::sliderInput(ns("election_sd"), make_tooltip_label("Greška anketa u izbornom ciklusu – SD", "Dodatna modelska neizvesnost zajednička izbornom ciklusu, odvojena od specifičnih efekata anketara. Nova specifikacija simulatora."), min = 0, max = 8, value = 2.5, step = .1, post = " pp")
      ),
      bslib::accordion_panel(
        "Izlaznost",
        shiny::p(class = "small-muted", "Očekivana izlaznost je centar raspodele, SD je njena neizvesnost, a referentna izlaznost razdvaja bazni od dodatno mobilisanog dela biračkog tela."),
        shiny::sliderInput(ns("turnout_mean"), make_tooltip_label("Očekivana izlaznost", "Sredina distribucije izlaznosti. Izvorna rekonstrukcija koristi 63,0% uz SD 1,5 pp."), min = 45, max = 75, value = 63, step = .1, post = "%"),
        shiny::sliderInput(ns("turnout_sd"), make_tooltip_label("SD izlaznosti", "Standardna devijacija simulirane izlaznosti. Postavite 0 za fiksnu izlaznost."), min = 0, max = 5, value = 1.5, step = .1, post = " pp"),
        shiny::sliderInput(ns("reference_turnout"), make_tooltip_label("Referentna izlaznost za marginalnu mobilizaciju", "Izlaznost iznad ove vrednosti formira marginalni fond birača u koji se najpre uključuje zadata mobilizacija mladih."), min = 45, max = 70, value = 62.3, step = .1, post = "%")
      ),
      bslib::accordion_panel(
        "Taktičko glasanje",
        shiny::p(class = "small-muted", "Ovi slajderi uređuju transfer posebno definisanog fonda neopredeljenih koji preferira promenu. Bazne stope i granice transfera sa manjih lista menjaju se u tabeli ‘Podrška listama’."),
        shiny::sliderInput(ns("undecided_transfer_base"), make_tooltip_label("Transfer neopredeljenih koji preferiraju promenu – bazno", "Bazna pretpostavka iz rekonstrukcije je 75%, ali se odnosi samo na posebno definisan deo neopredeljenih koji preferira političku promenu."), min = 0, max = 100, value = 75, step = 1, post = "%"),
        shiny::sliderInput(ns("undecided_transfer_range"), make_tooltip_label("Raspon transfera neopredeljenih", "Donja i gornja granica skalirane Beta raspodele. Izvorni scenario daje 60–90%."), min = 0, max = 100, value = c(60, 90), step = 1, post = "%")
      ),
      bslib::accordion_panel(
        "Mobilizacija mladih",
        shiny::p(class = "small-muted", "Prvo odredite potencijalni fond i procenat dodatno mobilisanih. Zatim redom podesite Studentsku listu, SNS i SPS. Svaki naredni slajder ima maksimum jednak preostalom procentu, dok se udeo ostalih lista računa automatski kao ostatak do 100%."),
        shiny::numericInput(ns("youth_pool"), make_tooltip_label("Fond mladih birača", "Potencijalni fond mladih koji bi mogli prvi put ili dodatno izaći. Rekonstrukcija navodi približno 913.000 mladih sa pravom glasa; procenat stvarno mobilisanih određuje sledeći slajder."), value = 913000, min = 0, max = 1500000, step = 1000),
        shiny::sliderInput(ns("youth_mobilised_pct"), make_tooltip_label("Dodatno mobilisani mladi", "Udeo fonda mladih koji se tretira kao dodatno mobilisan. Izvorni visoki scenario koristi približno 20%, odnosno oko 183.000 birača."), min = 0, max = 50, value = 0, step = 1, post = "%"),
        shiny::sliderInput(ns("youth_student"), make_tooltip_label("1. Studentska lista", "Prvi zadržani udeo. Njegova vrednost ostaje nepromenjena dok podešavate naredne liste; izvorni visoki scenario koristi 70%."), min = 0, max = 100, value = 70, step = .1, post = "%"),
        shiny::sliderInput(ns("youth_sns"), make_tooltip_label("2. SNS", "Drugi zadržani udeo. Maksimum je 100% minus udeo Studentske liste; izvorni visoki scenario koristi 18%."), min = 0, max = 30, value = 18, step = .1, post = "%"),
        shiny::sliderInput(ns("youth_sps"), make_tooltip_label("3. SPS", "Treći zadržani udeo. Maksimum je 100% minus udeli Studentske liste i SNS; izvorni visoki scenario koristi 2%."), min = 0, max = 12, value = 2, step = .1, post = "%"),
        shiny::div(
          class = "computed-share",
          shiny::div(class = "computed-share-label", make_tooltip_label("4. Ostale liste – automatski ostatak", "Automatski se računa kao 100% minus udeli Studentske liste, SNS i SPS. Ovaj procenat se ne podešava ručno.")),
          shiny::textOutput(ns("youth_other_value"), inline = TRUE)
        ),
        shiny::uiOutput(ns("youth_sum_note"))
      ),
      bslib::accordion_panel(
        "Manje i manjinske liste",
        shiny::p(class = "small-muted", "Pet polja razlaže izvorni ostatak od 4,28%. U rekonstruisanom scenariju njihov zbir mora ostati 4,28%. Status manjinske liste uređuje se u tabeli i ne zaključuje se iz naziva."),
        shiny::numericInput(ns("resid_change"), make_tooltip_label("Neopredeljeni koji preferiraju promenu (%)", "Tehnička početna vrednost simulatora; nije zasebno procenjena u izvornom dokumentu."), value = 1.00, min = 0, max = 10, step = .01),
        shiny::numericInput(ns("resid_other"), make_tooltip_label("Ostale nemanjinske liste (%)", "Tehnička početna vrednost simulatora unutar nerazvrstanog ostatka."), value = 1.28, min = 0, max = 10, step = .01),
        shiny::numericInput(ns("resid_minority"), make_tooltip_label("Manjinske liste (%)", "Tehnička početna vrednost simulatora. Manjinski status se zatim primenjuje samo na listu označenu kao manjinska."), value = 1.50, min = 0, max = 10, step = .01),
        shiny::numericInput(ns("resid_abstain"), make_tooltip_label("Verovatna apstinencija (%)", "Deo izvornog aritmetičkog ostatka koji se ne pretvara u glas za listu u ovom koraku."), value = .30, min = 0, max = 10, step = .01),
        shiny::numericInput(ns("resid_unclassified"), make_tooltip_label("Nerazvrstano (%)", "Preostali deo čija politička pripadnost nije poznata. Ne prenosi se mehanički nijednoj listi."), value = .20, min = 0, max = 10, step = .01)
      ),
      bslib::accordion_panel(
        "Napredni parametri",
        shiny::p(class = "small-muted", "Ove kontrole menjajte kada želite eksplicitan test osetljivosti. One utiču na pretvaranje anketa u glasove, širinu slučajnih raspodela, taktičke transfere i granice dozvoljenih simuliranih izlaznosti."),
        shiny::sliderInput(ns("current_poll_weight"), make_tooltip_label("Težina aktuelnih anketa", "U završnoj rekonstrukciji navedeno je približno 90–92%; 91% je sredina tog raspona. Preostali deo pripada istorijskom sidru."), min = 70, max = 100, value = 91, step = 1, post = "%"),
        shiny::numericInput(ns("registered_voters"), make_tooltip_label("Broj upisanih birača", "Tehnički parametar potreban za pretvaranje izlaznosti u broj glasačkih listića. Početna vrednost 6,44 miliona prati aritmetiku rekonstrukcije."), value = 6440000, min = 1000000, max = 10000000, step = 1000),
        shiny::sliderInput(ns("invalid_share"), make_tooltip_label("Udeo nevažećih listića", "Procenat svih glasačkih listića birača koji su glasali, ne procenat upisanih birača. Rekonstrukcija visokog scenarija implicira približno 1,3–1,5%; početna vrednost je 1,5%."), min = 0, max = 5, value = 1.5, step = .1, post = "%"),
        shiny::numericInput(ns("historical_anchor"), make_tooltip_label("Istorijsko SNS+SPS sidro – glasovi", "Aritmetička sredina 2022. i 2023. iz beleške iznosi približno 2.051.996 glasova."), value = 2051996, min = 1000000, max = 3000000, step = 1000),
        shiny::numericInput(ns("historical_low"), make_tooltip_label("Donja granica istorijskog sidra", "Donja granica nove skalirane Beta specifikacije. Polazi od približno 2,052 miliona minus 220.000 glasova."), value = 1832000, min = 500000, max = 3000000, step = 1000),
        shiny::numericInput(ns("historical_high"), make_tooltip_label("Gornja granica istorijskog sidra", "Gornja granica nove skalirane Beta specifikacije. Polazi od približno 2,052 miliona plus 220.000 glasova."), value = 2272000, min = 500000, max = 3500000, step = 1000),
        shiny::sliderInput(ns("historical_kappa"), make_tooltip_label("Koncentracija Beta raspodele istorijskog sidra", "Nova specifikacija simulatora. Veća vrednost znači jaču koncentraciju oko centralne vrednosti."), min = 5, max = 100, value = 20, step = 1),
        shiny::sliderInput(ns("tactical_kappa"), make_tooltip_label("Koncentracija distribucije taktičkog transfera", "Nova specifikacija simulatora. Više vrednosti znače da su slučajni transferi bliže baznim vrednostima."), min = 5, max = 100, value = 20, step = 1),
        shiny::sliderInput(ns("threshold_gamma"), make_tooltip_label("Osetljivost transfera na cenzus", "0 = nema dodatnog endogenog pojačanja; 1 = maksimalno pojačanje ka gornjoj granici kada je lista ispod/blizu 3%."), min = 0, max = 1, value = .5, step = .05),
        shiny::sliderInput(ns("threshold_width"), make_tooltip_label("Širina zone oko cenzusa", "Kontroliše koliko brzo se taktički transfer menja kada simulirana podrška prolazi kroz zonu oko 3%."), min = .1, max = 2, value = .6, step = .1, post = " pp"),
        shiny::sliderInput(ns("major_bloc_corr"), make_tooltip_label("Korelacija latentnih grešaka Studentska lista – SNS/SPS", "Nova specifikacija simulatora. Negativna vrednost predstavlja tendenciju da zajedničke greške dva glavna bloka idu u suprotnim smerovima. Matrica se numerički koriguje na najbližu pozitivno semidefinitnu matricu ako je potrebno."), min = -.9, max = 0, value = -.45, step = .05),
        shiny::numericInput(ns("turnout_min"), make_tooltip_label("Minimalna modelom dozvoljena izlaznost (%)", "Donja tehnička granica ograničene normalne raspodele; nije pravno ili administrativno propisana dozvola."), value = 45, min = 0, max = 100, step = 1),
        shiny::numericInput(ns("turnout_max"), make_tooltip_label("Maksimalna modelom dozvoljena izlaznost (%)", "Gornja tehnička granica ograničene normalne raspodele; nije pravno ili administrativno propisana dozvola."), value = 75, min = 0, max = 100, step = 1)
      ),
      bslib::accordion_panel(
        "Monte Carlo simulacija",
        shiny::p(class = "small-muted", "Seed omogućava ponavljanje identične simulacije. Za ispitivanje koristite manji broj iteracija, a za završni izveštaj veći."),
        shiny::numericInput(ns("seed"), make_tooltip_label("Seed", "Početna vrednost generatora slučajnih brojeva. Isti parametri i isti seed daju isti rezultat."), value = 12345, min = 1, max = 2147483646, step = 1),
        shiny::selectInput(ns("n_sims"), make_tooltip_label("Broj simulacija", "Više iteracija daje stabilnije Monte Carlo sažetke, ali zahteva više vremena."), choices = c("1.000" = 1000, "5.000" = 5000, "10.000" = 10000, "50.000" = 50000, "100.000" = 100000), selected = 10000)
      )
    ),
    shiny::tags$hr(),
    shiny::actionButton(ns("run"), "Pokreni simulaciju scenarija", class = "btn-primary", width = "100%")
  )
}

mod_sidebar_server <- function(id, default_polls, default_lists) {
  shiny::moduleServer(id, function(input, output, session) {
    presets <- scenario_presets()
    polls_rv <- shiny::reactiveVal(default_polls)
    lists_rv <- shiny::reactiveVal(default_lists)
    status_rv <- shiny::reactiveVal(presets$reconstructed$name)
    applying <- shiny::reactiveVal(FALSE)
    control_defaults <- scenario_control_defaults()
    youth_values <- shiny::reactiveVal(c(
      student = control_defaults$youth_student,
      sns = control_defaults$youth_sns,
      sps = control_defaults$youth_sps,
      other = control_defaults$youth_other
    ))

    poll_labels <- c(
      "ID ankete", "Anketar", "Period terenskog rada", "Veličina uzorka", "Način anketiranja",
      "Aktivna", "Ponder", "Studentska lista (%)", "SNS (%)", "SPS (%)"
    )
    list_view_columns <- c(
      "name", "list_id", "central_support", "uncertainty_sd_pp", "active", "minority",
      "tactical_target", "baseline_transfer", "lower_transfer", "upper_transfer",
      "manual_shift_pp", "analytic_bloc"
    )
    list_labels <- c(
      "Lista", "ID liste", "Centralna podrška (%)", "SD podrške (pp)", "Aktivna",
      "Manjinska", "Cilj transfera", "Bazni transfer (%)", "Donja granica (%)",
      "Gornja granica (%)", "Ručni pomak (pp)", "Analitički blok"
    )

    output$scenario_status <- shiny::renderUI({
      shiny::div(shiny::strong("Status: "), status_rv())
    })
    output$scenario_description <- shiny::renderUI({
      shiny::div(class = "scenario-note", presets[[input$preset]]$description)
    })

    output$poll_table <- DT::renderDT({
      DT::datatable(polls_rv(), selection = "single", editable = TRUE, rownames = FALSE,
                    colnames = poll_labels,
                    options = list(scrollX = TRUE, pageLength = 5, dom = "tip"))
    })
    output$list_table <- DT::renderDT({
      DT::datatable(lists_rv()[, list_view_columns, drop = FALSE], selection = "single", editable = TRUE, rownames = FALSE,
                    colnames = list_labels,
                    options = list(scrollX = TRUE, pageLength = 10, dom = "tip"))
    })
    output$poll_weight_warning <- shiny::renderUI({
      d <- polls_rv(); a <- as.logical(d$active) & is.finite(d$weight) & d$weight >= 0
      total <- sum(d$weight[a], na.rm = TRUE)
      if (abs(total - 100) > .01) shiny::div(class = "small-muted", paste0("Upozorenje: zbir pondera aktivnih anketa je ", round(total, 2), "%. U obračunu se ponderi interno normalizuju; dugme ‘Normalizuj pondere’ menja i tabelu."))
    })
    output$list_support_note <- shiny::renderUI({
      d <- lists_rv()
      total <- sum(d$central_support[as.logical(d$active)], na.rm = TRUE)
      shiny::div(
        class = "small-muted",
        paste0(
          "Zbir kolone central_support za aktivne liste trenutno iznosi ", round(total, 2),
          "%. Simulator konačne aktivne podrške normalizuje na 100% nakon primene eksplicitnih ostataka, ručnih pomaka i drugih izabranih pravila."
        )
      )
    })
    output$youth_sum_note <- shiny::renderUI({
      total <- sum(youth_values())
      shiny::div(class = "small-muted", paste0("Automatski kontrolisan zbir četiri udela: ", round(total, 1), "%."))
    })
    output$youth_other_value <- shiny::renderText({
      sprintf("%.1f%%", youth_values()[["other"]])
    })

    mark_custom <- function() if (!isTRUE(applying())) status_rv("Korisnički scenario")

    shiny::observeEvent(input$poll_table_cell_edit, {
      info <- input$poll_table_cell_edit
      d <- polls_rv()
      d[info$row, info$col] <- DT::coerceValue(info$value, d[info$row, info$col])
      polls_rv(d); mark_custom()
    })
    shiny::observeEvent(input$list_table_cell_edit, {
      info <- input$list_table_cell_edit
      d <- lists_rv()
      source_col <- list_view_columns[[info$col]]
      d[info$row, source_col] <- DT::coerceValue(info$value, d[info$row, source_col])
      lists_rv(d); mark_custom()
    })

    shiny::observeEvent(input$add_poll, {
      d <- polls_rv(); i <- nrow(d) + 1
      new <- d[1, , drop = FALSE]
      new[1, ] <- NA
      new$poll_id <- paste0("poll", i); new$pollster <- paste("Nova anketa", i); new$active <- TRUE; new$weight <- 0
      d <- rbind(d, new); polls_rv(d); mark_custom()
    })
    shiny::observeEvent(input$delete_poll, {
      sel <- input$poll_table_rows_selected
      if (length(sel) == 1 && nrow(polls_rv()) > 1) polls_rv(polls_rv()[-sel, , drop = FALSE])
      mark_custom()
    })
    shiny::observeEvent(input$norm_weights, {
      d <- polls_rv(); a <- as.logical(d$active) & is.finite(d$weight) & d$weight >= 0
      if (any(a) && sum(d$weight[a]) > 0) d$weight[a] <- 100 * d$weight[a] / sum(d$weight[a])
      polls_rv(d); mark_custom()
    })


    shiny::observeEvent(input$poll_upload, {
      shiny::req(input$poll_upload$datapath)
      d <- tryCatch(read.csv(input$poll_upload$datapath, stringsAsFactors = FALSE, check.names = FALSE), error = function(e) NULL)
      prepared <- if (is.null(d)) list(data = NULL, error = "CSV fajl nije moguće pročitati.") else prepare_poll_upload(d, default_polls)
      if (is.null(prepared$data)) {
        shiny::showNotification(paste(prepared$error, "Proverite objašnjenje i šablon na tabu ‘Kako koristiti aplikaciju’."), type = "error")
      } else {
        polls_rv(prepared$data); mark_custom()
      }
    })
    output$poll_template <- shiny::downloadHandler(
      filename = function() "sablon_ankete.csv",
      content = function(file) write.csv(default_polls, file, row.names = FALSE, na = "")
    )

    shiny::observeEvent(input$list_upload, {
      shiny::req(input$list_upload$datapath)
      d <- tryCatch(read.csv(input$list_upload$datapath, stringsAsFactors = FALSE, check.names = FALSE), error = function(e) NULL)
      prepared <- if (is.null(d)) list(data = NULL, error = "CSV fajl nije moguće pročitati.") else prepare_list_upload(d, default_lists)
      if (is.null(prepared$data)) {
        shiny::showNotification(paste(prepared$error, "Proverite objašnjenje i šablon na tabu ‘Kako koristiti aplikaciju’."), type = "error")
      } else {
        lists_rv(prepared$data); mark_custom()
      }
    })
    output$list_template <- shiny::downloadHandler(
      filename = function() "sablon_izborne_liste.csv",
      content = function(file) write.csv(default_lists, file, row.names = FALSE, na = "")
    )
    shiny::observeEvent(input$add_list, {
      d <- lists_rv(); i <- nrow(d) + 1
      new <- d[1, , drop = FALSE]
      new$list_id <- paste0("list", i); new$name <- paste("Nova lista", i); new$central_support <- 1
      new$uncertainty_sd_pp <- 1; new$active <- TRUE; new$minority <- FALSE; new$tactical_target <- ""
      new$baseline_transfer <- 0; new$lower_transfer <- 0; new$upper_transfer <- 0; new$manual_shift_pp <- 0; new$analytic_bloc <- "Ostalo"
      lists_rv(rbind(d, new)); mark_custom()
    })
    shiny::observeEvent(input$delete_list, {
      sel <- input$list_table_rows_selected
      if (length(sel) == 1 && nrow(lists_rv()) > 1) lists_rv(lists_rv()[-sel, , drop = FALSE])
      mark_custom()
    })

    apply_preset <- function(id) {
      applying(TRUE)
      pr <- presets[[id]]
      dflt <- control_defaults
      freeze_ids <- c(
        "data_updated", "central_source", "exclude_nacija", "turnout_mean", "turnout_sd",
        "reference_turnout", "election_sd", "pollster_strength", "undecided_transfer_base",
        "undecided_transfer_range", "youth_pool", "current_poll_weight", "threshold_gamma",
        "tactical_kappa", "youth_mobilised_pct", "youth_student", "youth_sns", "youth_sps",
        "resid_change", "resid_other", "resid_minority", "resid_abstain",
        "resid_unclassified", "registered_voters", "invalid_share", "historical_anchor",
        "historical_low", "historical_high", "historical_kappa", "threshold_width",
        "major_bloc_corr", "turnout_min", "turnout_max", "seed", "n_sims"
      )
      lapply(freeze_ids, function(input_id) shiny::freezeReactiveValue(input, input_id))
      polls_rv(default_polls)
      lists_rv(apply_preset_to_lists(default_lists, id))
      youth_values(c(
        student = dflt$youth_student,
        sns = dflt$youth_sns,
        sps = dflt$youth_sps,
        other = dflt$youth_other
      ))
      shiny::updateDateInput(session, "data_updated", value = dflt$data_updated)
      shiny::updateRadioButtons(session, "central_source", selected = pr$central_source)
      shiny::updateCheckboxInput(session, "exclude_nacija", value = dflt$exclude_nacija)
      shiny::updateSliderInput(session, "turnout_mean", value = pr$turnout_mean)
      shiny::updateSliderInput(session, "turnout_sd", value = pr$turnout_sd)
      shiny::updateSliderInput(session, "reference_turnout", value = pr$reference_turnout)
      shiny::updateSliderInput(session, "election_sd", value = pr$election_cycle_sd)
      shiny::updateSliderInput(session, "pollster_strength", value = 100 * pr$pollster_correction_strength)
      shiny::updateSliderInput(session, "undecided_transfer_base", value = dflt$undecided_transfer_base)
      shiny::updateSliderInput(session, "undecided_transfer_range", value = dflt$undecided_transfer_range)
      shiny::updateNumericInput(session, "youth_pool", value = dflt$youth_pool)
      shiny::updateSliderInput(session, "current_poll_weight", value = pr$current_poll_weight)
      shiny::updateSliderInput(session, "threshold_gamma", value = pr$threshold_gamma)
      shiny::updateSliderInput(session, "tactical_kappa", value = pr$tactical_kappa)
      shiny::updateSliderInput(session, "youth_mobilised_pct", value = pr$youth_mobilised_pct)
      shiny::updateSliderInput(session, "youth_student", value = dflt$youth_student)
      shiny::updateSliderInput(session, "youth_sns", max = 100 - dflt$youth_student, value = dflt$youth_sns)
      shiny::updateSliderInput(session, "youth_sps", max = 100 - dflt$youth_student - dflt$youth_sns, value = dflt$youth_sps)
      shiny::updateNumericInput(session, "resid_change", value = dflt$resid_change)
      shiny::updateNumericInput(session, "resid_other", value = dflt$resid_other)
      shiny::updateNumericInput(session, "resid_minority", value = dflt$resid_minority)
      shiny::updateNumericInput(session, "resid_abstain", value = dflt$resid_abstain)
      shiny::updateNumericInput(session, "resid_unclassified", value = dflt$resid_unclassified)
      shiny::updateNumericInput(session, "registered_voters", value = dflt$registered_voters)
      shiny::updateSliderInput(session, "invalid_share", value = dflt$invalid_share)
      shiny::updateNumericInput(session, "historical_anchor", value = dflt$historical_anchor)
      shiny::updateNumericInput(session, "historical_low", value = dflt$historical_low)
      shiny::updateNumericInput(session, "historical_high", value = dflt$historical_high)
      shiny::updateSliderInput(session, "historical_kappa", value = dflt$historical_kappa)
      shiny::updateSliderInput(session, "threshold_width", value = dflt$threshold_width)
      shiny::updateSliderInput(session, "major_bloc_corr", value = dflt$major_bloc_corr)
      shiny::updateNumericInput(session, "turnout_min", value = dflt$turnout_min)
      shiny::updateNumericInput(session, "turnout_max", value = dflt$turnout_max)
      shiny::updateNumericInput(session, "seed", value = dflt$seed)
      shiny::updateSelectInput(session, "n_sims", selected = as.character(dflt$n_sims))
      status_rv(pr$name)
      session$onFlushed(function() {
        applying(FALSE)
      }, once = TRUE)
    }

    shiny::observeEvent(input$preset, { apply_preset(input$preset) }, ignoreInit = TRUE)
    shiny::observeEvent(input$reset_scenario, { apply_preset(input$preset) })

    update_youth_hierarchy <- function(changed_name) {
      if (isTRUE(applying())) return()
      previous <- youth_values()
      student <- input$youth_student %||% previous[["student"]]
      sns <- input$youth_sns %||% previous[["sns"]]
      sps <- input$youth_sps %||% previous[["sps"]]
      values <- hierarchical_youth_composition(student, sns, sps, total = 100, digits = 1)
      youth_values(values)

      sns_max <- 100 - values[["student"]]
      sps_max <- 100 - values[["student"]] - values[["sns"]]
      if (identical(changed_name, "student")) {
        shiny::freezeReactiveValue(input, "youth_sns")
        shiny::updateSliderInput(session, "youth_sns", max = sns_max, value = values[["sns"]])
      }
      if (changed_name %in% c("student", "sns")) {
        shiny::freezeReactiveValue(input, "youth_sps")
        shiny::updateSliderInput(session, "youth_sps", max = sps_max, value = values[["sps"]])
      }
    }

    shiny::observeEvent(input$youth_student, update_youth_hierarchy("student"), ignoreInit = TRUE)
    shiny::observeEvent(input$youth_sns, update_youth_hierarchy("sns"), ignoreInit = TRUE)
    shiny::observeEvent(input$youth_sps, update_youth_hierarchy("sps"), ignoreInit = TRUE)

    watched <- shiny::reactive({
      list(input$data_updated, input$central_source, input$exclude_nacija, input$pollster_strength, input$election_sd,
           input$turnout_mean, input$turnout_sd, input$reference_turnout, input$undecided_transfer_base,
           input$undecided_transfer_range, input$youth_pool, input$youth_mobilised_pct, youth_values(),
           input$resid_change, input$resid_other,
           input$resid_minority, input$resid_abstain, input$resid_unclassified, input$current_poll_weight,
           input$registered_voters, input$invalid_share, input$historical_anchor, input$historical_low,
           input$historical_high, input$historical_kappa, input$tactical_kappa, input$threshold_gamma,
           input$threshold_width, input$major_bloc_corr, input$turnout_min, input$turnout_max, input$seed, input$n_sims)
    })
    shiny::observeEvent(watched(), { mark_custom() }, ignoreInit = TRUE)

    params <- shiny::reactive({
      rng <- input$undecided_transfer_range %||% c(60, 90)
      youth <- youth_values()
      list(
        preset_id = input$preset,
        data_updated = as.character(input$data_updated),
        scenario_name = status_rv(),
        scenario_description = if (identical(status_rv(), "Korisnički scenario")) paste0("Korisnički scenario izveden iz predefinisanog polazišta ‘", presets[[input$preset]]$name, "’. ", presets[[input$preset]]$description) else presets[[input$preset]]$description,
        central_source = input$central_source,
        exclude_nacija = isTRUE(input$exclude_nacija),
        pollster_correction_strength = input$pollster_strength / 100,
        election_cycle_sd = input$election_sd,
        turnout_mean = input$turnout_mean,
        turnout_sd = input$turnout_sd,
        reference_turnout = input$reference_turnout,
        turnout_min = input$turnout_min,
        turnout_max = input$turnout_max,
        invalid_share = input$invalid_share,
        undecided_transfer_base = input$undecided_transfer_base,
        undecided_transfer_low = rng[1],
        undecided_transfer_high = rng[2],
        youth_pool = input$youth_pool,
        youth_mobilised_pct = input$youth_mobilised_pct,
        youth_student = unname(youth[["student"]]),
        youth_sns = unname(youth[["sns"]]),
        youth_sps = unname(youth[["sps"]]),
        youth_other = unname(youth[["other"]]),
        resid_change = input$resid_change,
        resid_other = input$resid_other,
        resid_minority = input$resid_minority,
        resid_abstain = input$resid_abstain,
        resid_unclassified = input$resid_unclassified,
        current_poll_weight = input$current_poll_weight,
        registered_voters = input$registered_voters,
        historical_anchor_votes = input$historical_anchor,
        historical_anchor_low = input$historical_low,
        historical_anchor_high = input$historical_high,
        historical_kappa = input$historical_kappa,
        tactical_kappa = input$tactical_kappa,
        threshold_gamma = input$threshold_gamma,
        threshold_width = input$threshold_width,
        major_bloc_corr = input$major_bloc_corr,
        seed = as.integer(input$seed),
        n_sims = as.integer(input$n_sims),
        n_seats = 250L,
        data_cutoff = "29.08.2026. za izvornu metodološku rekonstrukciju; korisničke ankete mogu biti novije",
        app_version = "0.2.4"
      )
    })

    list(
      params = params,
      polls = shiny::reactive(polls_rv()),
      lists = shiny::reactive(lists_rv()),
      run = shiny::reactive(input$run),
      status = shiny::reactive(status_rv())
    )
  })
}
