mod_results_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::div(class = "intro-box",
      "Ovi rezultati prikazuju raspodelu ishoda nastalu ponovljenom simulacijom izbornog procesa pod trenutno izabranim pretpostavkama. Oni nisu isto što i rezultat ankete niti predstavljaju bezuslovnu prognozu izbora."
    ),
    shiny::uiOutput(ns("stale_note")),
    shiny::uiOutput(ns("run_header")),
    shiny::uiOutput(ns("summary_boxes")),
    shiny::h3("Glasovi"),
    shiny::div(class = "plot-frame", shiny::plotOutput(ns("vote_plot"), width = "100%", height = "480px")),
    shiny::downloadButton(ns("dl_vote"), "Preuzmi PNG"),
    shiny::h3("Mandati"),
    shiny::div(class = "plot-frame", shiny::plotOutput(ns("seat_plot"), width = "100%", height = "480px")),
    shiny::downloadButton(ns("dl_seat"), "Preuzmi PNG"),
    shiny::h3("Izborni cenzus"),
    shiny::div(class = "plot-frame", shiny::plotOutput(ns("threshold_plot"), width = "100%", height = "450px")),
    shiny::downloadButton(ns("dl_threshold"), "Preuzmi PNG"),
    shiny::h3("Izlaznost"),
    shiny::div(class = "plot-frame", shiny::plotOutput(ns("turnout_plot"), width = "100%", height = "380px")),
    shiny::downloadButton(ns("dl_turnout"), "Preuzmi PNG"),
    shiny::h3("Poređenje sa referentnim scenarijem"),
    shiny::div(class = "plot-frame", shiny::plotOutput(ns("compare_plot"), width = "100%", height = "450px")),
    shiny::downloadButton(ns("dl_compare"), "Preuzmi PNG"),
    shiny::h3("Numerički rezultati"),
    shiny::div(class = "table-frame", DT::DTOutput(ns("results_table"))),
    shiny::h3("Analitički blokovi"),
    shiny::p(class = "small-muted", "Blok je samo zbir korisnički označenih lista; ne utiče na D’Hondt osim ako su liste zaista modelovane kao jedna izborna lista."),
    shiny::div(class = "table-frame", DT::DTOutput(ns("blocs_table"))),
    shiny::h3("Parametri korišćeni u poslednjoj simulaciji"),
    shiny::div(class = "table-frame", DT::DTOutput(ns("active_params"))),
    shiny::h3("Tumačenje"),
    shiny::uiOutput(ns("interpretation")),
    shiny::tags$hr(),
    shiny::downloadButton(ns("dl_report"), "Preuzmi kompletan izveštaj – Word", class = "btn-primary")
  )
}

mod_results_server <- function(id, result_r, reference_r, stale_r) {
  shiny::moduleServer(id, function(input, output, session) {
    output$stale_note <- shiny::renderUI({
      if (isTRUE(stale_r())) shiny::div(class = "stale-note", "Parametri su promenjeni. Rezultati ispod i dalje pripadaju prethodno pokrenutom scenariju. Pritisnite ‘Pokreni simulaciju scenarija’ da biste izračunali nove rezultate.")
    })

    output$run_header <- shiny::renderUI({
      r <- result_r(); shiny::req(r)
      shiny::div(
        shiny::h2(r$params$scenario_name),
        shiny::p(r$params$scenario_description),
        shiny::p(class = "small-muted",
          paste0("Seed: ", r$params$seed, " | Simulacije: ", fmt_int(r$params$n_sims),
                 " | Podaci ažurirani: ", r$params$data_updated,
                 " | ID scenarija: ", r$scenario_id,
                 " | Verzija aplikacije: ", r$params$app_version)
        )
      )
    })

    output$summary_boxes <- shiny::renderUI({
      r <- result_r(); shiny::req(r)
      turnout_med <- r$turnout_summary[3]
      valid_med <- median(r$valid_votes)
      bslib::layout_columns(
        bslib::value_box(title = "Medijana izlaznosti", value = sprintf("%.1f%%", turnout_med)),
        bslib::value_box(title = "Medijana važećih glasova", value = fmt_int(valid_med)),
        bslib::value_box(title = "Broj aktivnih lista", value = nrow(r$lists)),
        col_widths = c(4, 4, 4)
      )
    })

    # Stabilne minimalne dimenzije grafičkog uređaja sprečavaju crtanje u
    # premalom uređaju kada se tab prvi put otvori ili prozor brzo promeni.
    # HTML izlaz i dalje ostaje responzivan jer plotOutput koristi širinu 100%.
    output$vote_plot <- shiny::renderPlot({
      shiny::req(result_r())
      print(plot_vote_intervals(result_r()))
    }, width = 1000, height = 480, res = 110)
    output$seat_plot <- shiny::renderPlot({
      shiny::req(result_r())
      print(plot_seat_intervals(result_r()))
    }, width = 1000, height = 480, res = 110)
    output$threshold_plot <- shiny::renderPlot({
      shiny::req(result_r())
      print(plot_threshold(result_r()))
    }, width = 1000, height = 450, res = 110)
    output$turnout_plot <- shiny::renderPlot({
      shiny::req(result_r())
      print(plot_turnout(result_r()))
    }, width = 1000, height = 380, res = 110)
    output$compare_plot <- shiny::renderPlot({
      shiny::req(result_r(), reference_r())
      print(plot_scenario_compare(result_r(), reference_r()))
    }, width = 1000, height = 450, res = 110)

    output$results_table <- DT::renderDT({
      shiny::req(result_r())
      DT::datatable(make_results_table(result_r()), rownames = FALSE, options = list(scrollX = TRUE, pageLength = 15))
    })
    output$blocs_table <- DT::renderDT({
      shiny::req(result_r())
      d <- make_bloc_table(result_r())
      DT::datatable(d, rownames = FALSE, options = list(dom = "tip", pageLength = 10))
    })
    output$active_params <- DT::renderDT({
      shiny::req(result_r())
      DT::datatable(make_parameter_snapshot(result_r()), rownames = FALSE, options = list(dom = "tip", pageLength = 20, scrollX = TRUE))
    })

    output$interpretation <- shiny::renderUI({
      r <- result_r(); shiny::req(r)
      paras <- strsplit(make_interpretation(r), "\n\n", fixed = TRUE)[[1]]
      shiny::tagList(lapply(paras, shiny::p))
    })

    make_dl <- function(plot_fun, stem) {
      shiny::downloadHandler(
        filename = function() paste0(safe_filename(result_r()$params$scenario_name), "_", stem, ".png"),
        content = function(file) save_plot_png(plot_fun(), file)
      )
    }
    output$dl_vote <- make_dl(function() plot_vote_intervals(result_r()), "glasovi")
    output$dl_seat <- make_dl(function() plot_seat_intervals(result_r()), "mandati")
    output$dl_threshold <- make_dl(function() plot_threshold(result_r()), "cenzus")
    output$dl_turnout <- make_dl(function() plot_turnout(result_r()), "izlaznost")
    output$dl_compare <- make_dl(function() plot_scenario_compare(result_r(), reference_r()), "poredjenje")

    output$dl_report <- shiny::downloadHandler(
      filename = function() paste0("Simulacija_scenarija_", safe_filename(result_r()$params$scenario_name), ".docx"),
      content = function(file) build_word_report(result_r(), reference_r(), file)
    )
  })
}
