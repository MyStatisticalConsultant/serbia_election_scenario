instruction_table <- function(headers, rows) {
  shiny::tags$table(
    class = "table table-striped table-sm instruction-table",
    shiny::tags$thead(
      shiny::tags$tr(lapply(headers, shiny::tags$th))
    ),
    shiny::tags$tbody(
      lapply(rows, function(row) shiny::tags$tr(lapply(row, shiny::tags$td)))
    )
  )
}

instruction_item <- function(term, text) {
  shiny::tags$li(shiny::tags$strong(paste0(term, ": ")), text)
}

mod_instructions_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::div(
      class = "intro-box",
      "Najkorisniji način rada je da najpre pokrenete jedan neizmenjen predefinisani scenario, a zatim menjate mali broj pretpostavki odjednom. Posle svake izmene ponovo pritisnite ‘Pokreni simulaciju scenarija’ i uporedite celu raspodelu rezultata, ne samo medijanu."
    ),
    shiny::h3("Osnovni postupak"),
    shiny::tags$ol(
      shiny::tags$li("Izaberite predefinisani scenario. Njegove vrednosti se učitavaju u levi panel."),
      shiny::tags$li("Ako želite upravo taj scenario, ne morate menjati nijedan parametar — odmah kliknite ‘Pokreni simulaciju scenarija’."),
      shiny::tags$li("Ako menjate kontrole ili tabele, status postaje ‘Korisnički scenario’."),
      shiny::tags$li("Po potrebi pregledajte ili uvezite ankete i izborne liste."),
      shiny::tags$li("Za brzo ispitivanje koristite manji broj iteracija; za završni rezultat povećajte broj simulacija."),
      shiny::tags$li("Posle svake izmene ponovo pokrenite simulaciju. Prikazani rezultati se ne menjaju automatski."),
      shiny::tags$li("Tumačite medijanu zajedno sa 50% i 95% intervalima scenarija.")
    ),
    bslib::accordion(
      multiple = TRUE,
      open = c("Predefinisani scenariji i resetovanje", "Ankete i ponderi"),
      bslib::accordion_panel(
        "Predefinisani scenariji i resetovanje",
        shiny::p("Predefinisani scenario je dosledan skup početnih vrednosti. Njegov naziv opisuje pretpostavke, a ne procenu verovatnoće da će se scenario ostvariti."),
        instruction_table(
          c("Scenario", "Šta pretpostavlja", "Kako ga pokrenuti"),
          list(
            list("Rekonstruisana početna procena", "Koristi centralne podrške iz metodološke rekonstrukcije, izlaznost 63,0% uz SD 1,5 pp i eksplicitno razlaže ostatak od 4,28%. Ankete nisu izvor centralnih podrški u ovom scenariju.", "Izaberite scenario i kliknite ‘Pokreni simulaciju scenarija’. Menjanje anketa nije potrebno osim ako želite da pređete na ažurirani anketni model."),
            list("Bazni taktički transferi", "Koristi ažurirane ankete, bazne transfere iz rekonstrukcije, umerenu izlaznost i standardnu neizvesnost simulatora.", "Može se pokrenuti bez dodatnih izmena. Koristite ga kao referencu za poređenje alternativnih stopa transfera."),
            list("Visoka izlaznost i visoka konsolidacija", "Povećava očekivanu izlaznost i mobilizaciju mladih, a transferi sa Narodne Srbije i Proevropskog bloka postaju viši. To je stres-scenario pretpostavki, ne oznaka da je ishod verovatan.", "Pokrenite ga neizmenjenog, zatim po želji odvojeno smanjujte izlaznost, mobilizaciju ili transfer da biste videli koji element najviše menja ishod."),
            list("Niža taktička konsolidacija", "Pretpostavlja slabije reagovanje birača manjih lista na blizinu cenzusa i raspršenije stope transfera.", "Pokrenite bez izmene i uporedite sa baznim taktičkim scenarijem."),
            list("Veća neizvesnost anketa", "Povećava grešku izbornog ciklusa i SD izlaznosti, a smanjuje punu istorijsku korekciju anketara. Intervali bi trebalo da budu širi, bez automatskog favorizovanja liste.", "Pokrenite bez izmene, pa uporedite širinu intervala sa baznim scenarijem.")
          )
        ),
        shiny::h4("Dugme ‘Resetuj izabrani scenario’"),
        shiny::p("Dugme vraća ankete, listu izbornih lista i sve kontrole koje pripadaju izabranom scenariju na njihove početne vrednosti, uključujući napredne tehničke vrednosti, seed i broj simulacija. Koristite ga kada ste napravili više ručnih izmena i želite da ponovo dobijete čisto polazište. Resetovanje samo menja kontrole; zatim morate ponovo kliknuti ‘Pokreni simulaciju scenarija’ da bi se izračunali novi rezultati."),
        shiny::p(shiny::strong("Datum poslednjeg ažuriranja podataka "), "je metapodatak koji se prikazuje u rezultatima i izveštaju. Sam po sebi ne menja matematiku simulacije; treba da odgovara stvarnom preseku unetih anketa i lista."),
        shiny::p(shiny::strong("Status scenarija "), "ostaje naziv predefinisanog scenarija dok ne promenite kontrolu ili tabelu. Posle ručne izmene postaje ‘Korisnički scenario’. To ne pokreće automatski novi obračun.")
      ),
      bslib::accordion_panel(
        "Ankete i ponderi",
        shiny::h4("Izvor centralne podrške"),
        shiny::tags$ul(
          instruction_item("Rekonstruisana početna procena", "centralne vrednosti podrške čitaju se iz rekonstruisanih vrednosti u tabeli izbornih lista. Tabela anketa tada ne određuje centar simulacije; nije potrebno uređivati ankete pre pokretanja."),
          instruction_item("Ažurirane ankete i model", "aktivne ankete određuju centralne vrednosti za Studentsku listu, SNS i SPS. Na SNS+SPS zatim se primenjuju izabrana korekcija anketara i kombinovanje sa istorijskim sidrom. Ostale liste dolaze iz tabele ‘Podrška listama’. Potrebna je najmanje jedna aktivna anketa sa pozitivnim ponderom i najmanje jedna raspoloživa procena za svaku od tri glavne liste.")
        ),
        shiny::h4("Isključi Nacija TV"),
        shiny::p("Kada je opcija isključena, Nacija TV ulazi u agregat ako je njen red označen kao active i ponder je pozitivan. Kada je uključena, anketa se privremeno izostavlja iz računanja, ali se njen red ne briše. Opcija ima efekat samo kada je izvor ‘Ažurirane ankete i model’. Namenjena je analizi osetljivosti, jer je dokumentacija te ankete u rekonstrukciji bila nepotpuna; uključivanje ne tvrdi da je anketa nevažeća."),
        shiny::h4("Jačina korekcije efekta anketara"),
        shiny::p("Vrednost 0% znači da se ne primenjuje istorijska korekcija. Vrednost 100% primenjuje punu rekonstruisanu korekciju: približno +1,2 pp na zbir SNS+SPS za NSPM i −4,4 pp za Faktor Plus, uz očuvanje njihovog odnosa SNS:SPS. Vrednosti između 0% i 100% primenjuju odgovarajući deo korekcije. Pošto su istorijske procene zasnovane na malom broju izbornih ciklusa, srednje vrednosti su koristan test osetljivosti."),
        shiny::h4("Uređivanje tabele anketa"),
        shiny::p("Ćelija se menja dvostrukim klikom. active uključuje red u agregat; weight je relativni uticaj ankete. Na primer, ponder 40 ima dvostruko veći uticaj od pondera 20. Ponder mora biti nenegativan, a aktivne ankete zajedno moraju imati pozitivan zbir pondera. Njihov zbir ne mora ručno biti 100%, jer se ponderi interno normalizuju. Pojedinačna anketna procena mora biti između 0% i 100%. Procene student_list + sns + sps ne moraju dati 100%, jer tabela ne sadrži sve liste i neopredeljene."),
        shiny::h4("Normalizuj pondere"),
        shiny::p("Dugme proporcionalno menja pondere aktivnih anketa tako da njihov zbir postane 100%, bez menjanja njihovih međusobnih odnosa. Neaktivni redovi ne učestvuju u računanju. Normalizacija olakšava čitanje tabele, ali ne menja rezultat ako su relativni odnosi pondera već isti."),
        shiny::p("‘Dodaj anketu’ umeće novi red sa ponderom 0, koji zatim treba popuniti. ‘Obriši izabranu’ uklanja označeni red; najmanje jedan red ostaje u tabeli. Uvoz CSV-a zamenjuje trenutnu tabelu uvezenim sadržajem, dok ‘Preuzmi CSV šablon’ daje primer pune strukture."),
        shiny::h4("CSV anketa"),
        instruction_table(
          c("Kolone", "Status", "Značenje"),
          list(
            list("poll_id, pollster, active, weight", "Obavezne", "Jedinstveni ID, naziv anketara, uključenost i nenegativni ponder."),
            list("fieldwork, sample_size, mode", "Opcione", "Metapodaci o terenskom radu, veličini uzorka i načinu anketiranja; izostavljene kolone se popunjavaju sa NA."),
            list("student_list, sns, sps", "Strukturno opcione", "Mogu sadržati NA, ali ažurirani model zahteva da među aktivnim anketama postoji najmanje jedna raspoloživa procena za svaku od tri liste.")
          )
        )
      ),
      bslib::accordion_panel(
        "Podrška listama i CSV izbornih lista",
        shiny::p("Prva kolona u prikazu nosi zaglavlje ‘Lista’ i sadrži čitljiv naziv liste; druga kolona sadrži stabilni list_id. Tabela se uređuje dvostrukim klikom. Vrednosti central_support moraju biti između 0% i 100%, uncertainty_sd_pp ne sme biti negativan, a aktivne liste moraju imati najmanje jednu pozitivnu podršku."),
        shiny::p("Konačne podrške u svakoj simulaciji uvek se normalizuju na 100%. Zbir same kolone central_support ne mora mehanički biti 100% u rekonstruisanom scenariju, jer se deo ostatka vodi odvojeno, neke komponente ne postaju važeći glasovi, a ručni pomaci i taktički transferi primenjuju se u kasnijim koracima. Za potpuno samostalnu korisničku tabelu ipak je korisno proveriti da je zamišljena raspodela logički zatvorena."),
        shiny::p("‘Dodaj listu’ umeće novi aktivni red sa tehničkim početnim vrednostima koje treba urediti. ‘Obriši izabranu’ uklanja označenu listu, ali aplikacija ne dopušta brisanje poslednjeg reda. Uvoz CSV-a zamenjuje trenutnu tabelu, a preuzeti šablon sadrži i obavezne i opcione kolone."),
        instruction_table(
          c("Kolona", "Status", "Dozvoljene vrednosti / uloga"),
          list(
            list("list_id", "Obavezna", "Jedinstveni tehnički identifikator bez duplikata; koristi se i u tactical_target."),
            list("name", "Obavezna", "Naziv koji se prikazuje u grafikonima i tabelama."),
            list("central_support", "Obavezna", "Centralna podrška 0–100%."),
            list("active", "Obavezna", "TRUE/FALSE; samo aktivne liste ulaze u simulaciju."),
            list("minority", "Obavezna", "TRUE/FALSE; pravilo manjinske liste primenjuje se samo kada je TRUE."),
            list("uncertainty_sd_pp", "Opciona", "Dodatna SD podrške u procentnim poenima; podrazumevano 1."),
            list("tactical_target", "Opciona", "list_id liste kojoj se prenosi deo podrške; prazno znači bez transfera."),
            list("baseline_transfer, lower_transfer, upper_transfer", "Opcione", "Procenti 0–100 uz uslov lower ≤ baseline ≤ upper; podrazumevano 0."),
            list("manual_shift_pp", "Opciona", "Ručni pomak u procentnim poenima; podrazumevano 0."),
            list("analytic_bloc", "Opciona", "Naziv grupe za zbirne analitičke rezultate; ne spaja liste u D’Hondtovom obračunu.")
          )
        )
      ),
      bslib::accordion_panel(
        "Greška anketa u izbornom ciklusu",
        shiny::p("Ova SD predstavlja zajedničku neizvesnost specifičnu za konkretan izborni ciklus: moguće odstupanje anketa usled odziva, kasne promene raspoloženja, pokrivenosti birača ili drugih zajedničkih razloga. Razlikuje se od efekta pojedinačnog anketara."),
        shiny::tags$ul(
          instruction_item("0–1 pp", "vrlo mala dodatna neizvesnost; koristite samo kao deterministički ili izrazito stabilan test."),
          instruction_item("oko 1,5–3 pp", "umerena radna pretpostavka; početna vrednost aplikacije je 2,5 pp."),
          instruction_item("oko 3–5 pp", "izbori sa većom zajedničkom neizvesnošću ili scenario stresa."),
          instruction_item("iznad 5 pp", "veoma širok stres-test, ne automatski ‘realističnija’ pretpostavka.")
        ),
        shiny::p("Ukupna neizvesnost svake liste kombinuje ovu vrednost sa uncertainty_sd_pp iz tabele lista. Zato istovremeno povećavanje oba parametra može veoma proširiti intervale. Veća SD bi trebalo da širi ishode, a ne da sistematski povećava podršku određene liste.")
      ),
      bslib::accordion_panel(
        "Izlaznost",
        shiny::tags$ul(
          instruction_item("Očekivana izlaznost", "centar simulirane raspodele. Birajte je prema istorijskoj izlaznosti, istraživanjima i konkretnoj pretpostavci o mobilizaciji; 63,0% je rekonstruisana početna vrednost."),
          instruction_item("SD izlaznosti", "određuje koliko se simulirane izlaznosti rasipaju oko centra. Vrednost 0 znači fiksnu izlaznost; 1–2 pp je umerena radna neizvesnost, a više vrednosti daju širi raspon."),
          instruction_item("Referentna izlaznost", "tehnička baza za identifikovanje marginalnog dela izlaznosti. Samo broj glasačkih listića iznad te baze može se prvo pripisati dodatno mobilisanim mladima, do zadatog maksimuma. Niža referenca povećava prostor za modul mladih; viša ga smanjuje.")
        ),
        shiny::p("Referentna izlaznost nije prognoza i nije pravni prag. Ona sprečava da se isti rast izlaznosti dvaput računa — jednom kroz ukupnu izlaznost, a drugi put kao dodatni broj mladih birača.")
      ),
      bslib::accordion_panel(
        "Taktičko glasanje",
        shiny::tags$ul(
          instruction_item("Transfer neopredeljenih koji preferiraju promenu – bazno", "srednja pretpostavljena stopa kojom posebno izdvojeni deo neopredeljenih koji preferira političku promenu prelazi Studentskoj listi. Početna vrednost je 75%. Ne odnosi se na sve neopredeljene niti na ceo ostatak od 4,28%."),
          instruction_item("Raspon transfera neopredeljenih", "donja i gornja granica slučajnih realizacija. Početni opseg je 60–90%; bazna vrednost mora biti unutar tog opsega.")
        ),
        shiny::p("Ove kontrole rade zajedno sa poljem ‘Neopredeljeni koji preferiraju promenu (%)’ u sekciji manjih lista i sa Beta koncentracijom. Ako je taj fond 0%, slajderi transfera neopredeljenih nemaju praktičan efekat. Niže vrednosti koristite za slabiju konsolidaciju; više za scenario u kome se veći deo ovog specifičnog fonda usmerava Studentskoj listi. Transferi sa imenovanih manjih lista uređuju se odvojeno u tabeli ‘Podrška listama’ i dodatno zavise od blizine cenzusa.")
      ),
      bslib::accordion_panel(
        "Mobilizacija mladih",
        shiny::tags$ul(
          instruction_item("Fond mladih birača", "procenjeni potencijalni fond mladih koji bi mogli prvi put ili dodatno izaći na izbore. Rekonstrukcija koristi oko 913.000 mladih sa pravom glasa kao širu osnovu; to nije broj koji se automatski pojavljuje na izborima."),
          instruction_item("Dodatno mobilisani mladi", "procenat fonda koji se stvarno tretira kao dodatno mobilisan. Vrednost 20% od 913.000 daje oko 183.000, što odgovara visokom scenariju iz rekonstrukcije."),
          instruction_item("Studentska lista, SNS, SPS i Ostale liste", "hijerarhijska raspodela važećih glasova dodatno mobilisanih mladih. Početnih 70/18/2/10 je scenario pretpostavka iz rekonstrukcije, ne neposredno izmerena struktura glasanja mladih.")
        ),
        shiny::p("Podešavanje ide redom. Prvo zadajete X% za Studentsku listu; ta vrednost ostaje fiksna. Zatim zadajete Y% za SNS, najviše 100 − X. Potom zadajete Z% za SPS, najviše 100 − X − Y. Udeo ‘Ostale liste’ nije zaseban korisnički slajder, već se automatski računa kao 100 − X − Y − Z. Ako povećanje ranijeg udela ostavi premalo prostora, ograničava se samo kasniji udeo; prethodno postavljeni udeli se ne preračunavaju proporcionalno. Udeo ‘Ostale liste’ zatim se unutar modela raspodeljuje proporcionalno među svim drugim aktivnim listama. Modul ne može dodati više mladih birača nego što postoji marginalne izlaznosti iznad referentne baze.")
      ),
      bslib::accordion_panel(
        "Manje i manjinske liste",
        shiny::p("Pet polja razlaže dokumentovani aritmetički ostatak od 4,28%. Podela 1,00 + 1,28 + 1,50 + 0,30 + 0,20 je tehnička početna vrednost simulatora, a ne zasebno empirijski procenjena struktura birača."),
        shiny::tags$ul(
          instruction_item("Neopredeljeni koji preferiraju promenu", "fond na koji se primenjuje poseban transfer ka Studentskoj listi."),
          instruction_item("Ostale nemanjinske liste", "podrška drugih običnih lista koje nisu zasebno imenovane."),
          instruction_item("Manjinske liste", "zbirna početna podrška manjinskim listama; pravni status se ipak određuje zastavicom minority u tabeli."),
          instruction_item("Verovatna apstinencija", "deo ostatka koji se ne pretvara u važeći glas za listu."),
          instruction_item("Nerazvrstano", "deo za koji nije opravdano pretpostaviti političko odredište.")
        ),
        shiny::p("Za izvorno veran rekonstruisani scenario preporučeni opseg svake komponente je 0–4,28%, uz obavezan zajednički zbir 4,28%. Menjajte raspodelu unutar tog ukupnog fonda. U ažuriranom anketnom scenariju ukupan ostatak može biti drugačiji, ali svaku promenu treba obrazložiti podacima ili jasno označenom pretpostavkom.")
      ),
      bslib::accordion_panel(
        "Napredni parametri",
        shiny::tags$ul(
          instruction_item("Težina aktuelnih anketa", "udeo kojim se zbir SNS+SPS oslanja na sadašnje ankete; ostatak do 100% pripada istorijskom sidru. Početnih 91% je sredina dokumentovanog raspona 90–92%. Ima efekat samo u ažuriranom anketnom modelu."),
          instruction_item("Broj upisanih birača", "imenilac kojim se procenat izlaznosti pretvara u broj birača koji su glasali. Početnih 6,44 miliona prati aritmetiku rekonstrukcije."),
          instruction_item("Udeo nevažećih listića", "procenat svih glasačkih listića birača koji su glasali, odnosno ballots cast; nije procenat upisanih birača. Oduzima se pre raspodele važećih glasova listama. Početnih 1,5% izvedeno je iz aritmetičkog mosta visokog scenarija."),
          instruction_item("Istorijsko SNS+SPS sidro", "oko 2.051.996 glasova, približna aritmetička sredina relevantnih rezultata 2022. i 2023. Donja i gornja granica 1.832.000–2.272.000 predstavljaju centralnu vrednost ±220.000 glasova. Taj raspon je analitički zadat interval, ne standardna greška."),
          instruction_item("Koncentracija Beta raspodele istorijskog sidra", "određuje koliko su izvlačenja unutar navedenih granica zbijena oko 2.051.996. Početnih 20 je umerena tehnička vrednost simulatora: veće vrednosti daju manje rasipanje, niže veće. Parametar deluje samo kada istorijsko sidro ima pozitivnu težinu."),
          instruction_item("Koncentracija distribucije taktičkog transfera", "na isti način kontroliše rasipanje stopa transfera unutar njihovih donjih i gornjih granica. Početnih 20 je umerena tehnička pretpostavka, ne izvorna empirijska procena."),
          instruction_item("Osetljivost transfera na cenzus", "vrednost 0 isključuje dodatno povećanje transfera zbog blizine 3%; vrednost 1 daje maksimalno predviđeno približavanje gornjoj granici kada je lista ispod ili vrlo blizu cenzusa. Početnih 0,50 je srednja pretpostavka."),
          instruction_item("Širina zone oko cenzusa", "određuje koliko široko područje podrške oko 3% utiče na transfer. Mala vrednost, npr. 0,1–0,3 pp, daje naglu reakciju tik uz cenzus; veća, npr. 1–2 pp, daje postepen uticaj na širem području. Početna vrednost je 0,6 pp."),
          instruction_item("Korelacija latentnih grešaka Studentska lista – SNS/SPS", "početnih −0,45 pretpostavlja umereno suprotno kretanje njihovih neočekivanih odstupanja. Vrednost 0 uklanja direktnu latentnu vezu, a vrednosti bliže −1 pojačavaju suprotno kretanje. To nije korelacija izračunata iz anketa, već podesiva specifikacija simulatora."),
          instruction_item("Minimalna i maksimalna izlaznost", "tehničke granice skraćene normalne raspodele. ‘Dozvoljena’ znači dozvoljena modelom, ne zakonom ili izbornom administracijom. Početnih 45–75% je široka zaštitna zona koja sprečava ekstremna slučajna izvlačenja.")
        )
      ),
      bslib::accordion_panel(
        "Monte Carlo simulacija",
        shiny::tags$ul(
          instruction_item("Seed", "početna vrednost generatora slučajnih brojeva. Sa potpuno istim podacima, parametrima, seedom i brojem iteracija dobićete isti rezultat. Promenite seed ako želite da proverite Monte Carlo stabilnost."),
          instruction_item("Broj simulacija", "1.000–10.000 koristite za brzo istraživanje i podešavanje scenarija. Za konačne tabele i izveštaj koristite 50.000 ili 100.000 ako računar i vreme to dozvoljavaju. Veći broj smanjuje slučajnu Monte Carlo varijaciju, ali ne popravlja pogrešne pretpostavke modela.")
        )
      )
    ),
    shiny::h3("Kako NE treba tumačiti rezultate"),
    shiny::tags$ul(
      shiny::tags$li("‘Udeo simulacija iznad cenzusa = 70%’ ne znači da je objektivna realna verovatnoća prelaska cenzusa tačno 70%. To je rezultat uslovan na unesene pretpostavke."),
      shiny::tags$li("Medijana od 48% nije anketa od 48%. Ona je centralna vrednost simulirane raspodele scenarija."),
      shiny::tags$li("Širi interval ne znači da je lista ‘slabija’; znači da je u model unesena veća neizvesnost."),
      shiny::tags$li("Analitički zbir SNS+SPS nije isto što i zajednička izborna lista u D’Hondtovom obračunu."),
      shiny::tags$li("Promena jednog parametra pokazuje osetljivost modela na pretpostavku, ali sama po sebi ne dokazuje politički uzrok.")
    )
  )
}
