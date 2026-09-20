# Reproduktivnost

Aplikacija beleži:

- seed;
- broj Monte Carlo iteracija;
- aktivne ankete i pondere;
- aktivne izborne liste;
- sve scenario parametre;
- hash konfiguracije (`ID scenarija`);
- verziju aplikacije.

Za lokalnu evidenciju tačnih verzija R-a i paketa, nakon instalacije pokrenite:

```r
sessionInfo()
```

ili sačuvajte izlaz u datoteku:

```r
writeLines(capture.output(sessionInfo()), "sessionInfo.txt")
```

Kod je generisan u okruženju u kome R izvršni program nije bio dostupan, pa `sessionInfo()` za ciljnu R instalaciju nije moguće unapred generisati. Zbog toga su uključeni statičke provere strukture projekta i `testthat` testovi koje treba pokrenuti u RStudio okruženju pre produkcione upotrebe.
