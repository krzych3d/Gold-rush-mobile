# Brief 001 — Krasnoludzki Tragarz Skarbca

Data: 13 listopada 2026. Silnik: Godot 4.2.2, Android. Zakres: specyfikacja nowego kompletu klatek dla istniejącego `dwarf_carrier`, bez dodawania jednostki lub zmiany kosztu, PŻ, szybkości i pojemności. To brief produkcyjny; nowe klatki postaci nie zostały jeszcze wykonane ani zastąpione w grze.

## Pomysł i spójność ruchu

Krępy krasnolud niesie zamykaną skrzynię podpartą pasem biodrowym. Pusty porusza się szerokim, sprężystym krokiem; obciążony najpierw przenosi ciężar nad nogę podporową, następnie przestawia drugą. Biodra i barki pracują w przeciwnych fazach. Skrzynia reaguje z niewielkim opóźnieniem, ale dłonie stale dotykają uchwytów. Broda i pasy podążają za ciałem. Nie wolno zastąpić tego przesuwaniem, kołysaniem lub rozciąganiem jednego rysunku.

Styl: epicka baśń, rzeźbiona stal i mosiądz, ciemny turkus tkaniny, wyraźna twarz i kontrastowa krawędź hełmu. Małe ornamenty poza sylwetką nie są priorytetem. Monety pozostają złote, także na planszy Pustki. Silhouette musi odróżniać się na zielonym, kamiennym, jasnym elfim i fioletowym tle. Nie wypalać oznaczenia drużyny w postaci — czytelny pierścień i PŻ rysuje gra.

W ataku krasnolud opiera skrzynię na pasie i prawej dłoni, a lewym przedramieniem wykonuje krótkie odepchnięcie. Po trafieniu wraca do identycznego uchwytu. Bez teleportowania skrzyni, zmiany ręki, dodatkowego młota lub pojawiania się łupu przed kradzieżą. Wariant bez złota ma tę samą anatomię i ruch barku; zamknięta, pusta skrzynia jest wyposażeniem, widoczny blask łupu występuje tylko przy `carried > 0`.

## Czasy i kluczowe klatki

Numery od zera. Czasy dotyczą wejścia w dany stan; animacje akcji nie korzystają z globalnego zegara. Każda klatka to osobna poza z zachowaną objętością ciała. Nie duplikować ostatniej klatki na początku pętli.

| Stan / plik | Klatki, tempo, czas | Kluczowe pozy i zdarzenia |
|---|---|---|
| `idle` | 8, 8 kl./s, 1,00 s, pętla | 0 neutralnie; 2 wdech; 4 szczyt oddechu; 6 powrót. Stopy nieruchome, ruch barków 1–2 px w źródle. |
| `walk` | 12, 15 kl./s, 0,80 s, pętla | 0 lewa pięta dotyka ziemi; 2 amortyzacja; 3 noga wolna mija podporową; 5 uniesienie; 6 prawa pięta; 8 amortyzacja; 9 minięcie; 11 przygotowanie kolejnego kroku. Praca kolan i przeciwskręt tułowia. |
| `attack` | 12, 26⅔ kl./s, 0,45 s, raz | 0 stabilizacja; 2 ugięcie i cofnięcie barku (75 ms); 4 przyspieszenie (150 ms); **5 kontakt (187,5 ms)**; 6 przejście siły; 8 wyhamowanie; 11 odtworzenie uchwytu. Jedno trafienie na cykl, bez przesuwania pozycji jednostki. |
| `hit` | 6, 21 3/7 kl./s, 0,28 s, raz | 0 reakcja; 1 największy odrzut klatki piersiowej; 3 odzyskanie balansu; 5 gotowość. Ręka nie przenika przez skrzynię. |
| `death` | 12, 20 kl./s, 0,60 s + 0,20 s zatrzymania | 0 utrata siły; 2 ugięcie kolan; 4 skrzynia dotyka gruntu; 6 opadnięcie barku; 9 upadek; 11 ciało i wyposażenie spoczywają. Zamrozić 11 do końca istniejącego czasu 0,80 s. Nigdy nie wracać do 0. |
| `pickup` | 10, 15 5/13 kl./s, 0,65 s, raz | 0 oprzeć skrzynię przy wrogim skarbcu; 2 otworzyć; 4–6 napełnić; 7 zamknąć; 9 stabilny chwyt. To istniejący postój kradzieży, a nie animacja oddania łupu. |
| `carry` | 12, 15 kl./s, 0,80 s, pętla | Kontakty 0 i 6 jak w `walk`; 2/8 dłuższe oparcie; 3/9 mniejszy wymach nogi. Skrzynia pozostaje w dłoniach, tułów pochylony 5–8°, bez mechanicznej kary do szybkości. Wrażenie ciężaru daje poza, nie zmiana statystyki. |
| `deposit` | 12, 16 kl./s, 0,75 s, raz | 0 ustawić skrzynię przy własnym skarbcu; 2 oprzeć; 4 otworzyć; 5–8 wysypać monety; 9 zamknąć pustą; 11 rozluźnić chwyt. Po zakończeniu usunąć wizualnego aktora. |

Minimum produkcyjne: najpierw zatwierdzić wszystkie cztery główne akcje E/W (`walk`, `attack`, `death`, `carry`) w szarej animacji, potem klatki przejść i pozostałe kierunki. Etap E/W to 96 klatek głównych akcji, nie kompletny finalny pakiet. Pełny zakres poniżej obejmuje 672 klatki. Szacunkowy nakład dla animatora 2D: 5–8 dni roboczych przy wykorzystaniu zatwierdzonego modelu postaci i kontroli póz; to szacunek, nie deklaracja terminu.

## Kierunki, punkt stóp i ruch powrotny

Osiem rzędów każdego atlasu, w kolejności: **E, SE, S, SW, W, NW, N, NE**. E to ruch w prawo ekranu, S w dół. Kierunek obliczać z rzeczywistej prędkości po projekcji planszy, kwantyzując kąt do 45°. Dla prawie zerowej prędkości zachować ostatni kierunek, a przy ataku używać wektora do celu. Kierunki są rysowane osobno, bez obracania płaskiego sprite'a i bez lustrzanego przerzucania skrzyni na drugą rękę.

Obecne `_point()` prowadzi wszystkie trzy alejki poziomo, więc w meczu używa E/W. Pozostałe sześć kierunków służy kontrolowanemu podglądowi i przyszłym zakrętom; nie zmieniać obecnych tras tylko po to, aby je pokazać. Powrót strony 0 to W, a strony 1 to E. Po pobraniu łupu zmienić kierunek i stan na `carry`, nigdy nie odtwarzać chodzenia wstecz. Obrót wykonać na stabilnej podporze przez 2–3 pozy już przewidziane w końcówce `pickup`; nie obracać całego obrazka wokół środka.

Komórka **128×128 px**, wspólny punkt stóp **(64,112)**, przezroczysta przestrzeń pod stopami 16 px. Ten punkt odpowiada położeniu jednostki w świecie, również przy śmierci i odkładaniu. Margines po bokach i u góry co najmniej 8 px dla ciała, wyposażenia i ruchu; efekty nie mogą wyjść do sąsiedniej komórki. Kolorystyka i wzrost pozostają stałe we wszystkich kierunkach. Cień rysuje silnik, bez cienia wypalonego w PNG.

## Układ spritesheetów i budżet

Osiem osobnych PNG RGBA, po jednym na akcję, pod `assets/epic/animations/dwarf_carrier_v2/`. Kolumny to kolejne klatki, rzędy to kierunki. Bez napisów, ramek, tła i wspólnej planszy pokazowej.

| PNG | Kolumny × rzędy | Rozmiar px | Pętla |
|---|---:|---:|---|
| `idle.png` | 8 × 8 | 1024 × 1024 | tak |
| `walk.png` | 12 × 8 | 1536 × 1024 | tak |
| `attack.png` | 12 × 8 | 1536 × 1024 | nie |
| `hit.png` | 6 × 8 | 768 × 1024 | nie |
| `death.png` | 12 × 8 | 1536 × 1024 | nie; ostatnia zatrzymana |
| `pickup.png` | 10 × 8 | 1280 × 1024 | nie |
| `carry.png` | 12 × 8 | 1536 × 1024 | tak |
| `deposit.png` | 12 × 8 | 1536 × 1024 | nie |

84 klatki × 8 kierunków = **672 klatki**. Nieskompresowane RGBA8: **42 MiB bez mipmap**, około 56 MiB z pełnym łańcuchem mipmap. To budżet jednego pakietu, nie całej gry. Maksymalny bok 1536 px mieści się w limicie 2048. Import: filtrowanie liniowe, repeat wyłączony, bez stratnej kompresji obwódek alfa; sprawdzić wariant mobilnej kompresji na docelowym telefonie. Nie tworzyć węzła dla każdej klatki lub monety. Ładować na żądanie pakiet używanej rasy/roli, nie osiem atlasów wszystkich ras podczas startu.

Metadane `manifest.json`: wersja 2, `cell_size`, `foot_anchor`, kolejność kierunków oraz dla każdej akcji `file`, `frame_count`, `duration`, `loop`, `hold_last`, opcjonalnie `impact_time`. Prostokąt źródła: `Rect2(frame*128, direction*128, 128, 128)`. Żadnych pustych komórek udających brakujące pozy. Hash każdej klatki i kontrola kontaktowa wyłapią kopie, lecz samo różne pikselowo tło nie potwierdza animacji ciała.

## Integracja z obecną grą

1. Nie podmieniać obecnego `dwarf_carrier_sheet.png` arkuszem o innej geometrii. Renderer `scripts/game.gd` używa `draw_texture_rect_region` i stałych komórek 128 px, a nie `AnimatedSprite2D`. Dodać odrębny czytnik metadanych v2 z kontrolą wymiarów i zachować obecny atlas jako fallback przy niekompletnym pakiecie.
2. Z jednego helpera pobierać klatkę i kierunek dla pola bitwy, `scripts/menu_preview.gd` i studia animacji. Obecne stare arkusze mają sześć rzędów akcji; nowych ośmiu rzędów kierunków nie wolno interpretować jako tych samych akcji.
3. Dodać lokalny czas stanu/odległość kroku do aktora. Chód i niesienie synchronizować z przebytą odległością: kontakty 0/6 przypadają na pół kroku; przy zatrzymaniu czas kroku staje. Nie dodawać przesunięcia pozycji w samym sprite'cie, ponieważ ruch świata wykonuje `_simulate()`.
4. Priorytety: `death` → `hit/stun` → `attack` → `pickup` → `carry` (tylko `returning && carried>0`) → `walk` → `idle`. Aktor `deposit_actors` obsługuje osobno własny skarbiec. Obrona i atak nigdy nie mogą przez pomyłkę przełączyć załadowanego tragarza w pusty wariant.
5. **Kontakt ataku wymaga zmiany w przyszłej integracji**: obecne `_guard_combat()` odejmuje PŻ przed rozwinięciem animacji. Przy starcie odłożyć trafienie z `attack_id`, zapisać cel i sprawdzić go ponownie w 187,5 ms. Przekroczenie czasu między tickami emituje kontakt dokładnie raz, także przy pominięciu renderowanej klatki 5. Śmierć, przerwanie lub utrata celu anulują oczekujące trafienie. Zachować istniejący cooldown i obrażenia, nie dodawać drugiego odjęcia PŻ w funkcji rysującej. To praca do wykonania z atlasem, nie już wdrożona poprawka.
6. `steal_timer=0.65` mapuje na `pickup`; `deposit_actors.age` na `deposit` trwające 0,75 s; `fallen_actors.age` na `death` + zatrzymanie do 0,80 s. W obecnej logice przelew złota następuje przy dotarciu do skarbca, a oddawanie jest potwierdzeniem wizualnym. Nie dopisywać przelewu przy klatce wysypywania. Złoto ofiary śmierci rozliczać wyłącznie istniejącą ścieżką symulacji.
7. Wykorzystać wspólne `_unit_art_size()` i `_unit_art_rect()`: kwadratowe proporcje, ten sam punkt stóp dla żywej jednostki, zwłok i oddawania. PŻ nad hełmem; znaczek łupu przy skrzyni i zawsze z tą samą skalą. Obrót telefonu zmienia układ interfejsu i dopasowanie mapy, nie atlas, trasę, kierunek, łup, fazę kroku ani stan meczu.
8. Po podpięciu: `ci/asset_manifest.py --write`, potem `--check`; uruchomić walidację Godot 4.2.2 oraz testy animacji, HUD, księgi, języków i obracania. Nie oznaczać pakietu jako gotowego na podstawie samego udanego importu.

## Kryteria odbioru

- **Anatomia i ruch**: 12 kolejnych klatek `walk` pokazuje zmianę podpory i ugięcia kolan; tułów, ręce i skrzynia zmieniają wzajemne położenie. Żadna para klatek pętli nie jest kopią przetransformowanej wycinanki. Brak podmiany twarzy, dodatkowych palców, zgubionych uchwytów i migotania obrysu.
- **Kontakt z gruntem**: na nieruchomej mapie przy ruchu stopy podporowej dopuszczalny poślizg do 2 logicznych px przez fazę podporu; w spoczynku punkt stóp dryfuje najwyżej 1 px. Nie używać pływania całej postaci zamiast pracy nóg.
- **Akcje**: 100 ataków daje najwyżej 100 zdarzeń kontaktu, ani jednego przed fazą kontaktu. Test przy 15/30/60 FPS i skoku czasu 100 ms nie podwaja trafień. 100 śmierci nie wraca do pierwszej klatki i nie przesuwa zwłok do skarbca.
- **Złoto**: przebieg pusty chód → pobranie u wroga → powrót w przeciwnym kierunku → oddanie we własnym skarbcu. Suma złota przed i po animacji jest zgodna z symulacją. Śmierć z łupem nie uruchamia oddania i nie dopisuje monet ponownie. Rozładunek nie pojawia się w środku alejki.
- **Kierunki**: test ośmiu rzędów i obu drużyn. E/W w grze odpowiada rzeczywistemu ruchowi, a uchwyt skrzyni nie zamienia rąk. Zatrzymanie na granicy sektora nie powoduje migotania dwóch kierunków.
- **Czytelność**: w pionie 720×1280, poziomie 1280×720 i szerokim 1560×720 mapa pokazuje oba skarbce, bez śledzenia kamery. Dla wszystkich pięciu plansz odróżnić chód od niesienia oraz atak od trafienia na 64-pikselowej komórce ekranowej. Oznaczenia PŻ, drużyny i łupu nie zasłaniają twarzy.
- **Obrót**: 20 obrotów w czasie chodu, ataku, śmierci, oddawania i animacji arsenału nie zeruje `action_time`, nie zmienia celu, nie wydaje złota, nie odtwarza trafienia i nie zmienia wzrostu postaci między stanami. Sprawdzić też oba kierunki poziome, powrót z tła i wcięcie ekranu.
- **Android**: na wskazanym słabszym telefonie mierzyć minimum 60 s bitwy z 30 aktorami i efektami. Cel: stabilne 30 FPS, 95. percentyl czasu klatki ≤33,3 ms po rozgrzaniu, bez trwałych spadków podczas równoczesnego oddania i śmierci. Zanotować model, Android, użycie pamięci i profil jakości; wynik desktopowy nie zastępuje telefonu. Oddzielnie sprawdzić płynność animacji w profilu oszczędnym.

## Następny brief i brak powtórek

Następna rasa: **Pustka**, główny nacisk: **atak**. Następnie gobliny / śmierć, krasnoludy / wynoszenie złota, Pustka / chód. Każdy brief nadal musi pokrywać komplet głównych akcji. Odróżniać pomysły po pracy ciała, sposobie trzymania łupu, rytmie i mechanice przejść, nie samym kolorze, nazwie lub numerze pliku. W tym briefie cechą rozpoznawczą jest fizyczne podparcie skrzyni na pasie biodrowym i zachowanie uchwytu podczas odepchnięcia przedramieniem.
