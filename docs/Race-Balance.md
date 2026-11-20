# Balans ras i kontr — Vault Wars

Zasady gry, bot oraz turniej korzystają z tego samego symulatora Godot 4.2.2 i kroku 0,05 s. Parametry znajdują się w `scripts/balance_rules.gd`.

## Rasy

| Rasa | Premia stała | Odsetki bazowe | Zdolność za 120 złota, jedna fala |
|---|---|---:|---|
| Krasnoludy | +25% PŻ najeźdźców | 24% | Obecni obrońcy dostają tarczę 60 PŻ. Nie leczy, nie podnosi maksymalnych PŻ, nie kumuluje się. |
| Gobliny | +20% tempa i +5% pojemności | 18% | +25% tempa i ataki w zwarciu co 0,45 s zamiast 0,65 s. |
| Elfy | +10% PŻ i +5% pojemności | 18% | +35% pojemności. Łup trzeba dowieźć; ryzyko utraty pozostaje. |
| Voidborn | +5% tempa i +8% pojemności | 18% | +12% tempa i unik jednego uruchomienia pułapki lub rzeczywistego strzału wieży. |

Premie dotyczą również darmowych najeźdźców. Pojemność jest zaokrąglana do całych monet. Późniejsze odblokowanie rasy jest nagrodą za postęp, a nie wyższym poziomem siły.

## Kontry

- Zwiadowca kosztuje 75, ma bazowo 45 PŻ i 50 pojemności. Kolce zadają 50 obrażeń i mają trzy ładunki; zatrzymują podstawowy szybki najazd. Krasnoludzka wytrzymałość i trening zmieniają progi przeżycia.
- Tragarz kosztuje 140, ma bazowo 120 PŻ, 80 pojemności i mniejsze tempo. W zwarciu zadaje bazowo 22 obrażenia/s, inni płatni najeźdźcy 14, darmowi 10. Pomaga przebić obrońcę, ale nie łączy już najwyższej opłacalności łupu z ogromnym zapasem zdrowia.
- Wieża kosztuje 155. Strzela co 0,6 s: 16 obrażeń, przeciw tragarzom 32. Priorytetem są tragarze, następnie wróg najbliższy skarbca, zamiast pierwszego darmowego najeźdźcy w tablicy.
- Sabotażysta kosztuje 110. Rozbraja jedną strukturę, także wieżę. Kolejne warstwy obrony działają, więc sama zdolność rozbrajania nie zapewnia bezpiecznego przejścia przez całą alejkę.
- Obrońca kosztuje 130 i ma 140 PŻ. Zatrzymuje pobliskiego najeźdźcę w walce. Sidła, kolce, wieże i obrońcy mają uzupełniać się zamiast tworzyć jeden zawsze najlepszy zakup.

Kolejna jednostka tego samego typu w danej fali kosztuje o **20% ceny bazowej więcej**, również po zmianie alejki. Przykład: zwiadowcy kosztują **75 / 90 / 105 / 120 / 135 / 150**. Inny typ zachowuje własną cenę, a nowa fala zeruje dopłatę. Przycisk pokazuje koszt kolejnego zakupu. Mieszany skład pozwala wydawać złoto sprawniej.

Obie strony mają limit sześciu płatnych jednostek na falę i czterech na alejkę, pięciu struktur i trzech obrońców na alejkę. Bot płaci te same ceny i korzysta z własnej rasy, treningu, odsetek i płatnej zdolności. Reaguje na widoczną obronę oraz historię zakończonego najazdu, bez odczytywania niezrealizowanych zamówień gracza. Zachowuje rezerwę złota.

## Ekonomia i zakończenie meczu

Tylko pierwsze **1000 złota** zarabia odsetki. Minimalna wypłata wynosi 20 dla żywego skarbca. Każdy poziom banku nadal dodaje 4 p.p.; trening kosztuje kolejno **120 / 200 / 280**, co ogranicza opłacalność natychmiastowego wykupienia całości.

Od końca **fali 6** oba skarbce tracą po odsetkach odpowiednio **75, 150, 225…** złota. Licznik pokazuje obecną presję, a zasady są opisane w samouczku i Księdze gry. Stała obrona i oszczędzanie nie mogą podtrzymywać meczu bez końca. Mecz nadal kończy wyzerowanie skarbca; nie wybieramy zwycięzcy według wyniku punktowego.

Jednoczesne kradzieże rozstrzygane są po wykonaniu ruchów obu stron w danym kroku. Wyeliminowano automatyczną przewagę strony przetwarzanej jako pierwsza. Niedowieziony łup wraca do obrabowanej strony na końcu fali.

## Weryfikacja

`ci/smoke_balance.gd` sprawdza obie strony, cztery rasy, role, zdolności, trening, rosnące ceny ulepszeń, ograniczenie odsetek, brak trwałego leczenia tarczą, sabotaż, priorytety wież, unik rzeczywistego strzału, zatrzymanie przez sidła, walkę w zwarciu, równoczesną kradzież, zwrot łupu i presję skarbców.

`ci/balance_tournament.gd` porównuje oszczędzanie, bank, trening, zwiadowców, tragarzy, sabotażystów, kolce, wieże, obrońców, skład mieszany i adaptację. Pełny turniej zestawia każdą parę rasa–strategia i zamienia strony planszy. Remis daje po pół punktu. Żaden test nie ustala zwycięzcy według zapasu złota po arbitralnym limicie tur.

```sh
godot --headless --path . --script res://ci/smoke_balance.gd
godot --headless --path . --script res://ci/balance_tournament.gd -- --full --seeds=1701,42,9001 --report=balance-report.json
```

Wersja bez `--full` sprawdza pary strategii wewnątrz poszczególnych ras. Godot CI uruchamia pełny turniej i zachowuje raport przez siedem dni. Eksport APK wymaga testów mechanik balansu.

Raport opisuje skończony zbiór taktyk automatycznych. Jest narzędziem do wykrywania regresji, a nie dowodem braku wszystkich możliwych strategii dominujących w rozgrywce ludzi.

## Wynik weryfikacji — 20 listopada 2026

**3784 starcia**, dwa ziarna losowania (1701, 42), obie strony planszy, 11 strategii na cztery rasy. Remis liczony jako pół punktu.

| Rasa | Udział zdobytych punktów |
|---|---:|
| Krasnoludy | 49.02% |
| Gobliny | 52.06% |
| Elfy | 50.24% |
| Voidborn | 48.68% |

Wystąpiło **49 remisów**, **0 meczów bez rozstrzygnięcia po limicie kontrolnym**; najdłuższy mecz zakończył się w fali **15**. Każda para rasa–strategia miała porażki, a każda strategia miała inne ustawienie wygrywające z nią w większości prób. Żadna strategia nie przekroczyła 75% punktów całości; najwyższy wynik wyniósł 72.82%.

| Schemat | Najmocniejsza testowana kontra | Punkty schematu przeciw kontrze |
|---|---|---:|
| Masowi zwiadowcy | Same wieże | 14.06% |
| Masowi tragarze | Masowi zwiadowcy | 0.00% |
| Same wieże | Adaptacja | 25.00% |
| Sami obrońcy | Masowi tragarze | 31.25% |
| Oszczędzanie | Same wieże | 0.00% |
| Skład mieszany | Sami obrońcy | 9.38% |
| Adaptacja | Oszczędzanie | 0.00% |

[Raport wyników i sumy kontrolne użytego kodu](Balance-Results-2026-11-20.json) zawiera zestawienia wszystkich strategii, macierze starć, profile ras i rozbicie na ziarna. Surowe starcia można odtworzyć podaną wyżej komendą; pełny raport CI pozostaje w artefakcie. Wszystkie 11 testów integracyjnych przeszło; po końcowej korekcie obrażeń wieży powtórzono test balansu, HUD i języków.
