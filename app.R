required_packages <- c(
  "shiny", "bslib", "DT", "dplyr", "ggplot2", "scales", "MASS",
  "officer", "flextable", "ragg", "digest"
)
missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages)) {
  stop("Nedostaju R paketi: ", paste(missing_packages, collapse = ", "),
       ". Instalirajte ih komandom install.packages(c(",
       paste(sprintf("'%s'", missing_packages), collapse = ", "), ")).")
}

library(shiny)
library(bslib)

r_files <- list.files("R", pattern = "\\.R$", full.names = TRUE)
for (f in r_files) source(f, local = FALSE)

default_polls <- read.csv(file.path("data", "default_polls.csv"), stringsAsFactors = FALSE, check.names = FALSE)
default_lists <- read.csv(file.path("data", "default_lists.csv"), stringsAsFactors = FALSE, check.names = FALSE)

default_polls$active <- as.logical(default_polls$active)
default_lists$active <- as.logical(default_lists$active)
default_lists$minority <- as.logical(default_lists$minority)

ui <- bslib::page_sidebar(
  title = "Simulator izbornih scenarija – parlamentarni izbori u Srbiji",
  theme = bslib::bs_theme(version = 5, bg = "#ffffff", fg = "#222222", primary = "#34506b"),
  # Sadržaj tabova je duži od visine prozora i treba normalno da se skroluje.
  # fillable = TRUE može privremeno dati grafikonu veoma malu/nultu širinu dok
  # se skriveni tab aktivira, što na pojedinim kombinacijama Shiny/bslib verzija
  # izaziva poruku "figure margins too large".
  fillable = FALSE,
  sidebar = mod_sidebar_ui("controls"),
  shiny::tags$head(
    shiny::tags$link(rel = "stylesheet", type = "text/css", href = "app.css")
  ),
  bslib::navset_card_tab(
    bslib::nav_panel("Rezultati", mod_results_ui("results")),
    bslib::nav_panel("Parametri scenarija", mod_parameters_ui("parameters")),
    bslib::nav_panel("Metodologija", mod_methodology_ui("methodology")),
    bslib::nav_panel("Kako koristiti aplikaciju", mod_instructions_ui("instructions"))
  )
)

server <- function(input, output, session) {
  side <- mod_sidebar_server("controls", default_polls, default_lists)
  last_result <- shiny::reactiveVal(NULL)
  last_reference <- shiny::reactiveVal(NULL)
  last_hash <- shiny::reactiveVal(NULL)

  current_hash <- shiny::reactive({
    scenario_hash(list(params = side$params(), polls = side$polls(), lists = side$lists()))
  })

  stale <- shiny::reactive({
    if (is.null(last_result()) || is.null(last_hash())) return(FALSE)
    !identical(current_hash(), last_hash())
  })

  preset_reference_params <- function(current_params) {
    pr <- scenario_presets()[[current_params$preset_id]]
    p <- current_params
    p$scenario_name <- pr$name
    p$scenario_description <- pr$description
    p$central_source <- pr$central_source
    p$turnout_mean <- pr$turnout_mean
    p$turnout_sd <- pr$turnout_sd
    p$reference_turnout <- pr$reference_turnout
    p$election_cycle_sd <- pr$election_cycle_sd
    p$pollster_correction_strength <- pr$pollster_correction_strength
    p$current_poll_weight <- pr$current_poll_weight
    p$threshold_gamma <- pr$threshold_gamma
    p$tactical_kappa <- pr$tactical_kappa
    p$youth_mobilised_pct <- pr$youth_mobilised_pct
    p
  }

  shiny::observeEvent(side$run(), {
    p <- side$params(); polls <- side$polls(); lists <- side$lists()
    errs <- validate_scenario_inputs(p, polls, lists)
    if (length(errs)) {
      shiny::showModal(shiny::modalDialog(
        title = "Parametri nisu validni",
        shiny::tags$ul(lapply(errs, shiny::tags$li)),
        easyClose = TRUE, footer = shiny::modalButton("Zatvori")
      ))
      return()
    }

    shiny::withProgress(message = "Simulacija scenarija", value = 0, {
      shiny::incProgress(.15, detail = "Priprema parametara i raspodela")
      r <- simulate_scenario(p, polls, lists)
      shiny::incProgress(.70, detail = "D’Hondt raspodela i sažeci")

      ref_p <- preset_reference_params(p)
      ref_lists <- apply_preset_to_lists(default_lists, p$preset_id)
      ref <- deterministic_reference(ref_p, default_polls, ref_lists)
      shiny::incProgress(.15, detail = "Završavanje grafikona i tabela")

      last_result(r)
      last_reference(ref)
      last_hash(current_hash())
    })
  }, ignoreInit = TRUE)

  mod_results_server("results", shiny::reactive(last_result()), shiny::reactive(last_reference()), stale)
  mod_parameters_server("parameters", shiny::reactive(last_result()))
  mod_methodology_server("methodology", side$params)
}

shinyApp(ui, server)
