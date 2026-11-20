# Samouczek interaktywny Vault Wars

Dostęp: **menu główne → Samouczek** albo **Księga gry → Jak grać**. Każdą lekcję można uruchomić osobno; po ukończeniu przycisk „Następna” prowadzi dalej. „Powtórz” zaczyna bieżącą lekcję od początku, „Lekcje” wraca do listy, a Android Back bezpiecznie zamyka trening.

Nie ma odliczania. Wymagany zakup lub wybór jest podświetlony złotą ramką i wskazany strzałką. Inne akcje są blokowane również w logice zakupów, a nie tylko wizualnie. Po wykonaniu wskazanego działania pojawia się następna instrukcja. Teksty są po polsku i angielsku.

## Lekcje i przykłady

| Lekcja | Czego uczy i co pokazuje |
|---|---|
| 1. Podstawy i trzy alejki | Osobne kliknięcie każdej alejki, złoto jako życie, jeden darmowy najeźdźca, kradzież i dopiero późniejsza dostawa. |
| 2. Zwiadowca | Rzeczywisty zakup, nowa cena kolejnego zwiadowcy i samotny najazd po niebronionej trasie. |
| 3. Tragarz | Zakup, PŻ, pojemność, wolniejsza dostawa i zagrożenie ze strony wież. |
| 4. Sabotażysta | Rozbrojenie pierwszej pułapki, zachowanie PŻ oraz obrażenia od następnej warstwy obrony. |
| 5. Obrońca | Zatrzymanie przeciwnika w zwarciu, wymiana ciosów i zużywanie zdrowia obrońcy. |
| 6. Kolce | Trafienie podstawowego zwiadowcy, jego porażka i zużyty ładunek pułapki. |
| 7. Sidła | Zatrzymanie na 2,5 s, dobudowanie wieży i pokaz ich współpracy. |
| 8. Wieża | Ostrzał tragarza, premia obrażeń oraz osobny przykład rozbrojenia wieży przez sabotażystę. |
| 9. Skarbiec | Koszt ulepszenia, wygląd/poziom budynku, rzeczywiste odsetki po ręcznie wywołanym rozliczeniu fali, limit podstawy odsetek i rezerwa. |
| 10. Trening | Zakup każdego z trzech poziomów, rosnące ceny, porównanie dwóch najeźdźców i widoczny limit MAX. |
| 11. Skład i rezerwa | Kolejne role mają własne ceny; wspólny najazd zwiadowcy i tragarza oraz rozłożone w czasie dostawy. |
| 12. Krasnoludy | PŻ, odsetki, zakup obrońcy przed Żelaznym murem, pochłonięty cios i zniknięcie tarczy po fali. |
| 13. Gobliny | Tempo i pojemność, zakup jednostki, aktywacja Szału i szybszy rzeczywisty cios w zwarciu. |
| 14. Elfy | PŻ i pojemność, Księżycowe błogosławieństwo, większa kradzież i konieczność dostarczenia złota do domu. |
| 15. Voidborn | Krok cienia, unik pierwszej pułapki bez jej rozbrojenia i skuteczna druga warstwa obrony. |

Przykłady korzystają z funkcji zakupów i symulatora zwykłej gry. Nie odtwarzamy z góry ustalonej animacji udającej wynik. Zakończenie pokazu zależy od stanu gry: podniesienia/dostarczenia łupu, rozbrojenia, ogłuszenia, obrażeń, ciosu lub porażki jednostki. Pokaz zatrzymuje się po zdarzeniu, a gracz sam wybiera „Dalej”. W czasie pokazu dostępna jest pauza.

## Oddzielenie od normalnej gry

Trening tworzy osobną instancję planszy. Zwykły mecz jest wstrzymany, jego przyciski wyłączone, a złoto, zamówienia, rasa i pozostały czas zachowane. Instancja treningowa nie uruchamia bota ani darmowych fal poza wskazanym przykładem. Jej zegar nie odlicza i nie przyznaje ona EXP, wyników meczu ani odblokowań konta. Lekcje elfów i Voidborn są dostępne wcześniej wyłącznie do nauki.

Po wyjściu najpierw wraca lista lekcji, a po jej zamknięciu poprzedni ekran lub dokładnie ten sam mecz. Trening nie zmienia zasad czasowych normalnej rozgrywki. Przykładowe rozliczenia fali są wywoływane przez kliknięcie i nie dochodzą do fazy presji skarbców.

W pionie instrukcja znajduje się nad planszą, w poziomie obok niej. Podświetlenie śledzi cel po obrocie. Arsenał jest otwierany i przewijany do wymaganego przycisku. Instrukcja ma własne przewijanie dłuższego tekstu. Przykłady odświeżają etykiety z częstotliwością do 5 Hz, a wskaźnik stosuje budżet graficzny wybranego profilu telefonu. Ograniczenie ruchu wyłącza pulsowanie ramki.

## Sprawdzenie

`ci/smoke_guided_tutorial.gd` przechodzi 15 lekcji w obu językach: 148 kroków i 86 rzeczywistych kliknięć w GUI. Sprawdza zdarzenia w symulatorze, brak odliczania przy długim oczekiwaniu, blokowanie niewłaściwych zakupów, odporność na podwójne kliknięcie, pauzę/powtarzanie, brak nagród i odblokowań, Android Back oraz zachowanie i wznowienie prawdziwego meczu. Kontroluje też układ w siedmiu rozmiarach ekranu od 540×960 do poziomego 960×540.

```sh
godot --headless --path . --script res://ci/smoke_guided_tutorial.gd
```

Test jest wymagany w walidacji Godot i przed eksportem APK. Otwarty wcześniej raport balansu dotyczy źródeł z commitu `a603e98e51a3cf6c49ba140aa152676362fcf65f`; dodane szkolenie jest oddzielone od normalnej symulacji. Pełny turniej CI nadal sprawdza aktualną wersję gry.
