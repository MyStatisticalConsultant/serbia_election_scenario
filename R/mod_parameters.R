mod_parameters_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::div(class = "intro-box", "Ova stranica prikazuje sve pretpostavke koje su korišćene u poslednjoj pokrenutoj simulaciji. Prvo proverite šta je zaista ušlo u model, a tek zatim tumačite rezultate."),
    shiny::h3("Sažetak parametara"),
    shiny::p("Tabela je revizijski trag poslednje simulacije. Kolona ‘Poreklo’ razlikuje dokumentovane i rekonstruisane vrednosti, pretpostavke scenarija, nove specifikacije simulatora i korisničke vrednosti."),
    shiny::div(class = "table-frame", DT::DTOutput(ns("snapshot"))),
    shiny::h3("Ankete korišćene u scenariju"),
    shiny::p("Prikazana je sačuvana tabela iz trenutka pokretanja simulacije. active i weight pokazuju koje ankete su bile dostupne modelu; izbor ‘Isključi Nacija TV’ može dodatno izostaviti taj red iz agregacije bez brisanja iz tabele."),
    shiny::div(class = "table-frame", DT::DTOutput(ns("polls"))),
    shiny::h3("Izborne liste i taktičke pretpostavke"),
    shiny::p("Tabela beleži centralnu podršku, neizvesnost, manjinski status, eventualni cilj i granice taktičkog transfera, ručni pomak i analitički blok svake aktivne liste."),
    shiny::div(class = "table-frame", DT::DTOutput(ns("lists"))),
    shiny::h3("Korelaciona struktura latentnih grešaka"),
    shiny::div(
      class = "intro-box",
      shiny::strong("Intuitivno: "),
      "matrica opisuje da li neočekivano odstupanje jedne liste u istoj simulaciji obično ide u istom ili suprotnom smeru od odstupanja druge liste. Ona ne prikazuje korelaciju nivoa podrške iz anketa i ne dokazuje političku uzročnost."
    ),
    shiny::tags$ul(
      shiny::tags$li(shiny::strong("Pozitivna vrednost: "), "latentne greške dve liste teže da se pomeraju u istom smeru."),
      shiny::tags$li(shiny::strong("Negativna vrednost: "), "kada je jedna lista iznad svoje centralne vrednosti, druga češće odstupa naniže."),
      shiny::tags$li(shiny::strong("Vrednost blizu 0: "), "nema zadate direktne veze između njihovih latentnih grešaka."),
      shiny::tags$li(shiny::strong("Dijagonala 1,000: "), "svaka promenljiva je savršeno korelisana sama sa sobom; matricu treba čitati simetrično oko dijagonale.")
    ),
    shiny::p("Na primer, početna vrednost približno −0,45 između Studentske liste i SNS/SPS predstavlja umereno suprotno kretanje latentnih odstupanja, dok +0,50 između SNS i SPS predstavlja zajedničku komponentu greške. Čak i kada je ćelija 0, konačni procenti nisu potpuno nezavisni, jer svi udeli moraju zajedno dati 100%. Matrica se po potrebi numerički koriguje tako da bude validna korelaciona matrica."),
    shiny::div(class = "table-frame", DT::DTOutput(ns("corr")))
  )
}

mod_parameters_server <- function(id, result_r) {
  shiny::moduleServer(id, function(input, output, session) {
    output$snapshot <- DT::renderDT({
      shiny::req(result_r())
      DT::datatable(make_parameter_snapshot(result_r()), rownames = FALSE, options = list(dom = "tip", pageLength = 25, scrollX = TRUE))
    })
    output$polls <- DT::renderDT({
      shiny::req(result_r())
      DT::datatable(
        result_r()$polls,
        rownames = FALSE,
        colnames = c("ID ankete", "Anketar", "Period terenskog rada", "Veličina uzorka", "Način anketiranja", "Aktivna", "Ponder", "Studentska lista (%)", "SNS (%)", "SPS (%)"),
        options = list(scrollX = TRUE, pageLength = 10)
      )
    })
    output$lists <- DT::renderDT({
      shiny::req(result_r())
      d <- result_r()$lists[, c("name", "list_id", "central_support", "uncertainty_sd_pp", "active", "minority", "tactical_target", "baseline_transfer", "lower_transfer", "upper_transfer", "manual_shift_pp", "analytic_bloc"), drop = FALSE]
      DT::datatable(
        d,
        rownames = FALSE,
        colnames = c("Lista", "ID liste", "Centralna podrška (%)", "SD podrške (pp)", "Aktivna", "Manjinska", "Cilj transfera", "Bazni transfer (%)", "Donja granica (%)", "Gornja granica (%)", "Ručni pomak (pp)", "Analitički blok"),
        options = list(scrollX = TRUE, pageLength = 15)
      )
    })
    output$corr <- DT::renderDT({
      shiny::req(result_r())
      r <- result_r()
      mat <- round(r$correlation, 3)
      labels <- setNames(r$lists$name, r$lists$list_id)
      row_labels <- unname(labels[rownames(mat)])
      col_labels <- unname(labels[colnames(mat)])
      d <- data.frame(Lista = row_labels, mat, check.names = FALSE, stringsAsFactors = FALSE)
      names(d) <- c("Lista", col_labels)
      DT::datatable(
        d,
        rownames = FALSE,
        options = list(dom = "t", paging = FALSE, scrollX = TRUE),
        class = "compact stripe"
      )
    })
  })
}
