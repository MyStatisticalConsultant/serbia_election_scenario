mod_methodology_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::div(
      class = "intro-box",
      shiny::strong("Intuitivno: "),
      "aplikacija počinje od centralne slike podrške, zatim mnogo puta menja izlaznost, podrške i transfere u granicama izabranih pretpostavki. U svakoj iteraciji preračunava glasove, cenzus i 250 mandata. Rezultat nije jedan ‘tačan broj’, već raspodela posledica izabranog scenarija."
    ),
    shiny::h3("Tok modela"),
    shiny::p("ANKETE ILI REKONSTRUKCIJA → KOREKCIJE → ISTORIJSKO SIDRO → NEIZVESNOST → IZLAZNOST → TAKTIČKO GLASANJE → MOBILIZACIJA MLADIH → VAŽEĆI GLASOVI → CENZUS → D’HONDT → RASPODELA ISHODA"),
    shiny::p("Svaka strelica predstavlja poseban korak. To je važno zato što, na primer, viša izlaznost sama po sebi ne govori kome pripadaju dodatni glasovi, a veća neizvesnost ne bi smela automatski da favorizuje jednu listu."),
    bslib::accordion(
      multiple = TRUE,
      open = c("Izvori centralne podrške", "Endogeni transfer u blizini cenzusa"),
      bslib::accordion_panel(
        "Izvori centralne podrške",
        shiny::p(shiny::strong("Intuitivno: "), "centralna podrška je polazna mapa, pre nego što se dodaju slučajna odstupanja i transferi."),
        shiny::p("Kod ‘Rekonstruisane početne procene’ koriste se dokumentovane početne vrednosti iz metodološke beleške. Kod ‘Ažuriranih anketa i modela’ aktivne ankete se ponderišu posebno za svaku listu; nedostajuća procena iz jedne ankete izostavlja se samo iz agregacije te liste, a preostali ponderi se ponovo normalizuju."),
        shiny::p("Istorijske korekcije anketara primenjuju se samo na zbir SNS+SPS, jer rekonstrukcija ne daje odvojene korekcije. Posle korekcije njihov odnos se čuva proporcionalno. Opcija ‘Isključi Nacija TV’ predstavlja test osetljivosti, ne presudu o kvalitetu ankete."),
        shiny::p("U ažuriranom modelu anketni zbir SNS+SPS kombinuje se sa istorijskim sidrom. Težina anketa od 91% znači da istorijsko sidro ima 9%. Ako je težina anketa 100%, istorijsko sidro nema uticaj.")
      ),
      bslib::accordion_panel(
        "Šta je dokumentovano, a šta je nova specifikacija",
        shiny::p(shiny::strong("Intuitivno: "), "aplikacija razdvaja ono što znamo iz rekonstrukcije od matematičkih pravila koja su bila potrebna da bi model ponovo postao izvršiv."),
        shiny::p("Metodološka rekonstrukcija daje ankete i njihove pondere, približne istorijske korekcije, početne podrške, bazne taktičke transfere i njihove opsege, izlaznost N(63,0%; 1,5 pp), SNS+SPS sidro od oko 2,052 miliona glasova i visoki mobilizacioni primer sa oko 183.000 dodatno mobilisanih mladih."),
        shiny::p("Nisu sačuvani originalni izvršni kod, seed, puna matrica parametara, sve raspodele podrške, standardne devijacije, korelaciona struktura ni iteracioni rezultati. Zato logističko-normalna raspodela, skalirane Beta raspodele, kalibracija grešaka i deo korelacija predstavljaju nove, eksplicitno označene specifikacije simulatora. Aplikacija reprodukuje dokumentovanu logiku, ali ne tvrdi da je identična izgubljenom programu.")
      ),
      bslib::accordion_panel(
        "Logističko-normalna podrška i korelisane greške",
        shiny::p(shiny::strong("Intuitivno: "), "podrške listama ne mogu biti negativne i moraju zajedno dati 100%. Zbog toga nije dovoljno svakoj listi nezavisno dodati običnu normalnu grešku."),
        shiny::p("Centralne podrške se prevode na latentnu log-ratio skalu. Vektor latentnih grešaka izvlači se zajednički iz multivarijantne normalne raspodele, a softmax transformacija ga vraća u procente koji su pozitivni i sabiraju se na 100%."),
        shiny::p("SD izbornog ciklusa kombinuje se sa uncertainty_sd_pp svake liste, a zatim se približno kalibriše sa procentnih poena na latentnu skalu. Korelaciona matrica određuje zajedničko kretanje latentnih odstupanja. Negativna korelacija Studentske liste sa SNS/SPS znači češće suprotne smerove odstupanja; pozitivna korelacija SNS–SPS predstavlja zajedničku komponentu greške. Nula ne znači da su konačni udeli potpuno nezavisni, jer kompozicioni zbir ostaje 100%.")
      ),
      bslib::accordion_panel(
        "Taktičko glasanje i skalirana Beta raspodela",
        shiny::p(shiny::strong("Intuitivno: "), "model ne pretpostavlja da će u svakoj simulaciji identičan procenat birača manje liste glasati taktički. Stopa varira unutar izričito zadatih granica."),
        shiny::p("Za donju granicu L, gornju granicu U i baznu vrednost koristi se skalirana Beta raspodela. Parametar koncentracije kappa određuje zbijenost: veća kappa daje realizacije bliže baznoj vrednosti, a manja kappa češće daje vrednosti bliže krajevima opsega. Izvorna beleška daje bazne vrednosti i opsege, ali ne navodi Beta raspodelu; ona je nova specifikacija simulatora."),
        shiny::p("Preneti glasovi se oduzimaju izvornoj i dodaju ciljnoj listi, pa je zbir očuvan. Poseban transfer neopredeljenih primenjuje se samo na eksplicitni fond ‘neopredeljenih koji preferiraju promenu’, a ne na ceo ostatak.")
      ),
      bslib::accordion_panel(
        "Endogeni transfer u blizini cenzusa",
        shiny::p(shiny::strong("Šta znači: "), "‘endogeni’ ovde znači da stopa taktičkog transfera nije unapred ista bez obzira na položaj liste. Ona zavisi od simulirane podrške te liste u istoj iteraciji."),
        shiny::p(shiny::strong("Zašto je relevantno: "), "birač koji preferira manju listu može imati jači podsticaj za taktičko glasanje kada procenjuje da je lista blizu ili ispod 3%. Ako je lista bezbedno iznad cenzusa, dodatni pritisak je slabiji. To je modelirana pretpostavka ponašanja, ne neposredno posmatrana individualna odluka."),
        shiny::p("Model polazi od slučajno izvučene bazne stope transfera i dodaje pojačanje ka gornjoj granici pomoću logističke funkcije:"),
        shiny::p(shiny::code("efektivni transfer = bazni transfer + gamma × (gornja granica − bazni transfer) × logistic((3 − podrška) / širina)")),
        shiny::tags$ul(
          shiny::tags$li(shiny::strong("Gamma = 0: "), "blizina cenzusa ne daje dodatno pojačanje; ostaje samo bazna Beta stopa."),
          shiny::tags$li(shiny::strong("Gamma = 0,50: "), "primenjuje se polovina maksimalno predviđenog dodatnog približavanja gornjoj granici."),
          shiny::tags$li(shiny::strong("Gamma = 1: "), "kada je lista dovoljno nisko, stopa može snažno prići gornjoj granici."),
          shiny::tags$li(shiny::strong("Mala širina, npr. 0,1–0,3 pp: "), "kriva se naglo menja neposredno oko 3%; model pretpostavlja usku zonu reakcije."),
          shiny::tags$li(shiny::strong("Veća širina, npr. 1–2 pp: "), "promena je postepenija i počinje dalje od cenzusa; širi opseg podrški utiče na ponašanje.")
        ),
        shiny::p("Na grafikonu je x-osa podrška izvornoj manjoj listi, a y-osa efektivni procenat njenog glasačkog fonda koji se prenosi ciljnoj listi. Isprekidana vertikalna linija označava 3%. Kriva koja raste ulevo pokazuje da transfer postaje viši kako podrška pada ka cenzusu i ispod njega. Grafikon je ilustracija za bazu 50% i gornju granicu 70%; stvarne vrednosti svake liste dolaze iz tabele ‘Podrška listama’."),
        shiny::div(class = "plot-frame", shiny::plotOutput(ns("tactical_curve"), width = "100%", height = "420px"))
      ),
      bslib::accordion_panel(
        "Izlaznost, nevažeći listići i mobilizacija mladih",
        shiny::p(shiny::strong("Intuitivno: "), "ukupna izlaznost govori koliko je ljudi glasalo; nevažeći listići određuju koliko glasova ostaje za liste; modul mladih određuje sastav samo dela dodatne izlaznosti."),
        shiny::p("Izlaznost se izvlači iz ograničene normalne raspodele sa korisničkim centrom i SD, između tehničkog minimuma i maksimuma. Broj birača koji su glasali dobija se množenjem izlaznosti brojem upisanih birača. Udeo nevažećih računa se među svim glasačkim listićima birača koji su glasali, a preostali broj predstavlja važeće glasove za liste."),
        shiny::p("Da bi se izbeglo dvostruko brojanje, prvo se utvrđuje broj listića iznad referentne izlaznosti. Samo unutar tog marginalnog fonda može se uključiti zadati broj dodatno mobilisanih mladih, i to najviše do youth_pool × youth_mobilised_pct. Njihovi glasovi se raspodeljuju prema tri redom zadata udela za Studentsku listu, SNS i SPS, dok se udeo ostalih lista automatski dobija kao ostatak do 100%. Preostali važeći glasovi dele se prema opštoj simuliranoj strukturi.")
      ),
      bslib::accordion_panel(
        "Nerazvrstani ostatak, manje i manjinske liste",
        shiny::p(shiny::strong("Intuitivno: "), "dokumentovanih 4,28% nije jedna homogena grupa i ne sme se automatski pripisati bilo kojoj političkoj strani."),
        shiny::p("Simulator ga zato razlaže na neopredeljene koji preferiraju promenu, ostale nemanjinske liste, manjinske liste, verovatnu apstinenciju i nerazvrstano. Samo jasno definisane glasačke komponente ulaze u raspodelu važećih glasova; apstinencija i nerazvrstano ne postaju automatski glasovi za listu. Kod rekonstruisanog izvora zbir pet komponenti mora biti 4,28%."),
        shiny::p("Manjinski status se nikada ne zaključuje iz imena. Korisnik ga označava u tabeli u skladu sa pravno relevantnim statusom za scenario.")
      ),
      bslib::accordion_panel(
        "Cenzus i D’Hondt",
        shiny::p(shiny::strong("Intuitivno: "), "najpre se određuje koje liste učestvuju u raspodeli, a tek zatim se njihov broj glasova pretvara u mandate."),
        shiny::p("Za obične liste prag je 3% od broja birača koji su glasali, a ne 3% od samo važećih glasova za liste. Manjinske liste mogu učestvovati ispod 3%; kada su ispod praga, njihovi D’Hondtovi količnici povećavaju se za 35%. To ne garantuje mandat. Ako nijedna lista ne dostigne 3%, u raspodeli učestvuju sve liste sa glasovima."),
        shiny::p("D’Hondtov metod deli glasove svake kvalifikovane liste sa 1, 2, 3 i tako dalje, a 250 najvećih količnika dobijaju mandate. Analitički blokovi sabiraju rezultate posle obračuna i ne tretiraju se kao jedna izborna lista osim ako je korisnik zaista modeluje kao jedinstvenu listu.")
      ),
      bslib::accordion_panel(
        "Kako tumačiti intervale i udeo simulacija",
        shiny::p(shiny::strong("Intuitivno: "), "interval pokazuje koliko se rezultat menja kroz iteracije pod istim skupom pretpostavki."),
        shiny::p("Medijana deli simulacije na dve polovine. Centralni 50% interval obuhvata srednju polovinu ishoda, a 95% interval gotovo celu simuliranu raspodelu. To su intervali scenarija, ne automatski klasični intervali pouzdanosti."),
        shiny::p("‘Udeo simulacija iznad cenzusa’ je procenat iteracija u kojima je lista pod izabranim pretpostavkama dostigla zakonski prag. Ne treba ga bez dodatnog modela nazivati objektivnom realnom verovatnoćom.")
      ),
      bslib::accordion_panel(
        "Šta model namerno ne sadrži",
        shiny::p("Izborne nepravilnosti, medijska nejednakost, kupovina glasova i administrativni pritisak nisu pretvoreni u proizvoljan fiksni bonus bilo kojoj listi. Rekonstrukcija ih nije kvantifikovala na način koji bi opravdao determinističku korekciju. Njihovo izostavljanje nije tvrdnja da ne postoje, već ograničenje merljivosti i modela.")
      )
    ),
    shiny::p(class = "small-muted", "Pravila cenzusa, manjinskih lista i raspodele mandata zasnovana su na pravilima Republičke izborne komisije koja su proverena pri izradi aplikacije.")
  )
}

mod_methodology_server <- function(id, params_r) {
  shiny::moduleServer(id, function(input, output, session) {
    output$tactical_curve <- shiny::renderPlot({
      shiny::req(params_r())
      print(plot_tactical_curve(params_r()))
    }, width = 1000, height = 420, res = 110)
  })
}
