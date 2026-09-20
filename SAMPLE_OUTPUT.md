# Primer očekivanog izlaza

Nakon pokretanja simulacije, tab **Rezultati** prikazuje:

- naziv i status scenarija;
- seed, broj simulacija i ID scenarija;
- medijanu i 50%/95% interval simulirane podrške za svaku listu;
- medijanu i interval broja mandata;
- udeo simulacija iznad 3% cenzusa za obične liste;
- distribuciju izlaznosti;
- analitički zbir SNS+SPS, bez spajanja lista u D’Hondt obračunu;
- poređenje trenutne simulacije sa centralnom vrednošću izabranog referentnog scenarija;
- automatski generisano tekstualno tumačenje sa numeričkim vrednostima iz poslednjeg pokretanja.

Primer formulacije teksta je:

> U izabranom scenariju, medijana simulirane podrške za listu X iznosi A%, uz 95% interval scenarija od B% do C%. Za listu Y, udeo iteracija u kojima prelazi izborni cenzus iznosi D% pod izabranim pretpostavkama. Rezultati predstavljaju modelsku posledicu izabranih pretpostavki, a ne tvrdnju da će se baš takav ishod ostvariti na izborima.

Konkretne vrednosti se namerno ne fiksiraju u ovoj datoteci: generišu se iz aktivnih parametara, podataka, seeda i broja Monte Carlo iteracija.
