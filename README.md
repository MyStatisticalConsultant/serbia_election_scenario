# Simulator izbornih scenarija – parlamentarni izbori u Srbiji

Interaktivna **R Shiny aplikacija** za transparentnu Monte Carlo simulaciju uslovnih scenarija parlamentarnih izbora u Srbiji.

Aplikacija povezuje ankete, izlaznost, grešku izbornog ciklusa, mobilizaciju mladih, taktičko glasanje, izborni cenzus, poseban tretman manjinskih lista i D’Hondtovu raspodelu 250 mandata. Korisnik može menjati pretpostavke, porediti scenarije i preuzeti grafikone i kompletan Word izveštaj.

> **Live Shiny aplikacija:** **https://statisticar-serbia-election-scenario.share.connect.posit.cloud**  
> **Povratne informacije:** [Zlatko@MyStatisticalConsultant.com](mailto:Zlatko@MyStatisticalConsultant.com)

Aktuelna verzija aplikacije: **0.2.4**.

---

## Važna napomena: scenario nije prognoza

Rezultati aplikacije predstavljaju **uslovne modelske ishode pod izabranim pretpostavkama**. Oni nisu:

- nova reprezentativna anketa;
- bezuslovna prognoza izbornog rezultata;
- dokaz da će određeni scenario nastupiti;
- procena izborne krađe ili drugih izbornih nepravilnosti;
- zamena za političku, pravnu i institucionalnu analizu izbornog procesa.

Aplikacija je izvedena iz dokumenta *BIRODI Scenario Model for the Next Parliamentary Election in Serbia – Reconstructed Methodological Note*, sa informacijama do 29. avgusta 2026. Izvorni izvršni kod, seed, kompletne distribucije i puna korelaciona struktura nisu sačuvani. Zbog toga aplikacija jasno razlikuje dokumentovane podatke, rekonstruisane vrednosti, scenario pretpostavke i nove statističke specifikacije simulatora.

Detaljnije metodološko obrazloženje nalazi se u [`METHODOLOGY.md`](METHODOLOGY.md), a pregled parametara u [`PARAMETER_DICTIONARY.csv`](PARAMETER_DICTIONARY.csv).

---

## Zašto ova aplikacija?

Aplikacija je namenjena istraživačima, izbornim analitičarima, novinarima, organizacijama civilnog društva, studentima i drugim korisnicima koji žele da sistematski ispitaju posledice različitih izbornih pretpostavki.

Omogućava da:

- odvojite **scenario analizu** od tvrdnje o najverovatnijem ishodu;
- proverite kako izlaznost, neizvesnost i taktički transferi menjaju raspodelu glasova i mandata;
- koristite rekonstruisane početne vrednosti ili ažurirane ankete;
- testirate osetljivost rezultata na uključivanje pojedinačne ankete i efekat anketara;
- procenite koliko često obične liste prelaze izborni cenzus od 3%;
- modelujete poseban tretman manjinskih lista;
- odvojeno analizirate mobilizaciju mladih i raspodelu njihovih glasova;
- ponovite isti rezultat korišćenjem istog seeda;
- sačuvate parametre, rezultate i grafikone za proveru i dalje istraživanje.

---

## Šta možete da radite

### Biranje predefinisanog scenarija

Aplikacija sadrži pet početnih scenarija:

1. **Rekonstruisana početna procena**
2. **Bazni taktički transferi**
3. **Visoka izlaznost i visoka konsolidacija**
4. **Niža taktička konsolidacija**
5. **Veća neizvesnost anketa**

Scenario se može pokrenuti bez izmena ili koristiti kao polazište za korisnički scenario. Dugme **Resetuj izabrani scenario** vraća ankete, izborne liste i kontrole na početne vrednosti izabranog scenarija. Posle resetovanja potrebno je ponovo pokrenuti simulaciju.

### Uređivanje anketa i izbornih lista

- Ćelije u tabelama menjaju se dvostrukim klikom.
- Ankete i liste mogu se dodavati ili brisati.
- Aktivne ankete mogu imati različite relativne pondere.
- Ponderi se mogu proporcionalno normalizovati na zbir od 100%.
- Ankete i izborne liste mogu se uvesti iz CSV datoteka.
- Iz aplikacije se mogu preuzeti odgovarajući CSV šabloni.

### Podešavanje modela

Korisnik može menjati:

- izvor centralne podrške;
- uključivanje ankete Nacija TV;
- jačinu korekcije efekta anketara;
- grešku anketa u izbornom ciklusu;
- očekivanu, referentnu, minimalnu i maksimalnu izlaznost;
- standardnu devijaciju izlaznosti;
- bazni nivo i raspon transfera neopredeljenih;
- fond i procenat dodatno mobilisanih mladih;
- hijerarhijsku raspodelu glasova mladih;
- komponente nerazvrstanog ostatka;
- istorijsko SNS+SPS sidro i njegovu neizvesnost;
- koncentraciju taktičkog transfera;
- osetljivost transfera na blizinu cenzusa;
- latentnu korelaciju grešaka glavnih političkih blokova;
- seed i broj Monte Carlo simulacija.

### Pregled rezultata

Aplikacija prikazuje:

- intervale simulirane podrške listama;
- intervale broja mandata;
- udeo simulacija u kojima obična lista prelazi cenzus;
- raspodelu simulirane izlaznosti;
- poređenje sa referentnim predefinisanim scenarijem;
- numeričku tabelu glasova, mandata i statusa oko cenzusa;
- zbirne rezultate korisnički označenih analitičkih blokova;
- parametre korišćene u poslednjoj simulaciji;
- automatsko tekstualno tumačenje rezultata.

---

## Struktura aplikacije

### Levi panel

Levi panel sadrži kontrole grupisane u sledeće sekcije:

1. **Predefinisani scenario**
2. **Ankete i ponderi**
3. **Podrška listama**
4. **Greška anketa i izborni ciklus**
5. **Izlaznost**
6. **Taktičko glasanje**
7. **Mobilizacija mladih**
8. **Manje i manjinske liste**
9. **Napredni parametri**
10. **Monte Carlo simulacija**

Promena kontrola ne pokreće automatski novi obračun. Kada završite podešavanje, kliknite **Pokreni simulaciju scenarija**.

### Glavni tabovi

1. **Rezultati** — grafikoni, tabele, sažetak, tumačenje i preuzimanje izveštaja.
2. **Parametri scenarija** — revizijski trag poslednje simulacije, korišćene ankete i liste i matrica latentnih korelacija.
3. **Metodologija** — objašnjenje toka modela, novih statističkih specifikacija, cenzusa, transfera i ograničenja.
4. **Kako koristiti aplikaciju** — detaljna objašnjenja kontrola, CSV struktura i preporučenih vrednosti.

---

## Struktura repozitorijuma

```text
serbia_election_scenario_shiny/
|
|-- app.R
|-- SerbiaElectionScenario.Rproj
|-- README.md
|-- License.md
|-- METHODOLOGY.md
|-- PARAMETER_DICTIONARY.csv
|-- REPRODUCIBILITY.md
|-- SAMPLE_OUTPUT.md
|-- MANIFEST.sha256
|
|-- data/
|   |-- default_polls.csv
|   |-- default_lists.csv
|   `-- default_scenarios.csv
|
|-- R/
|   |-- electoral_system.R
|   |-- mod_instructions.R
|   |-- mod_methodology.R
|   |-- mod_parameters.R
|   |-- mod_results.R
|   |-- mod_sidebar.R
|   |-- plotting.R
|   |-- poll_aggregation.R
|   |-- reporting.R
|   |-- scenario_presets.R
|   |-- simulation_engine.R
|   |-- tactical_voting.R
|   |-- turnout_model.R
|   |-- utilities.R
|   `-- validation.R
|
|-- tests/
|   |-- run_tests.R
|   `-- test_simulation.R
|
`-- www/
    `-- app.css
```

Glavne programske celine su:

- `R/poll_aggregation.R` — agregacija anketa, ponderi i korekcije efekta anketara;
- `R/simulation_engine.R` — Monte Carlo simulacija kompozicione podrške;
- `R/tactical_voting.R` — Beta raspodele transfera i endogena reakcija na blizinu cenzusa;
- `R/turnout_model.R` — izlaznost, nevažeći listići i mobilizacija mladih;
- `R/electoral_system.R` — izborni cenzus, manjinske liste i D’Hondt;
- `R/reporting.R` — tabele, interpretacija, PNG grafikoni i Word izveštaj;
- `R/mod_*.R` — modularni Shiny korisnički interfejs.

---

## Softverski zahtevi

Za lokalno pokretanje potrebni su:

- aktuelna verzija **R-a**;
- **RStudio Desktop** ili drugo razvojno okruženje koje može pokrenuti Shiny aplikaciju;
- internet veza samo za početnu instalaciju paketa.

Zvanična preuzimanja:

- R: <https://cran.r-project.org/>
- RStudio Desktop: <https://posit.co/download/rstudio-desktop/>

Instalirajte **R pre RStudio Desktop-a**.

---

## Potrebni R paketi

Aplikacija koristi:

```text
shiny
bslib
DT
dplyr
ggplot2
scales
MASS
officer
flextable
ragg
digest
```

Paket `testthat` potreban je samo za pokretanje testova.

Pakete možete instalirati u RStudio konzoli:

```r
required_packages <- c(
  "shiny", "bslib", "DT", "dplyr", "ggplot2", "scales", "MASS",
  "officer", "flextable", "ragg", "digest", "testthat"
)

missing_packages <- setdiff(
  required_packages,
  rownames(installed.packages())
)

if (length(missing_packages) > 0) {
  install.packages(missing_packages)
}
```

Posle instalacije po potrebi ponovo pokrenite RStudio.

---

## Preuzimanje aplikacije

### Opcija 1 — Download ZIP sa GitHub-a

Ovo je najjednostavniji način za većinu korisnika.

1. Otvorite GitHub repozitorijum.
2. Kliknite zeleno dugme **Code**.
3. Izaberite **Download ZIP**.
4. Sačuvajte ZIP datoteku na računaru.
5. Raspakujte je u običan folder u kome imate pravo pisanja, na primer u `Documents`.
6. Ne pokrećite aplikaciju direktno iz ZIP arhive.

Posle raspakivanja nemojte menjati unutrašnju strukturu foldera.

### Opcija 2 — Kloniranje pomoću Git-a

Ako koristite Git:

```bash
git clone https://github.com/MyStatisticalConsultant/serbia_election_scenario
cd serbia_election_scenario_shiny
```

Git nije potreban za uobičajeno lokalno korišćenje aplikacije; ZIP je dovoljan.

---

## Lokalno pokretanje

1. Preuzmite i raspakujte ceo repozitorijum.
2. Instalirajte R, RStudio Desktop i potrebne pakete.
3. Dvostrukim klikom otvorite:

```text
SerbiaElectionScenario.Rproj
```

4. U RStudio konzoli pokrenite:

```r
shiny::runApp()
```

Možete i otvoriti `app.R` i kliknuti **Run App**.

RStudio će prikazati lokalnu adresu sličnu adresi `http://127.0.0.1:xxxx`. Aplikacija se može otvoriti u RStudio Viewer-u ili internet pregledaču.

### Važno: ne koristite lični `setwd()`

Projekat koristi relativne putanje. Ako aplikacija ne može da pronađe `data` ili `R` folder, prvo proverite da li ste otvorili `SerbiaElectionScenario.Rproj` ili pokrenuli aplikaciju iz korenskog foldera projekta.

Nemojte u kod dodavati putanju specifičnu za svoj računar, na primer:

```r
setwd("C:/Users/Ime/Documents/...")
```

---

## Kratko uputstvo za korišćenje

1. Izaberite jedan **Predefinisani scenario**.
2. Pročitajte opis scenarija ispod padajuće liste.
3. Po želji uredite ankete, liste ili druge parametre.
4. Kliknite **Pokreni simulaciju scenarija**.
5. Na tabu **Rezultati** pregledajte glasove, mandate, cenzus, izlaznost i poređenje sa referentnim scenarijem.
6. Na tabu **Parametri scenarija** proverite šta je stvarno ušlo u poslednju simulaciju.
7. Preuzmite pojedinačne PNG grafikone ili kompletan Word izveštaj.
8. Ako naknadno promenite kontrolu, aplikacija će označiti da prikazani rezultati pripadaju prethodnoj simulaciji. Ponovo kliknite dugme za pokretanje da biste dobili nove rezultate.

Za prvo upoznavanje preporučuje se da svaki predefinisani scenario najpre pokrenete bez izmena, a tek zatim menjate po jedan parametar i posmatrate posledice.

---

## Hijerarhijska raspodela glasova mladih

U sekciji **Mobilizacija mladih** prva tri udela podešavaju se redom:

1. Studentska lista = `X%`;
2. SNS = `Y%`, najviše `100 − X`;
3. SPS = `Z%`, najviše `100 − X − Y`.

Udeo **Ostalih lista** računa se automatski kao:

```text
100 − X − Y − Z
```

Ranije postavljen procenat ostaje nepromenjen dok se podešavaju naredne liste. Ako raniji procenat ostavlja manje raspoloživog prostora, maksimum narednog slajdera automatski se smanjuje.

---

## CSV anketa

Šablon se preuzima dugmetom **Preuzmi CSV šablon** u sekciji **Ankete i ponderi**.

Obavezne kolone su:

| Kolona | Značenje |
|---|---|
| `poll_id` | Jedinstveni identifikator ankete |
| `pollster` | Naziv anketara |
| `active` | `TRUE/FALSE` ili `1/0`; određuje da li anketa učestvuje |
| `weight` | Nenegativni relativni ponder ankete |

Opcione kolone su:

| Kolona | Značenje |
|---|---|
| `fieldwork` | Period terenskog rada |
| `sample_size` | Veličina uzorka |
| `mode` | Način prikupljanja podataka |
| `student_list` | Procena podrške Studentskoj listi |
| `sns` | Procena podrške SNS-u |
| `sps` | Procena podrške SPS-u |

Ako izaberete **Ažurirane ankete i model**, među aktivnim anketama sa pozitivnim ponderom mora postojati najmanje jedna raspoloživa procena za svaku od kolona `student_list`, `sns` i `sps`.

Ponderi ne moraju ručno imati zbir 100, jer ih model interno normalizuje. Dugme **Normalizuj pondere** menja vrednosti u tabeli tako da zbir pondera aktivnih anketa postane 100, bez menjanja njihovih međusobnih odnosa.

---

## CSV izbornih lista

Šablon se preuzima u sekciji **Podrška listama**.

Obavezne kolone su:

| Kolona | Značenje |
|---|---|
| `list_id` | Jedinstveni identifikator liste |
| `name` | Naziv liste |
| `central_support` | Početna centralna podrška |
| `active` | Da li lista učestvuje u scenariju |
| `minority` | Da li se primenjuje poseban tretman manjinske liste |

Opcione kolone i njihove početne vrednosti su:

| Kolona | Početna vrednost | Značenje |
|---|---:|---|
| `uncertainty_sd_pp` | `1` | Neizvesnost podrške u procentnim poenima |
| `tactical_target` | prazno | `list_id` liste kojoj se glasovi prenose |
| `baseline_transfer` | `0` | Bazni procenat transfera |
| `lower_transfer` | `0` | Donja granica transfera |
| `upper_transfer` | `0` | Gornja granica transfera |
| `manual_shift_pp` | `0` | Ručni pomak centralne podrške |
| `analytic_bloc` | prazno | Korisnička oznaka analitičkog bloka |

`list_id` mora biti jedinstven. Za taktički transfer mora važiti `lower_transfer ≤ baseline_transfer ≤ upper_transfer`, a `tactical_target` mora odgovarati aktivnom `list_id` identifikatoru.

---

## Preuzimanja i izvoz

Sa taba **Rezultati** mogu se preuzeti:

- grafikon intervala glasova — PNG, 300 dpi;
- grafikon intervala mandata — PNG, 300 dpi;
- grafikon statusa oko cenzusa — PNG, 300 dpi;
- grafikon izlaznosti — PNG, 300 dpi;
- grafikon poređenja scenarija — PNG, 300 dpi;
- kompletan Word (`.docx`) izveštaj.

Word izveštaj sadrži naziv i opis scenarija, datum i vreme generisanja, parametre, tabele, grafikone, automatsko tumačenje, seed, broj simulacija i ID scenarija.

---

## Metodološki tok

Pojednostavljeni tok računanja je:

1. agregiranje aktivnih anketa i pondera;
2. primena izabrane jačine korekcije efekta anketara;
3. kombinovanje ažurirane procene sa istorijskim SNS+SPS sidrom, kada je taj izvor izabran;
4. simuliranje kompozicione podrške listama pomoću logističko-normalne specifikacije;
5. simuliranje taktičkih transfera pomoću skaliranih Beta raspodela;
6. povećavanje transfera u blizini cenzusa kada je taj efekat uključen;
7. simuliranje izlaznosti ograničenom normalnom raspodelom;
8. uključivanje dodatno mobilisanih mladih samo unutar marginalne izlaznosti iznad referentne vrednosti;
9. oduzimanje nevažećih listića;
10. provera izbornog cenzusa i manjinskog statusa;
11. raspodela 250 mandata D’Hondtovim metodom.

Logističko-normalna raspodela, deo korelacione strukture, skalirane Beta raspodele i funkcija endogenog transfera predstavljaju **nove, transparentno dokumentovane specifikacije simulatora**, a ne rekonstruisani originalni izvršni kod.

---

## Reproduktivnost

Svaka simulacija beleži:

- seed;
- broj Monte Carlo iteracija;
- aktivne ankete i njihove pondere;
- aktivne izborne liste;
- sve parametre scenarija;
- datum preseka podataka;
- hash konfiguracije, prikazan kao **ID scenarija**;
- verziju aplikacije.

Isti kod, podaci, parametri, seed i broj simulacija treba da daju isti rezultat.

Za evidenciju verzija R-a i paketa pokrenite:

```r
sessionInfo()
```

ili sačuvajte rezultat:

```r
writeLines(capture.output(sessionInfo()), "sessionInfo.txt")
```

Detaljnije pogledajte [`REPRODUCIBILITY.md`](REPRODUCIBILITY.md).

---

## Testovi

Iz korenskog foldera projekta pokrenite:

```r
source("tests/run_tests.R")
```

Testovi proveravaju, između ostalog:

- da simulirane podrške daju zbir 100%;
- da je zbir mandata 250;
- reproduktivnost istog seeda;
- tretman izbornog cenzusa i manjinskih lista;
- očuvanje glasova tokom taktičkih transfera;
- hijerarhijsku raspodelu glasova mladih;
- fleksibilan CSV uvoz;
- izgradnju i PNG izvoz grafikona;
- odsustvo zastarelog `geom_errorbarh()` poziva;
- da promena kontrole sama ne pokreće novu simulaciju.

---

## Rešavanje problema

### `Nedostaju R paketi`

Instalirajte pakete navedene u odeljku **Potrebni R paketi**, zatim ponovo pokrenite RStudio.

### `cannot open file` ili datoteka ne postoji

Najverovatnije aplikacija nije pokrenuta iz korenskog foldera projekta.

**Rešenje:** otvorite `SerbiaElectionScenario.Rproj`, pa ponovo pokrenite `shiny::runApp()`.

### Rezultati se nisu promenili posle izmene parametra

Promene kontrola namerno ne pokreću automatsku simulaciju.

**Rešenje:** kliknite **Pokreni simulaciju scenarija**.

### Aplikacija prijavljuje nevažeće parametre

Pročitajte sve stavke u prikazanom prozoru. Najčešći uzroci su nevažeći ponderi, nepostojeći cilj transfera, pogrešan odnos donje/bazne/gornje stope ili nepotpuna tabela anketa za ažurirani model.

### Simulacija sa 100.000 iteracija traje dugo

Za razvoj i proveru scenarija koristite 1.000 ili 5.000 simulacija. Veći broj koristite tek za završni rezultat.

### Word izveštaj se ne preuzima

Proverite da li su instalirani `officer`, `flextable` i `ragg` i da li pregledač dozvoljava preuzimanje datoteka.

### Prijavljivanje greške

Uz prijavu priložite:

- tačan tekst greške;
- korake koji dovode do greške;
- naziv izabranog scenarija;
- R i RStudio verziju;
- rezultat `sessionInfo()`;
- CSV datoteku ili snimak ekrana, ako su relevantni.

---

## Navođenje izvora

Predloženo navođenje aplikacije:

> Kovačić, Z. J. (2026). *Simulator izbornih scenarija – parlamentarni izbori u Srbiji* (verzija 0.2.4) [R Shiny aplikacija]. GitHub repozitorijum: `https://github.com/MyStatisticalConsultant/serbia_election_scenario`.

Za potpuno reproduktivno navođenje navedite i korišćenu verziju ili Git commit.

Ako koristite metodološke elemente modela, navedite i izvorni BIRODI dokument na osnovu koga je izrađena rekonstrukcija, sa bibliografskim podacima dostupnim u vašoj verziji dokumenta.

---

## Povratne informacije i prijava problema

Ako su GitHub Issues uključeni, otvorite novi Issue u repozitorijumu. Možete pisati i na:

[Zlatko@MyStatisticalConsultant.com](mailto:Zlatko@MyStatisticalConsultant.com)

Posebno su korisne povratne informacije o:

- jasnoći kontrola i metodoloških objašnjenja;
- reproduktivnosti na drugim operativnim sistemima;
- greškama pri CSV uvozu ili izvozu;
- dodatnim scenarijima koji bi bili analitički korisni;
- načinu prikazivanja neizvesnosti i rezultata oko cenzusa.

---

## Zahvalnost

Zahvalnost pripada autorima i saradnicima uključenim u izradu rekonstruisane metodološke beleške, kao i zajednici otvorenog koda čiji R paketi omogućavaju rad aplikacije.

---

## Licenca

Ovaj projekat je objavljen pod **MIT licencom**. Pogledajte [`License.md`](License.md).

MIT licenca dozvoljava korišćenje, kopiranje, menjanje, spajanje, objavljivanje, distribuciju, podlicenciranje i prodaju kopija softvera, uz zadržavanje obaveštenja o autorskom pravu i teksta licence.

---

## Autorsko pravo

Copyright © 2026 Zlatko J. Kovačić.
