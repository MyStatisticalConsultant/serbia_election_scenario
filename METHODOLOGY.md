# Metodologija simulatora izbornih scenarija

## Status modela

Aplikacija je izvedena iz dokumenta **BIRODI Scenario Model for the Next Parliamentary Election in Serbia – Reconstructed Methodological Note**, sa informacijama do 29. avgusta 2026. Izvorni dokument naglašava da je reč o rekonstrukciji uslovnog scenarijskog modela, a ne o novoj reprezentativnoj anketi i ne o potpuno izvršivom replikacionom paketu.

Zato aplikacija namerno razdvaja četiri vrste elemenata: podatke dokumentovane u izvoru, rekonstruisane vrednosti, scenario pretpostavke i nove statističke specifikacije uvedene da bi model postao transparentan izvršivi simulator.

## Tok obračuna

1. Aktivne ankete se agregiraju ponderisano.
2. Rekonstruisane pollster korekcije za SNS+SPS mogu se skalirati od 0% do 100%.
3. U live modu agregirana aktuelna procena kombinuje se sa istorijskim SNS+SPS sidrom.
4. Centralni vektor podrške prevodi se u logističko-normalnu kompozicionu raspodelu, tako da podrške u svakoj iteraciji ostaju nenegativne i ukupno daju 100%.
5. Taktički transferi koriste skalirane Beta raspodele unutar korisnički vidljivih granica. Transfer može endogeno rasti kada izvorna lista prilazi cenzusu od 3%.
6. Izlaznost se simulira ograničenom normalnom raspodelom. Izvorni dokument eksplicitno daje sredinu 63,0% i SD 1,5 procentnih poena.
7. Dodatno mobilisani mladi raspoređuju se samo unutar marginalnog dela izlaznosti iznad referentne izlaznosti, čime se izbegava dvostruko brojanje mobilizacije.
8. Od glasačkih listića se oduzimaju nevažeći listići da bi se dobio broj važećih glasova za liste.
9. Za obične liste proverava se prag od 3% od broja birača koji su glasali. Manjinske liste imaju poseban tretman u skladu sa pravilima RIK-a.
10. Raspodeljuje se 250 mandata D’Hondtovim sistemom najvećeg količnika.

## Nove statističke specifikacije

Izvorni dokument ne čuva kompletnu specifikaciju distribucija podrške niti korelacionu matricu. Zato simulator uvodi:

- logističko-normalnu raspodelu podrške;
- skalirane Beta raspodele za taktičke transfere i, po potrebi, istorijsko sidro;
- podesivu latentnu korelaciju između Studentske liste i SNS/SPS;
- logističku funkciju koja vezuje intenzitet taktičkog transfera za udaljenost od 3% cenzusa.

Ovi elementi moraju se tumačiti kao **nove specifikacije simulatora**, a ne kao navodno sačuvani delovi originalnog BIRODI izvršnog koda.

## Endogeni transfer u blizini cenzusa

Stopa taktičkog transfera nije ista u svakoj iteraciji. Najpre se izvlači bazna
stopa unutar korisnički zadatih granica, a zatim se ona može povećati kada je
simulirana podrška izvornoj listi blizu ili ispod 3%. Parametar `threshold_gamma`
određuje jačinu tog dodatnog pojačanja: 0 ga isključuje, dok 1 dopušta maksimalno
približavanje gornjoj granici. Parametar `threshold_width` određuje širinu zone
reakcije: mala vrednost daje naglu promenu neposredno oko 3%, a veća vrednost
postepen uticaj na širem rasponu podrške.

Ovaj mehanizam predstavlja transparentnu pretpostavku o mogućem strateškom
ponašanju birača, a ne direktno izmerenu individualnu stopu prelaska.

## Korelaciona struktura latentnih grešaka

Pozitivna korelacija znači da latentna odstupanja dve liste češće idu u istom
smeru, negativna da češće idu u suprotnim smerovima, a vrednost blizu nule da
nema zadate direktne latentne veze. Dijagonala matrice iznosi 1. Čak i kada je
neka latentna korelacija nula, konačni procenti ostaju kompoziciono povezani jer
se moraju sabrati na 100%.

## Hijerarhijska raspodela mobilisanih mladih

Korisnik redom zadaje udele za Studentsku listu, SNS i SPS. Udeo Studentske
liste ostaje fiksiran kada se podešava SNS, a oba ranija udela ostaju fiksirana
kada se podešava SPS. Maksimum svakog narednog slajdera jednak je procentu koji
je preostao do 100%. Udeo ostalih lista izračunava se automatski kao
`100 − Studentska lista − SNS − SPS`. Broj glasova mladih ograničen je i zadatim
fondom i brojem birača iznad referentne izlaznosti, čime se sprečava dvostruko
računanje mobilizacije.

## Izborni sistem

Implementacija koristi 250 mandata. Obične izborne liste učestvuju u raspodeli ako osvoje najmanje 3% glasova od broja birača koji su glasali. Liste nacionalnih manjina mogu učestvovati i ispod 3%; kada su ispod praga, njihovi količnici u sistemu najvećeg količnika uvećavaju se za 35%, što samo po sebi ne garantuje mandat. Ako nijedna lista ne dostigne 3%, sve liste koje su dobile glasove mogu učestvovati u raspodeli. Pravila su proverena prema javnom objašnjenju Republičke izborne komisije pri izradi aplikacije.

## Ograničenja

Simulator ne kvantifikuje izborne nepravilnosti, kupovinu glasova, medijsku nejednakost ili administrativni pritisak kao fiksni stranački bonus. Izvorna metodološka beleška eksplicitno ne uvodi takvu korekciju jer nije postojao pouzdan način da se ona proceni.

Udeo simulacija u kojima lista prelazi cenzus predstavlja uslovni Monte Carlo rezultat pod izabranim pretpostavkama, a ne automatski objektivnu realnu verovatnoću ishoda.
