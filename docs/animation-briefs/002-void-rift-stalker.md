# Brief 002 — Tropiciel Szczeliny (Pustka / Void Stalker)

Data: 20 listopada 2026. Godot 4.2.2, Android. Główny nacisk: **atak**. Status: **brief_only** — specyfikacja do wykonania, bez gotowych klatek, płatnej generacji, wdrożenia renderera ani zmian balansu.

Podstawa: aktualny main krzych3d/Gold-rush-mobile, commit d1ed840704c8b80ae68c223e54b3bee3ad88b36e; przeczytano scripts/game.gd, index.json i cały brief 001 z 13.11.2026. Katalog zawiera tylko 001 i indeks; numer 002 i poniższy fingerprint są wolne. Nowy wariant dotyczy istniejącego klucza void_stalker, nie nowej jednostki w sklepie. Rotacja: krasnoludy/chód → **Pustka/atak** → gobliny/śmierć → krasnoludy/wynoszenie złota.

## 1. Tożsamość ruchu i granice mechaniki

Smukły baśniowy zabójca w obsydianowej zbroi wykonuje **pchnięcie krótkim ostrzem prawą ręką, napędzane przeciwskrętem bioder i barków oraz krokiem przechodzącym**. Najpierw zgina kolano i cofa łokieć, następnie wypycha biodro, prowadzi ostrze, wyhamowuje tułowiem i sprowadza rękę do gardy. To nie zamach całym nieruchomym obrazkiem ani obrót wycinanki.

Lewa dłoń stabilizuje przy lewym biodrze niewielki sztywny skórzano-metalowy pojemnik na monety. Pojemnik ma własny stelaż, dlatego zachowuje objętość pusty i pełny. Jest wyposażeniem, a nie złotem pojawiającym się przed kradzieżą. Podczas walki lewy łokieć osłania zamknięty pojemnik; prawa ręka nie zmienia broni ani strony. Przy niesieniu tułów osłania łup i ręka wyraźnie zaciska uchwyt. Monety widać podczas pobierania i oddawania, a oznaczenie posiadanego łupu tylko dla carried > 0. Zamknięty pojemnik pozwala współdzielić idle/attack/hit/death bez podwajania atlasów.

Odróżnienie od 001: brak skrzyni na pasie podpierającym ciężar, brak uderzenia przedramieniem i szerokiego krasnoludzkiego kołysania. Tutaj dominuje skrętny łańcuch stopa–kolano–biodro–bark–łokieć–ostrze oraz kontrbalans lewej ręki. Fingerprint: **cross-step-right-blade-thrust-left-hip-rigid-coin-case-protective-elbow**.

Styl: epicka baśń, obsydian, chłodny srebrny obrys, oszczędne ametystowe akcenty. Twarz i ostrze czytelne, monety złote. Bez neonowej chmury zasłaniającej nogi, znikania ciała, teleportacji i obietnicy jakości AAA. Zewnętrzny kontur ma pozostać czytelny na jasnych elfach, zieleni goblinów, kamieniu i fiolecie Pustki. Drużynę i PŻ rysuje UI.

**Nie zmieniać parametrów.** Dla rasy 3, kind 0, bez treningu i aktywnej zdolności: koszt 75, PŻ 45, szybkość 0,21 × 1,10 = 0,231 postępu/s, pojemność 50 + 15 = 65. To wynik obecnego raider_stats(), nie nowa propozycja. Zachować trening, Shadow Step, ceny, odsetki i odblokowanie Pustki na poziomie 10. Obecny cios tej opłaconej jednostki w obrońcę to 14 × 0,65 = 9,1 PŻ przy strike_cooldown 0,65 s i zasięgu kontaktu <48 jednostek świata. Nie stosować do niej parametrów ataku obrońcy (26 PŻ / 0,9 s).

Animacja nie zatrzymuje postępu jednostki, nie przesuwa root, nie zwiększa zasięgu ostrza, nie dodaje uniku, ogłuszenia, splash damage ani kary za łup. Złudzenie impetu tworzą pozy i praca nóg. Czasy kradzieży 0,65 s, wizualnego oddania 0,75 s i zwłok 0,80 s pozostają zgodne z kodem.

## 2. Komplet klatek, czas i pętle

Numeracja od zera, czas od początku klipu; t = numer / FPS. W tabeli ms zaokrąglono do 0,1. Animacje jednorazowe mają lokalny czas, nie globalny visual_time. Każda klatka jest nową pozą ciała; ostatnia klatka pętli nie jest kopią pierwszej.

| Klip | Klatki / FPS / czas / pętla | Kluczowe klatki i czasy |
|---|---|---|
| idle | 6 / 6 / 1000 ms / tak | 0: 0 ms neutralnie; 2: 333,3 ms delikatny wdech; 3: 500 ms barki najwyżej; 5: 833,3 ms powrót. Stopy zakotwiczone, palce na uchwycie. |
| walk | 10 / 15 / 666,7 ms / tak | 0: 0 ms lewy kontakt; 1: 66,7 amortyzacja kolana; 2: 133,3 noga wolna przechodzi; 4: 266,7 wybicie; 5: 333,3 prawy kontakt; 6: 400 amortyzacja; 7: 466,7 minięcie; 9: 600 przygotowanie lewego kontaktu. Miednica i barki przeciwnie, łokieć pracuje względem tułowia. |
| attack | 12 / 26⅔ / 450 ms / nie | 0: 0 ms obniżenie środka ciężkości; 1: 37,5 ugięcie kolana; 2: 75 cofnięcie prawego łokcia i skręt biodra; 3: 112,5 przyspieszenie ostrza; **4: 150 ms kontakt**; 5: 187,5 przejście siły; 6: 225 krok przechodzący; 8: 300 wyhamowanie barku i cofnięcie ostrza; 10: 375 garda; 11: 412,5 stabilny uchwyt. Koniec 450 ms. |
| hit | 4 / 100/7 ≈14,286 / 280 ms / nie | 0: 0 ms reakcja klatki piersiowej; 1: 70 ms największe ugięcie; 2: 140 odzyskanie balansu biodrem; 3: 210 gotowość. Dłonie zachowują kontakt z wyposażeniem. To reakcja wizualna, nie dodatkowy stun. |
| death | 12 / 20 / 600 ms + hold do 800 ms / nie | 0: 0 ms utrata napięcia; 2: 100 kolano ustępuje; 4: 200 lewa ręka opuszcza pojemnik; 6: 300 bark i biodro opadają; 8: 400 podparcie na ziemi; 10: 500 ciało osiada; 11: 550 bezruch. Ostatnia klatka pozostaje do age=0,80 s, bez pętli i znikania w połowie upadku. |
| pickup | 10 / 200/13 ≈15,385 / 650 ms / nie | 0: 0 ms otwarcie przy wrogim skarbcu; 2: 130 ms odchylenie wieka; 4: 260 zebranie monet lewą dłonią; 5: 325 zamknięcie; 6: 390 początek nawrotu na podporze; 7: 455 przestawienie stóp; 8: 520 przeciwskręt tułowia; 9: 585 chwyt i sylwetka gotowa do przeciwnego kierunku. |
| carry | 10 / 15 / 666,7 ms / tak | Kontakty 0: 0 ms i 5: 333,3 ms; ugięcia 1/6: 66,7/400 ms; minięcia 2/7: 133,3/466,7 ms; wybicia 4/9: 266,7/600 ms. Lewa dłoń na uchwycie, łokieć osłania pojemnik, prawy nadgarstek stabilizuje ostrze. Ciężar wyrażony pracą bioder, nie spowolnieniem statystyki. |
| deposit | 12 / 16 / 750 ms / nie | 0: 0 ms podniesienie pojemnika we własnym skarbcu; 2: 125 ms otwarcie; 4: 250 przechylenie; 5: 312,5 początek wysypania; 7: 437,5 ostatnie monety; 9: 562,5 puste wnętrze; 11: 687,5 zamknięcie i rozluźnienie. Usunięcie aktora w 750 ms. |

Walk/carry: nominalne 15 FPS przy bazowej szybkości. Faza pętli wynika z faktycznie przebytej odległości, nie losowego offsetu ani mijającego czasu podczas postoju. Referencyjna długość pełnego kroku: 0,231 × 2100 × 2/3 = **323,4 jednostki świata**. Przy treningu faza przyspiesza z prędkością symulacji; przy postoju/stunie stoi. Nie przyspieszać pickup, death i deposit treningiem. Atak jest krokiem przechodzącym, ponieważ obecna symulacja może przesuwać jednostkę podczas ciosu; nie rysować zablokowanej stopy pod przesuwanym rootem.

### Kontakt ataku bez niezamówionej zmiany balansu

Obecne _guard_combat() odejmuje PŻ **w ticku kontaktu**, przed odtworzeniem attack_time. Przesunięcie tego odjęcia o 150 ms mogłoby zmienić wynik walki i nie jest częścią zlecenia.

W przyszłej integracji przewidzieć jedną informację **attack_contact(attacker_id, target_id, strike_seq, damage)**, emitowaną raz z autorytatywnej ścieżki istniejącego ciosu, w tym samym ticku co obecne odjęcie 9,1 PŻ. Odbiorcy aktualizują wyłącznie pozę/VFX; nigdy ponownie PŻ, złoto lub cooldown. Użyć stabilnych identyfikatorów aktorów i rosnącego strike_seq, nie indeksu przesuwającej się tablicy.

Przy widocznym zbliżaniu do obrońcy można rozpocząć **wyłącznie wizualną, odwoływalną antycypację** klatkami 0–3 około 150 ms przed przewidywanym kontaktem (na podstawie tej samej alejki, dystansu i cooldownu). Nie rezerwuje ona ciosu i nie zmienia ruchu. Jeśli predykcja się nie potwierdzi, powrót do gardy bez zdarzenia. Gdy rzeczywisty kontakt nastąpi, ustawić klatkę 4 i jej zegar, następnie odtworzyć 5–11 przez pozostałe 300 ms. Nie powtarzać przygotowania po trafieniu. Na czas ewentualnej pozostałej części istniejącego attack_time=0,45 s utrzymać gotową gardę z oddechem, bez drugiego uderzenia.

Jeżeli kontakt zaskoczy animatora (spawn przy obrońcy, pominięte ticki, nagły cel), **pominąć brakujące przygotowanie i wejść w 4**. Zachowanie dotychczasowego momentu obrażeń ma pierwszeństwo; nie obiecywać pełnych 150 ms telegraphu w takim przypadku. W studiu klip zawsze pokazuje pełne 0–11. Gwarantowany telegraph przed każdym ciosem wymagałby osobnej decyzji o zmianie timingu walki — poza tym briefem.

Nie emitować trafień przy przekroczeniu klatki w funkcji rysującej. Zmiana kierunku, pauza podglądu, obrót telefonu, kilka renderów jednego ticku i odtworzenie VFX nie mogą ponowić strike_seq. Pozbawiona kontaktu antycypacja nie emituje zdarzenia.

## 3. Osiem kierunków, nawrót i kotwica

Każdy atlas: rzędy **E, SE, S, SW, W, NW, N, NE**. E to prawo ekranu, S dół. Dla ruchu używać rzeczywistego wektora po _iso_project(); sektor 45°, z histerezą 5° i zachowaniem ostatniego kierunku poniżej 0,5 logicznego px/s. Atak orientować do celu; jego kierunek zachować przez kontakt i odzyskanie gardy. Bez obrotu płaskiego obrazu i bez odbijania E do W: prawa dłoń z ostrzem oraz lewy pojemnik mają pozostać po anatomicznie właściwych stronach.

Aktualne _point() daje tylko poziome trasy. W meczu strona 0: E na wyprawie, W w powrocie; strona 1 odwrotnie. Pozostałe sześć kierunków należy sprawdzić w podglądzie, nie dodawać zakrętów mapy, żeby je wykorzystać. Nie odtwarzać chodu wstecz.

**Wyjątek przejściowy pickup:** jego rząd oznacza kierunek wejściowy D. Klatki 0–5 patrzą na wrogi skarbiec, 6–9 fizycznie wykonują półobrót; końcowa poza patrzy w D+4 modulo 8. Po zakończeniu wybrać carry z rzędu przeciwnego. W _simulate() returning staje się true już przy rozpoczęciu steal_timer: zapisać pickup_dir **przed** tą zmianą i trzymać go przez całe 0,65 s. Nie wyznaczać rzędu pickup ponownie z returning co render.

Komórka **128×128 px**, punkt stóp/root **(64,112)**, wspólny w każdym klipie i kierunku. Obrys i ostrze mieszczą się w x=8…119, y=8…119; żadne piksele nie dotykają brzegu. Podstawowy kontakt stóp y=112, poniżej 16 px przestrzeni, z dopuszczeniem wyposażenia upadłej postaci do y=119. Cień i pierścień drużyny rysuje silnik. Trzymać wysokość stojącej postaci około 92 px w źródle (korona głowy około y=20); zmiany wysokości wynikają z ugięcia, nie skalowania całego ciała.

Obecne _unit_art_rect() stosuje 0,88 wysokości, czyli 112,64 px przy komórce 128. W przyszłej gałęzi v2 użyć dokładnej kotwicy manifestu: lewy górny róg = -Vector2(64,112)/128 × art_size. Zachować _unit_art_size() i położenie świata; nie przesuwać istniejących atlasów. Bez dodatkowego proceduralnego bob/tilt dla nowego pakietu — ruch jest narysowany w klatkach.

## 4. Dokładne arkusze i koszt pamięci

Docelowy katalog po wykonaniu grafiki: assets/epic/animations/void_stalker_v2/. **Osiem PNG RGBA8**, jedno na klip. Kolumny to klatki, rzędy to kierunki. Pickup ma powyższą semantykę kierunku wejściowego. Bez tekstu, ramek, tła, pustych pól i plansz pokazowych.

| Plik | Kolumny × rzędy | Rozmiar px | RGBA8, bez mipmap |
|---|---:|---:|---:|
| idle.png | 6 × 8 | 768 × 1024 | 3 MiB |
| walk.png | 10 × 8 | 1280 × 1024 | 5 MiB |
| attack.png | 12 × 8 | 1536 × 1024 | 6 MiB |
| hit.png | 4 × 8 | 512 × 1024 | 2 MiB |
| death.png | 12 × 8 | 1536 × 1024 | 6 MiB |
| pickup.png | 10 × 8 | 1280 × 1024 | 5 MiB |
| carry.png | 10 × 8 | 1280 × 1024 | 5 MiB |
| deposit.png | 12 × 8 | 1536 × 1024 | 6 MiB |

76 klatek × 8 = **608 osobnych klatek**, 9 961 472 piksele, **39 845 888 bajtów = 38 MiB RGBA8**. Pełny łańcuch mipmap to około 50,7 MiB; specyfikacja mobilna domyślnie wyłącza mipmapy. Maksymalny bok 1536 px, poniżej budżetu 2048 px.

To koszt samych nowych tekstur jednej roli, nie całej aplikacji. Obecny game.gd ma również preładowane starsze atlasy; samo dodanie pakietu ich nie zwolni. Podczas importu/dekodowania kopia CPU i GPU mogą kosztować łącznie około 76 MiB dla tego pakietu, plus istniejące zasoby i bufory silnika. Rozmiar skompresowanego PNG/APK nie jest zużyciem VRAM. Wybranie jednego rzędu przez draw_texture_rect_region nie zmniejsza pamięci całej tekstury.

Manifest v2: character_key=void_stalker, cell_size=[128,128], foot_anchor=[64,112], directions w powyższej kolejności; dla każdego klipu file, frame_count, duration_s, loop, hold_last_until_s; attack ma contact_frame=4 i contact_time_s=0.15 **w czasie klipu, nie jako opóźnienie naliczania PŻ**. Pickup dodatkowo entry_direction_to_opposite=true. Rozmiar źródła: Rect2(frame*128, direction*128,128,128). Walidator sprawdza wymiary, liczbę klatek, komplet ośmiu kierunków, alfa-marginesy i SHA-256 plików.

Import: filtr liniowy, repeat off, bez stratnych obwódek alfa; złożyć osiem klatek obok siebie na czarnym/jasnym/fioletowym tle i sprawdzić bleeding. Przy profilu kompresji mobilnej sprawdzić realny format i jakość na słabszym Androidzie; do budżetu bezpieczeństwa przyjąć RGBA8. Nie obiecywać wsparcia konkretnego formatu kompresji na każdym GPU.

## 5. Plan integracji z istniejącym rendererem — do wykonania później

1. **Nie nadpisywać void_stalker_sheet.png arkuszem o innej geometrii.** Obecny loader akceptuje 1024×768, sześć rzędów akcji i osiem klatek. W _ready() dodać odrębny, walidowany loader manifestu v2; na brak całego pakietu zostawić istniejący fallback. Nie uruchamiać walidacji/dekodowania obrazów wewnątrz _draw_arena().
2. Dopasować klucz przez _character_key_for_race(3,0,false). Nie podmieniać void_sentinel, void_collector, void_weaver ani aktualnych przeciwników-botów: _character_key() dla side != 0 używa dziś innych atlasów. E/W i obie drużyny nowego pakietu sprawdzić w izolowanym podglądzie bez zmiany doboru botów.
3. Wspólny selektor klipu/źródłowego Rect2 dla _draw_arena(), scripts/menu_preview.gd i scripts/animation_gallery.gd. Rysować nadal przez draw_texture_rect_region; bez założenia AnimatedSprite2D. Kierunkowe wiersze nie są starymi rzędami akcji. Dla v2 nie wywoływać odbicia ujemnej osi X z _directional_sprite_transform(p,facing); zastosować dodatnią bazę, właściwy rząd i kotwicę manifestu. Stare ścieżki renderowania pozostają obsługiwane.
4. Dodać metadane prezentacji aktora: identyfikator, clip, clip_time, last_dir, pickup_dir, stride_distance, strike_seq i ostatni odebrany kontakt. Root i statystyki pozostają w _simulate(). Antycypacja ataku to prezentacja; jedyny rzeczywisty kontakt pochodzi z istniejącego ticku _guard_combat(). Rysowanie nie modyfikuje symulacji.
5. Przejścia żywej jednostki: death ma pierwszeństwo nad wszystkim; pickup przy steal_timer>0 zachowuje czas kradzieży i wejściowy kierunek; stun/hit mogą przesłonić pozę ruchu, lecz nie zmieniają cooldownu ani nie cofają przelewu. Następnie attack, carry wyłącznie dla returning && carried>0, walk przy ruchu, idle przy postoju. Powrót z zerowym łupem używa walk, nie carry. Po reakcji wrócić do stanu wynikającego z danych, bez ponawiania kontaktu.
6. Kradzież jest księgowana na początku postoju w _simulate(). Pickup wyłącznie ją pokazuje. Powrót do własnego skarbca dopisuje carried i usuwa jednostkę już przed animacją deposit_actors; rozładunek 0,75 s nie wykonuje drugiego przelewu. Dla amount=0 nie pokazywać wysypywanych monet. Zgon z łupem korzysta z istniejącego zwrotu do uprawnionego skarbca; bez rozrzucania zbieralnych monet, dodatkowego transferu i przejścia death→deposit.
7. Uzupełnić snapshot w _record_fallen() o kierunek/stan wizualny, zanim żywy aktor zostanie usunięty. Obecna kopia nie przechowuje carried; jeżeli znacznik łupu jest potrzebny na zwłokach, zachować has_loot wyłącznie prezentacyjnie. Fallen.age wybiera klatkę 0…11 bez modulo, utrzymuje 11 i usuwa przy 0,8 s. Deposit.age wybiera 0…11 i usuwa przy 0,75 s; zapisać kierunek powrotu. Wspólna skala obowiązuje także zwłoki i oddanie.
8. Dla v2 zastąpić/wyłączyć stary _draw_carried_gold() jako dekoracyjny obiekt przy stałym przesunięciu, jeżeli dubluje pojemnik; zostawić czytelny znacznik ilości łupu. Nie nakładać starego _draw_attack_effect() na każdą klatkę ataku: jeden krótki akcent z attack_contact, bez dodatkowych monet lub bryły zasłaniającej ostrze.
9. Ładować wspólny pakiet na żądanie dla faktycznie używanej roli i współdzielić tekstury pomiędzy aktorami/podglądem, nie kopiować ich dla jednostek. Jedna jednostka nie wymaga własnych węzłów na monety lub klatki. Zweryfikować faktyczny koszt współistnienia starego preładowanego atlasu z v2; optymalizacja cache całej gry jest osobną pracą.
10. Zachować nieruchomą kamerę, camera_offset=ZERO i pełne granice 2400×1060 z oboma skarbcami. _unit_art_size() utrzymuje kwadratową komórkę o ekranowej wysokości 58–86 logicznych px. Pion z menu, poziom z wysuwanym arsenałem oraz obrócenie telefonu nie zmieniają pozy, czasu, łupu, trasy ani proporcji.
11. Po wykonaniu klatek: ci/asset_manifest.py --write i --check; import Godot 4.2.2; istniejące smoke_animation_gallery, smoke_battle_presentation, smoke_lobby_codex, smoke_localization, smoke_account_progress i smoke_reward_presentation. Dopiero wtedy testy v2 oraz pomiar urządzenia. Ten brief nie dodaje implementacji i nie deklaruje, że te nowe animacje już przeszły testy.

## 6. Kryteria odbioru i pomiar

| Obszar | Konkretny warunek odbioru po implementacji |
|---|---|
| Rzeczywisty ruch | Kontakt sheet i odtworzenie 0,25× pokazują zmianę podpory, ugięcie kolan, skręt miednicy, niezależny bark/łokieć i chwyt. Zakazane generowanie pętli samą translacją/skalą/obrotem jednego rysunku. Brak zmiany ręki, twarzy, liczby palców i długości ostrza. |
| Atak | 100 rzeczywiście naliczonych ciosów = dokładnie 100 unikalnych attack_contact, zawsze w tym samym ticku/PŻ co referencyjna gra. Każda anulowana antycypacja = 0 kontaktów. Brak podwójnego kontaktu po redraw, 15/30/60 FPS, przerwie 100 ms, hit/stun i obrocie. Pełne 0–11 w podglądzie; normalna antycypacja→kontakt→garda w zbliżeniu; nagły kontakt przechodzi od razu do 4 bez opóźniania obrażeń. |
| Balans | Dla identycznych wejść, seed i dt porównać starą/nową prezentację: identyczne ticki i wartości PŻ, cooldowny, pozycje, chwile kradzieży, złoto i wynik. Żadnych opóźnień 150 ms dodanych do symulacji. |
| Stopy i wyposażenie | Idle: dryf root ≤1 logiczny px; faza podparcia przy ruchu: poślizg ≤2 logiczne px, oceniony względem nieruchomej mapy. Pojemnik zostaje w lewej dłoni/na uchwycie, ostrze w prawej; brak przenikania ciała i wychodzenia poza alfa-margines. |
| Śmierć | 100 zgonów, z łupem i bez: odtworzenie raz, klatka 11 utrzymana do 0,8 s, brak powrotu do 0, brak oddania po śmierci i brak dodatkowego przelewu. |
| Złoto | Pusty walk → pickup wyłącznie przy wrogim skarbcu → nawrót → carry w przeciwnym kierunku → deposit wyłącznie u siebie. Sprawdzić pełny, częściowy i zerowy łup oraz śmierć w trakcie powrotu. Suma złota i chwile księgowania identyczne jak przed zmianą; brak utraty pojemnika na zmianie stanu. |
| Kierunki | Osiem odrębnych rzędów i stała anatomia rąk. Granice sektorów nie migoczą. E/W w prawdziwym meczu, sześć pozostałych w podglądzie; pickup D kończy w D+4 bez cofania chodu i bez lustra całego sprite'a. |
| Skala / ekran | 720×1280, 720×1440, 1280×720 i 1560×720; wszystkie pięć map. Oba skarbce w kadrze, brak przesuwania kamery. Na komórce około 64 px odróżnić walk/carry, windup/contact/recovery i hit/death. PŻ/loot/team ring nie zasłaniają twarzy. |
| Obrót / tło | 20 obrotów podczas każdego głównego stanu i pickup/deposit, otwieranie arsenału oraz powrót z tła. Bez resetu klipu, powtórnego kontaktu/przelewu i zmiany rozmiaru zwłok. Pauza podglądu zatrzymuje wyłącznie podgląd. |
| Pamięć | Potwierdzić 608 klatek, osiem PNG, maksimum 1536×1024, 38 MiB RGBA8 bez mipmap. Zanotować realną pamięć tekstur i PSS przed/po załadowaniu, szczyt podczas ładowania oraz po 10 otwarciach/zamknięciach podglądu. Brak stałego wzrostu; zmierzony narzut pakietu ma zgadzać się z formatem importu, bez kopii per aktor. |
| Słabszy Android | Docelowo Huawei RNE-L21 / Android 8, jeśli nadal używany, profil oszczędny/GL Compatibility, faktyczna rozdzielczość i wariant ARM zapisane w raporcie. 30 s rozgrzewki, 3 × 60 s przy 30 aktorach, następnie stress 60 aktorów z jednoczesną śmiercią i oddaniem; osobno pion i poziom. Cel odbioru dla 30: stabilne 30 FPS, p95 odstępu renderowanych klatek ≤33,4 ms, p99 ≤50 ms, bez narastającego przycięcia. 60 aktorów to diagnoza limitu, nie obietnica. Porównać z tym samym scenariuszem bazowym. |

Zapisywać model/GPU, Android, temperaturę/stan termiczny, rozdzielczość, profil jakości, liczbę aktorów, medianę/p95/p99 czasu klatki, liczbę klatek >50 ms, pamięć tekstur, PSS procesu i szczyt ładowania. Do analizy użyć próbkowania czasu klatek oraz adb shell dumpsys meminfo dla identyfikatora aplikacji z bieżącego eksportu; sama średnia FPS i rozmiar APK nie wystarczą. Redraw pola bitwy jest dziś limitowany profilem jakości niezależnie od symulacji 20 Hz — pomiar ma odróżniać budżet repaintu od błędów czasowania atlasu. Jeśli bazowa gra nie spełnia progu, pokazać wynik bazowy i narzut v2, nie oznaczać testu jako zaliczony na podstawie desktopu.

## 7. Etapy wykonania i następna rotacja

Najpierw szary model ruchu: attack E/W z antycypacją, kontaktem i gardą, następnie walk/carry/death E/W oraz pickup/deposit. Minimalna próba czterech głównych stanów E/W obejmuje (10+12+12+10)×2 = **88 klatek**, a nie komplet finalny. Zatwierdzić anatomię i chwyt przed dopracowaniem ornamentów. Potem pozostałe sześć kierunków, osiem finalnych PNG i manifest, integracja za fallbackiem oraz testy Androida. Nie instalować szkiców jako gotowego pakietu.

Następny: **003 — gobliny, nacisk na śmierć**, z nowym sposobem utraty równowagi i odmiennym wyposażeniem; nadal wszystkie cztery główne stany. Potem krasnoludy/wynoszenie złota, Pustka/chód. Przed kolejnym zapisem ponownie sprawdzić aktualny indeks, pliki i fingerprinty.
