extends RefCounted
## Offline translations; stable source strings and formatting arguments stay separate.
## Language changes only presentation and never reset a match.
static var language := "pl"
const LANGUAGES := ["pl", "en"]
const MESSAGES := {
	"Odsetki +%d. Presja skarbców po tej fali: -%d dla obu stron.": ["Odsetki +%d. Presja skarbców po tej fali: -%d dla obu stron.", "Interest +%d. Vault pressure after this wave: -%d for both sides."],
	" • presja %d": [" • presja %d", " • pressure %d"],
	"⚔ TRENING %d  •  %d": ["⚔ TRENING %d  •  %d", "⚔ TRAINING %d  •  %d"],
	"KOPIA POSTĘPU": ["KOPIA POSTĘPU", "PROGRESS BACKUP"],
	"Zachowaj kod przed reinstalacją gry. Przywraca EXP i odblokowane rasy na tym lub innym telefonie.": ["Zachowaj kod przed reinstalacją gry. Przywraca EXP i odblokowane rasy na tym lub innym telefonie.", "Save this code before reinstalling. It restores XP and unlocked factions on this or another phone."],
	"Skopiuj kod": ["Skopiuj kod", "Copy code"],
	"Wklej kod postępu": ["Wklej kod postępu", "Paste progress code"],
	"Przywróć postęp": ["Przywróć postęp", "Restore progress"],
	"Postęp przywrócony. Poziom %d.": ["Postęp przywrócony. Poziom %d.", "Progress restored. Level %d."],
	"Masz już taki lub wyższy postęp.": ["Masz już taki lub wyższy postęp.", "Your progress is already at this point or higher."],
	"Nieprawidłowy kod postępu.": ["Nieprawidłowy kod postępu.", "Invalid progress code."],
	"Nie udało się zapisać postępu.": ["Nie udało się zapisać postępu.", "Progress could not be saved."],
	"POZIOM KONTA %d / 20": ["POZIOM KONTA %d / 20", "ACCOUNT LEVEL %d / 20"],
	"Elfy: poziom 5 • Pustka: poziom 10": ["Elfy: poziom 5 • Pustka: poziom 10", "Elves: level 5 • Voidborn: level 10"],
	"Następne odblokowanie: Pustka — poziom 10": ["Następne odblokowanie: Pustka — poziom 10", "Next unlock: Voidborn — level 10"],
	"Wszystkie rasy odblokowane": ["Wszystkie rasy odblokowane", "All factions unlocked"],
	"POZ. %d": ["POZ. %d", "LV. %d"],
	"Odblokowanie na poziomie %d": ["Odblokowanie na poziomie %d", "Unlocks at level %d"],
	"Odblokowanie: poziom %d • Twój poziom: %d": ["Odblokowanie: poziom %d • Twój poziom: %d", "Unlock: level %d • Your level: %d"],
	"ZABLOKOWANE • POZIOM %d": ["ZABLOKOWANE • POZIOM %d", "LOCKED • LEVEL %d"],
	"+%d EXP za mecz": ["+%d EXP za mecz", "+%d XP for the match"],
	"AWANS NA POZIOM %d": ["AWANS NA POZIOM %d", "LEVEL UP: %d"],
	"Maksymalny poziom konta": ["Maksymalny poziom konta", "Maximum account level"],
	"ODBLOKOWANO: %s": ["ODBLOKOWANO: %s", "UNLOCKED: %s"],
	"EXP po ukończeniu rozgrywki": ["EXP za zakończony mecz po rozpoczęciu bitwy", "XP for a completed match after battle starts"],
	"Nie udało się zapisać EXP. Postęp konta zachowany.": ["Nie udało się zapisać nagrody. Poprzedni postęp zachowany.", "Reward could not be saved. Previous progress was preserved."],
	"Nie można odczytać postępu. Zapis konta nie zostanie nadpisany.": ["Nie można odczytać postępu. Zapis konta nie zostanie nadpisany.", "Progress could not be loaded. Your saved account will not be overwritten."],
	"POZIOM KONTA I RASY": ["POZIOM KONTA I RASY", "ACCOUNT LEVEL AND FACTIONS"],
	"Konto rozwijasz do poziomu 20. Krasnoludy i gobliny są dostępne od początku, elfy od poziomu 5, a Pustka od 10. Za ukończony mecz otrzymasz 50 EXP za zwycięstwo lub 25 za porażkę, plus 20 za rozegraną falę (maksymalnie 20 fal). Wymagane jest rozpoczęcie bitwy. Wyjście z meczu nie daje EXP. Poziom nie zwiększa statystyk jednostek. Postęp zapisuje się na tym telefonie.": ["Konto rozwijasz do poziomu 20. Krasnoludy i gobliny są dostępne od początku, elfy od poziomu 5, a Pustka od 10. Za ukończony mecz otrzymasz 50 EXP za zwycięstwo lub 25 za porażkę, plus 20 za rozegraną falę (maksymalnie 20 fal). Wymagane jest rozpoczęcie bitwy. Wyjście z meczu nie daje EXP. Poziom nie zwiększa statystyk jednostek. Postęp zapisuje się na tym telefonie.", "Reach account level 20. Dwarves and Goblins are available from the start, Elves unlock at level 5, and Voidborn at 10. A completed match grants 50 XP for a win or 25 for a loss, plus 20 per played wave (up to 20 waves). Battle must have started. Leaving a match grants no XP. Account level does not increase unit stats. Progress is saved on this phone."],
	"WYBIERZ PLANSZĘ": ["WYBIERZ PLANSZĘ", "CHOOSE BATTLEFIELD"],
	"Standard": ["Standard", "Standard"],
	"Twierdze krasnoludów": ["Twierdze krasnoludów", "Dwarven vaults"],
	"Goblińskie ostępy": ["Goblińskie ostępy", "Goblin strongholds"],
	"Księżycowe ogrody": ["Księżycowe ogrody", "Elven moon gardens"],
	"Szczelina Pustki": ["Szczelina Pustki", "Void rift"],
	"Sceneria nie zmienia zasad ani premii rasy.": ["Sceneria nie zmienia zasad ani premii rasy.", "Scenery does not change the rules or faction bonuses."],
	"Krasnoludy mają +25% PŻ najeźdźców i 24% odsetek. Odsetki naliczane są od maksymalnie 1000 złota.": [
		"Krasnoludy mają +25% PŻ najeźdźców i 24% odsetek. Odsetki naliczane są od maksymalnie 1000 złota.",
		"Dwarves have +25% raider HP and 24% interest. Only the first 1000 gold earns interest."
	],
	"Gobliny mają +20% tempa i +5% pojemności najeźdźców oraz 18% odsetek. Sidła i obrońcy zatrzymują ich szybkie wypady.": [
		"Gobliny mają +20% tempa i +5% pojemności najeźdźców oraz 18% odsetek. Sidła i obrońcy zatrzymują ich szybkie wypady.",
		"Goblin raiders have +20% speed, +5% capacity and 18% interest. Snares and defenders stop their fast raids."
	],
	"Elfy mają +10% PŻ i +5% pojemności najeźdźców oraz 18% odsetek. Premia do łupu jest procentowa, także dla darmowej fali.": [
		"Elfy mają +10% PŻ i +5% pojemności najeźdźców oraz 18% odsetek. Premia do łupu jest procentowa, także dla darmowej fali.",
		"Elven raiders have +10% HP and +5% capacity, with 18% interest. The loot bonus is proportional, including free raiders."
	],
	"Voidborn mają +5% tempa i +8% pojemności najeźdźców oraz 18% odsetek. Mają mniej PŻ niż krasnoludy i elfy.": [
		"Voidborn mają +5% tempa i +8% pojemności najeźdźców oraz 18% odsetek. Mają mniej PŻ niż krasnoludy i elfy.",
		"Voidborn raiders have +5% speed and +8% capacity, with 18% interest. They have less HP than dwarves and elves."
	],
	"Zostaw część złota w skarbcu. Wyższe odsetki działają od oszczędności pozostałych po zakupach.": [
		"Zostaw część złota w skarbcu. Wyższe odsetki działają od oszczędności pozostałych po zakupach.",
		"Keep some gold in your vault. Higher interest applies to savings left after purchases."
	],
	"Wybierz słabiej bronioną alejkę i łącz szybkie wypady z większym transportem złota.": [
		"Wybierz słabiej bronioną alejkę i łącz szybkie wypady z większym transportem złota.",
		"Pick a weakly defended lane and combine fast raids with larger gold shipments."
	],
	"Chroń powracających tragarzy. Większa pojemność daje zysk dopiero po bezpiecznym powrocie.": [
		"Chroń powracających tragarzy. Większa pojemność daje zysk dopiero po bezpiecznym powrocie.",
		"Protect returning carriers. Extra capacity pays off only if they make it home safely."
	],
	"Przed trudnym wypadem aktywuj Shadow Step: najeźdźca ominie pierwszy napotkany efekt pułapki.": [
		"Przed trudnym wypadem aktywuj Krok cienia: najeźdźca ominie pierwszy napotkany efekt pułapki.",
		"Activate Shadow Step before a dangerous raid: each raider bypasses the first trap effect it encounters."
	],
	"Iron Wall daje obecnym obrońcom tarczę 60 PŻ na jedną falę. Tarcza pochłania obrażenia, nie leczy i znika po fali. Nie kumuluje się.": [
		"Żelazny mur daje obecnym obrońcom tarczę 60 PŻ na jedną falę. Tarcza pochłania obrażenia, nie leczy i znika po fali. Nie kumuluje się.",
		"Iron Wall gives existing defenders a 60 HP shield for one wave. It absorbs damage without healing and expires after the wave. It cannot stack."
	],
	"Goblin Frenzy daje +25% tempa na jedną falę. W zwarciu najeźdźcy uderzają co 0,45 s zamiast co 0,65 s. Sidła i kolce nadal ich zatrzymują.": [
		"Gobliński szał daje +25% tempa na jedną falę. W zwarciu najeźdźcy uderzają co 0,45 s zamiast co 0,65 s. Sidła i kolce nadal ich zatrzymują.",
		"Goblin Frenzy grants +25% speed for one wave. Raiders strike every 0.45 s instead of 0.65 s in melee. Snares and spikes still stop them."
	],
	"Moon Blessing zwiększa pojemność najeźdźców o 35% na jedną falę. Zysk wymaga bezpiecznego powrotu z łupem.": [
		"Księżycowe błogosławieństwo zwiększa pojemność najeźdźców o 35% na jedną falę. Zysk wymaga bezpiecznego powrotu z łupem.",
		"Moon Blessing increases raider capacity by 35% for one wave. Extra loot must be brought home safely."
	],
	"Shadow Step daje +12% tempa na jedną falę i unik jednego uruchomienia pułapki lub strzału wieży na jednostkę. Kolejne pułapki i strzały działają normalnie.": [
		"Krok cienia daje +12% tempa na jedną falę i unik jednego uruchomienia pułapki lub strzału wieży na jednostkę. Kolejne pułapki i strzały działają normalnie.",
		"Shadow Step grants +12% speed for one wave and evades one trap activation or tower shot per raider. Later traps and shots still work."
	],
	"Najeźdźcy dołączają bez opłaty na każdej alejce po rozpoczęciu ataku. Zbierają złoto i wracają do twojego skarbca tak samo jak płatne jednostki.": [
		"Najeźdźcy dołączają bez opłaty na każdej alejce po rozpoczęciu ataku. Zbierają złoto i wracają do twojego skarbca tak samo jak płatne jednostki.",
		"Free raiders join every lane when the attack begins. They collect gold and return to your vault just like hired units."
	],
	"Szybki najeźdźca do wypadów na skarbiec. Kradnie złoto, odwraca się i wraca tą samą alejką. Zysk trafia do ciebie po powrocie.": [
		"Szybki najeźdźca do wypadów na skarbiec. Kradnie złoto, odwraca się i wraca tą samą alejką. Zysk trafia do ciebie po powrocie.",
		"A fast raider for vault runs. It steals gold, turns around and returns along the same lane. You receive the loot when it gets home."
	],
	"Powolny i wytrzymały najeźdźca z dużą pojemnością na złoto. Zadaje obrońcom bazowo 22 obrażenia na sekundę, przebijając blokadę. Wymaga wsparcia przeciw wieżom i sidłom.": [
		"Powolny i wytrzymały najeźdźca z dużą pojemnością na złoto. Zadaje obrońcom bazowo 22 obrażenia na sekundę, przebijając blokadę. Wymaga wsparcia przeciw wieżom i sidłom.",
		"A slow, tough raider with large gold capacity. Deals a base 22 damage per second to defenders to break a blockade. Needs support against towers and snares."
	],
	"Rozbraja jedną napotkaną pułapkę, także wieżyczkę. Kolejna linia obrony działa normalnie. Bez pułapek zwiadowca jest tańszym wyborem.": [
		"Rozbraja jedną napotkaną pułapkę, także wieżyczkę. Kolejna linia obrony działa normalnie. Bez pułapek zwiadowca jest tańszym wyborem.",
		"Disarms one encountered trap, including a turret. The next defensive layer works normally. Against an open lane, a runner is cheaper."
	],
	"Wesprzyj falę zakupami na wybranej alejce. Darmowe jednostki też korzystają z premii rasy i treningu.": [
		"Wesprzyj falę zakupami na wybranej alejce. Darmowe jednostki też korzystają z premii rasy i treningu.",
		"Reinforce the wave with purchases on your chosen lane. Free units also benefit from faction and training bonuses."
	],
	"Użyj na słabiej bronionej alejce. Mniej PŻ oznacza duże ryzyko wobec kolców.": [
		"Użyj na słabiej bronionej alejce. Mniej PŻ oznacza duże ryzyko wobec kolców.",
		"Use on weakly defended lanes. Lower HP makes spikes especially dangerous."
	],
	"Wyślij obok szybszych jednostek. Chroń drogę powrotną, aby nie stracić dużego łupu.": [
		"Wyślij obok szybszych jednostek. Chroń drogę powrotną, aby nie stracić dużego łupu.",
		"Send alongside faster units. Protect the return route to keep your valuable loot safe."
	],
	"Wyślij przed tragarzem przeciw pułapkom i wieżom. Przeciwnik może osłonić wieżę obrońcą lub tańszą pułapką.": [
		"Wyślij przed tragarzem przeciw pułapkom i wieżom. Przeciwnik może osłonić wieżę obrońcą lub tańszą pułapką.",
		"Buy before a carrier if the route has spikes or snares. Overwhelm turrets with a larger group."
	],
	"Statystyki bez treningu i zdolności. Kolejna jednostka tego samego typu w tej fali kosztuje o 20% ceny bazowej więcej, niezależnie od alejki. Maks. 6 płatnych jednostek, 4 na alejce.": [
		"Statystyki bez treningu i zdolności. Kolejna jednostka tego samego typu w tej fali kosztuje o 20% ceny bazowej więcej, niezależnie od alejki. Maks. 6 płatnych jednostek, 4 na alejce.",
		"Stats without training or abilities. Each additional unit of the same type this wave costs another 20% of base price, across all lanes. Max. 6 hired units, 4 per lane."
	],
	"Po 2, 3, 4, 5 i 7 jednostek na alejce w falach 1–5; od fali 5 po 7.": [
		"Po 2, 3, 4, 5 i 7 jednostek na alejce w falach 1–5; od fali 5 po 7.",
		"2, 3, 4, 5 and 7 units per lane in waves 1–5; 7 per lane from wave 5 onward."
	],
	"Zatrzymuje najeźdźców w walce i zadaje 26 obrażeń co 0,9 s. Tragarz zadaje mu 22 obrażenia na sekundę, inni płatni najeźdźcy 14, darmowi 10. Przetrwały obrońca zostaje na kolejne fale.": [
		"Zatrzymuje najeźdźców w walce i zadaje 26 obrażeń co 0,9 s. Tragarz zadaje mu 22 obrażenia na sekundę, inni płatni najeźdźcy 14, darmowi 10. Przetrwały obrońca zostaje na kolejne fale.",
		"Blocks raiders in combat and deals 26 damage every 0.9 s. Carriers retaliate with 22 damage per second, other hired raiders with 14 and free raiders with 10. Surviving defenders persist across waves."
	],
	"Rozstaw przed atakiem. Jako krasnolud najpierw kup obrońców, a potem aktywuj Iron Wall.": [
		"Rozstaw przed atakiem. Jako krasnolud najpierw kup obrońców, a potem aktywuj Żelazny mur.",
		"Deploy before the attack. As a dwarf, hire defenders first, then activate Iron Wall."
	],
	"Maks. 3 twoich obrońców na alejce. Każdy zakup uszczupla skarbiec.": [
		"Maks. 3 twoich obrońców na alejce. Każdy zakup uszczupla skarbiec.",
		"Max. 3 friendly defenders per lane. Every purchase reduces your vault's gold."
	],
	"Zadają 50 obrażeń przy uruchomieniu, mają 3 ładunki. Eliminują podstawowego zwiadowcę jednym trafieniem; tragarze wytrzymują więcej. Każda jednostka uruchamia je tylko raz.": [
		"Zadają 50 obrażeń przy uruchomieniu, mają 3 ładunki. Eliminują podstawowego zwiadowcę jednym trafieniem; tragarze wytrzymują więcej. Każda jednostka uruchamia je tylko raz.",
		"Deal 50 damage per activation with 3 charges. Kill a basic runner in one hit; carriers withstand more. Each raider triggers each trap only once."
	],
	"Zadają 25 obrażeń i zatrzymują najeźdźcę na 2,5 s. Mają 2 ładunki. To zatrzymanie, a nie trwałe obniżenie szybkości.": [
		"Zadają 25 obrażeń i zatrzymują najeźdźcę na 2,5 s. Mają 2 ładunki. To zatrzymanie, a nie trwałe obniżenie szybkości.",
		"Deal 25 damage and stop a raider for 2.5 s. Have 2 charges. This is a temporary stop, not a permanent speed reduction."
	],
	"Strzela co 0,6 s: 16 obrażeń, przeciw tragarzom 32. Priorytetem są tragarze, potem najbliższy skarbca wróg. Sabotażysta może ją rozbroić: osłoń ją inną obroną.": [
		"Strzela co 0,6 s: 16 obrażeń, przeciw tragarzom 32. Priorytetem są tragarze, potem najbliższy skarbca wróg. Sabotażysta może ją rozbroić: osłoń ją inną obroną.",
		"Shoots every 0.6 s: 16 damage, 32 against carriers. Prioritizes carriers, then the enemy nearest the vault. A saboteur can disarm it; protect it with another defense."
	],
	"Broń zagrożonej alejki i łącz z obrońcą. Uważaj na sabotażystów.": [
		"Broń zagrożonej alejki i łącz z obrońcą. Uważaj na sabotażystów.",
		"Protect threatened lanes and combine with a defender. Watch out for saboteurs."
	],
	"Połącz z sidłami: zatrzymany przeciwnik dłużej pozostaje pod ostrzałem.": [
		"Połącz z sidłami: zatrzymany przeciwnik dłużej pozostaje pod ostrzałem.",
		"Combine with a snare: a stopped enemy stays under fire longer."
	],
	"Buduj podczas przygotowań. Wybrana alejka dotyczy każdego nowego zakupu.": [
		"Buduj podczas przygotowań. Wybrana alejka dotyczy każdego nowego zakupu.",
		"Build during preparation. Every new purchase is placed on the selected lane."
	],
	"Złoto jest jednocześnie twoim życiem i walutą. Każdy poziom skarbca dodaje 4 punkty procentowe do odsetek po fali. Poziomy 1–5 mają osobne budynki w grze.": [
		"Złoto jest jednocześnie twoim życiem i walutą. Każdy poziom skarbca dodaje 4 punkty procentowe do odsetek po fali. Poziomy 1–5 mają osobne budynki w grze.",
		"Gold is both your life and your currency. Each vault level adds 4 percentage points of interest after each wave. Levels 1–5 have distinct buildings in battle."
	],
	"Odsetki liczą się od maksymalnie 1000 pozostałego złota; minimum 20. Nadwyżka nie zwiększa wypłaty. Od fali 6 oba skarbce tracą złoto po fali: 75, 150, 225 i dalej +75.": [
		"Odsetki liczą się od maksymalnie 1000 pozostałego złota; minimum 20. Nadwyżka nie zwiększa wypłaty. Od fali 6 oba skarbce tracą złoto po fali: 75, 150, 225 i dalej +75.",
		"Only the first 1000 remaining gold earns interest; minimum 20. Excess savings do not increase income. From wave 6 both vaults lose 75, 150, 225 gold and another 75 each subsequent wave."
	],
	"Ulepszenie kosztuje złoto z twojego skarbca. Zero złota kończy mecz od razu.": [
		"Ulepszenie kosztuje złoto z twojego skarbca. Zero złota kończy mecz od razu.",
		"Upgrades cost gold from your vault. Reaching zero gold ends the match immediately."
	],
	"Każdy poziom dodaje najeźdźcom 12% bazowych PŻ i 8% bazowego tempa. Premie treningu mnożą statystyki po uwzględnieniu rasy i zdolności. Działa w kolejnych falach.": [
		"Każdy poziom dodaje najeźdźcom 12% bazowych PŻ i 8% bazowego tempa. Premie treningu mnożą statystyki po uwzględnieniu rasy i zdolności. Działa w kolejnych falach.",
		"Each level adds 12% base HP and 8% base speed to raiders. Training multiplies stats after faction and ability bonuses. Applies to later waves."
	],
	"Kup trening, gdy planujesz wysyłać więcej jednostek. Nie zwiększa pojemności łupu ani siły obrońców.": [
		"Kup trening, gdy planujesz wysyłać więcej jednostek. Nie zwiększa pojemności łupu ani siły obrońców.",
		"Buy training when planning to send more units. It does not increase loot capacity or defender strength."
	],
	"Maksymalnie +36% PŻ i +24% tempa. Zakupy tylko w przygotowaniach.": [
		"Maksymalnie +36% PŻ i +24% tempa. Zakupy tylko w przygotowaniach.",
		"Maximum +36% HP and +24% speed. Purchases are available only during preparation."
	],
	"Aktywuj w przygotowaniach przed rozpoczęciem ataku.": [
		"Aktywuj w przygotowaniach przed rozpoczęciem ataku.",
		"Activate during preparation before starting the attack."
	],
	"Najpierw zatrudnij obrońców, potem wzmocnij ich zdolnością.": [
		"Najpierw zatrudnij obrońców, potem wzmocnij ich zdolnością.",
		"Hire defenders first, then strengthen them with this ability."
	],
	"Gotowość odnawia się przy kolejnej fali. Nie aktywuje się w czasie ataku.": [
		"Gotowość odnawia się przy kolejnej fali. Nie aktywuje się w czasie ataku.",
		"Readiness resets with the next wave. Cannot activate during an attack."
	],
	"Zaczynasz z 1000 złota. Zakupy oraz kradzieże zmniejszają zawartość skarbca. Gdy skarbiec jednej strony osiąga zero, mecz kończy się natychmiast. Skradzione monety zwiększają twój skarbiec dopiero po powrocie najeźdźcy.": [
		"Zaczynasz z 1000 złota. Zakupy oraz kradzieże zmniejszają zawartość skarbca. Gdy skarbiec jednej strony osiąga zero, mecz kończy się natychmiast. Skradzione monety zwiększają twój skarbiec dopiero po powrocie najeźdźcy.",
		"You start with 1000 gold. Purchases and thefts reduce the vault's contents. When either vault reaches zero, the match ends immediately. Stolen coins reach your vault only when a raider returns."
	],
	"Zachowuj rezerwę. Śmierć złodzieja z łupem zwraca monety obrabowanej stronie.": [
		"Zachowuj rezerwę. Śmierć złodzieja z łupem zwraca monety obrabowanej stronie.",
		"Keep a reserve. If a thief carrying loot dies, the coins return to the side they were stolen from."
	],
	"Dotknij górnej, środkowej lub dolnej alejki. Płatni najeźdźcy, obrońcy i pułapki trafiają na aktualnie wybraną trasę. Darmowa fala rusza wszystkimi trzema.": [
		"Dotknij górnej, środkowej lub dolnej alejki. Płatni najeźdźcy, obrońcy i pułapki trafiają na aktualnie wybraną trasę. Darmowa fala rusza wszystkimi trzema.",
		"Tap the top, middle or bottom lane. Hired raiders, defenders and traps use the selected route. The free wave travels along all three lanes."
	],
	"Obserwuj wroga i wzmacniaj zagrożoną trasę. Pustej alejki nie osłania obrońca z sąsiedniej.": [
		"Obserwuj wroga i wzmacniaj zagrożoną trasę. Pustej alejki nie osłania obrońca z sąsiedniej.",
		"Watch the enemy and reinforce threatened routes. A defender on another lane cannot protect an empty one."
	],
	"Masz 30 sekund na zakupy i do 60 sekund ataku. Po walce otrzymujesz odsetki od maks. 1000 złota. Od fali 6 oba skarbce tracą 75 złota po fali, potem o 75 więcej co falę. Najazdy pozwalają przełamać oblężenie.": [
		"Masz 30 sekund na zakupy i do 60 sekund ataku. Po walce otrzymujesz odsetki od maks. 1000 złota. Od fali 6 oba skarbce tracą 75 złota po fali, potem o 75 więcej co falę. Najazdy pozwalają przełamać oblężenie.",
		"You have 30 seconds to shop and up to 60 seconds to attack. Interest applies to at most 1000 gold. From wave 6 both vaults lose 75 gold after combat, increasing by 75 each wave. Raids break the siege."
	],
	"Niedostarczony łup po końcu czasu wraca do obrabowanej strony. Walka trwa do opróżnienia skarbca.": [
		"Niedostarczony łup po końcu czasu wraca do obrabowanej strony. Walka trwa do opróżnienia skarbca.",
		"Undelivered loot returns to the side it was stolen from when time runs out. Battle continues until a vault is empty."
	],
	"Zaczynasz z 1000 złota. Każdy zakup zabiera monety ze skarbca. Gdy twój skarbiec osiągnie zero, przegrywasz od razu. Zachowuj rezerwę.": [
		"Zaczynasz z 1000 złota. Każdy zakup zabiera monety ze skarbca. Gdy twój skarbiec osiągnie zero, przegrywasz od razu. Zachowuj rezerwę.",
		"You start with 1000 gold. Every purchase takes coins from your vault. If your vault reaches zero, you lose immediately. Keep a reserve."
	],
	"Wybierz alejkę. Ceny bazowe: zwiadowca 75, tragarz 140, sabotażysta 110. Kolejny najeźdźca tego samego typu w tej fali kosztuje o 20% ceny bazowej więcej. Łącz różne role i obronę.": [
		"Wybierz alejkę. Ceny bazowe: zwiadowca 75, tragarz 140, sabotażysta 110. Kolejny najeźdźca tego samego typu w tej fali kosztuje o 20% ceny bazowej więcej. Łącz różne role i obronę.",
		"Choose a lane. Base prices: runner 75, carrier 140, saboteur 110. Each additional raider of the same type this wave costs another 20% of base price. Combine roles and defenses."
	],
	"Darmowa fala rusza z kupionymi jednostkami. Najeźdźca musi ukraść złoto i wrócić do twojego skarbca. Łup niedostarczony przed końcem fali wraca do obrabowanej strony.": [
		"Darmowa fala rusza z kupionymi jednostkami. Najeźdźca musi ukraść złoto i wrócić do twojego skarbca. Łup niedostarczony przed końcem fali wraca do obrabowanej strony.",
		"The free wave joins your hired units. A raider must steal gold and bring it back to your vault. Loot not delivered before the wave ends returns to the side it was stolen from."
	],
	"Skarbiec dodaje po 4 punkty procentowe odsetek na poziom. Tylko pierwsze 1000 złota zarabia odsetki; minimum wypłaty to 20. Od fali 6 oba skarbce tracą po walce 75 złota, potem o 75 więcej co falę.": [
		"Skarbiec dodaje po 4 punkty procentowe odsetek na poziom. Tylko pierwsze 1000 złota zarabia odsetki; minimum wypłaty to 20. Od fali 6 oba skarbce tracą po walce 75 złota, potem o 75 więcej co falę.",
		"Vault levels add 4 percentage points of interest each. Only the first 1000 gold earns interest; minimum payout 20. From wave 6 both vaults lose 75 gold after combat, increasing by 75 each wave."
	],
	"Kolce zadają obrażenia. Sidła ranią i zatrzymują przeciwnika na 2,5 s. Wieżyczki strzelają co 0,6 s. Obrońca pilnuje wybranej alejki.": [
		"Kolce zadają obrażenia. Sidła ranią i zatrzymują przeciwnika na 2,5 s. Wieżyczki strzelają co 0,6 s. Obrońca pilnuje wybranej alejki.",
		"Spikes deal damage. Snares hurt and stop enemies for 2.5 s. Turrets fire every 0.6 s. Defenders guard the selected lane."
	],
	"Krasnoludy: oszczędzanie i PŻ. Gobliny: szybkość. Elfy: PŻ i łup. Voidborn: szybkość i łup. Zdolność kosztuje 120 złota, raz na falę w przygotowaniach. Iron Wall wzmacnia już zatrudnionych obrońców.": [
		"Krasnoludy: oszczędzanie i PŻ. Gobliny: szybkość. Elfy: PŻ i łup. Voidborn: szybkość i łup. Zdolność kosztuje 120 złota, raz na falę w przygotowaniach. Żelazny mur wzmacnia już zatrudnionych obrońców.",
		"Dwarves: savings and HP. Goblins: speed. Elves: HP and loot. Voidborn: speed and loot. Abilities cost 120 gold, once per wave during preparation. Iron Wall strengthens defenders already hired."
	],
	"Opróżnij skarbiec przeciwnika. Każda wydana moneta zmniejsza też twoje życie. Mecz trwa do wyzerowania skarbca; nie ma limitu pięciu fal.": [
		"Opróżnij skarbiec przeciwnika. Każda wydana moneta zmniejsza też twoje życie. Mecz trwa do wyzerowania skarbca; nie ma limitu pięciu fal.",
		"Empty the enemy vault. Every coin you spend also reduces your life. The match continues until a vault reaches zero; there is no five-wave limit."
	],
	"DWARVES": [
		"KRASNOLUDY",
		"DWARVES"
	],
	"GOBLINS": [
		"GOBLINY",
		"GOBLINS"
	],
	"ELVES": [
		"ELFY",
		"ELVES"
	],
	"VOIDBORN": [
		"VOIDBORN",
		"VOIDBORN"
	],
	"IRON WALL": [
		"ŻELAZNY MUR",
		"IRON WALL"
	],
	"GOBLIN FRENZY": [
		"GOBLIŃSKI SZAŁ",
		"GOBLIN FRENZY"
	],
	"MOON BLESSING": [
		"KSIĘŻYCOWE BŁOGOSŁAWIEŃSTWO",
		"MOON BLESSING"
	],
	"SHADOW STEP": [
		"KROK CIENIA",
		"SHADOW STEP"
	],
	"Build your army with coins. Protect your vault!": [
		"Zbuduj armię. Chroń swój skarbiec!",
		"Build your army with coins. Protect your vault!"
	],
	"Playing as %s": [
		"Twoja rasa: %s",
		"Playing as %s"
	],
	"Selected lane %d": [
		"Wybrano alejkę %d",
		"Selected lane %d"
	],
	"%s ACTIVATED": [
		"AKTYWOWANO: %s",
		"%s ACTIVATED"
	],
	"BANK LEVEL %d! The vault is upgraded; +4%% interest per wave.": [
		"SKARBIEC POZIOM %d! +4%% odsetek po fali.",
		"BANK LEVEL %d! The vault is upgraded; +4%% interest per wave."
	],
	"Raid training %d/3: faster, stronger thieves.": [
		"Trening %d/3: szybsi i silniejsi złodzieje.",
		"Raid training %d/3: faster, stronger thieves."
	],
	"Need 130 vault gold; max 3 defenders per lane.": [
		"Potrzebujesz 130 złota. Limit: 3 obrońców na alejce.",
		"Need 130 vault gold; max 3 defenders per lane."
	],
	"Defender assigned to lane %d": [
		"Obrońca strzeże alejki %d",
		"Defender assigned to lane %d"
	],
	"Not enough gold or unit limit reached.": [
		"Za mało złota lub osiągnięto limit jednostek.",
		"Not enough gold or unit limit reached."
	],
	"Thief queued on lane %d": [
		"Złodziej czeka na alejce %d",
		"Thief queued on lane %d"
	],
	"Not enough gold or trap limit reached.": [
		"Za mało złota lub osiągnięto limit pułapek.",
		"Not enough gold or trap limit reached."
	],
	"Trap built on lane %d": [
		"Pułapka na alejce %d",
		"Trap built on lane %d"
	],
	"Attack phase! Steal gold and return home.": [
		"Atak! Ukradnij złoto i wróć do bazy.",
		"Attack phase! Steal gold and return home."
	],
	"DRAW! BOTH VAULTS ARE EMPTY": [
		"REMIS! OBA SKARBCE SĄ PUSTE",
		"DRAW! BOTH VAULTS ARE EMPTY"
	],
	"VICTORY! ENEMY VAULT DESTROYED": [
		"ZWYCIĘSTWO! SKARBIEC WROGA JEST PUSTY",
		"VICTORY! ENEMY VAULT DESTROYED"
	],
	"DEFEAT! YOUR VAULT IS EMPTY": [
		"PORAŻKA! TWÓJ SKARBIEC JEST PUSTY",
		"DEFEAT! YOUR VAULT IS EMPTY"
	],
	"LEAVE THE BATTLE?": [
		"OPUŚCIĆ BITWĘ?",
		"LEAVE THE BATTLE?"
	],
	"Current match progress will be lost.": [
		"Postęp tej bitwy zostanie utracony.",
		"Current match progress will be lost."
	],
	"CONTINUE BATTLE": [
		"KONTYNUUJ BITWĘ",
		"CONTINUE BATTLE"
	],
	"RETURN TO MAIN MENU": [
		"WRÓĆ DO MENU",
		"RETURN TO MAIN MENU"
	],
	"INTEREST +%d GOLD! Protect savings or invest in your army.": [
		"ODSETKI +%d ZŁOTA! Zachowaj rezerwę lub wzmocnij armię.",
		"INTEREST +%d GOLD! Protect savings or invest in your army."
	],
	"RACE: %s": [
		"RASA: %s",
		"RACE: %s"
	],
	"LANE %d": [
		"ALEJKA %d",
		"LANE %d"
	],
	"◆ LANE %d  •  %s  •  UNITS %d  •  TRAPS %d": [
		"◆ ALEJKA %d  •  %s  •  JEDNOSTKI %d  •  PUŁAPKI %d",
		"◆ LANE %d  •  %s  •  UNITS %d  •  TRAPS %d"
	],
	"✦ %s  •  120 GOLD": [
		"✦ %s  •  120 ZŁOTA",
		"✦ %s  •  120 GOLD"
	],
	"✓ %s ACTIVE": [
		"✓ %s • AKTYWNA",
		"✓ %s ACTIVE"
	],
	"🏛 BANK LV%d  •  %d": [
		"🏛 SKARBIEC POZ.%d  •  %d",
		"🏛 BANK LV%d  •  %d"
	],
	"🏛 BANK LV5 • MAX": [
		"🏛 SKARBIEC POZ.5 • MAKS.",
		"🏛 BANK LV5 • MAX"
	],
	"⚔ RAID LV%d  •  120": [
		"⚔ TRENING POZ.%d  •  120",
		"⚔ RAID LV%d  •  120"
	],
	"⚔ RAID MAX": [
		"⚔ TRENING • MAKS.",
		"⚔ RAID MAX"
	],
	"RUNNER": [
		"ZWIADOWCA",
		"RUNNER"
	],
	"CARRIER": [
		"TRAGARZ",
		"CARRIER"
	],
	"SABOTEUR": [
		"SABOTAŻYSTA",
		"SABOTEUR"
	],
	"SPIKES": [
		"KOLCE",
		"SPIKES"
	],
	"SNARE": [
		"SIDŁA",
		"SNARE"
	],
	"TURRET": [
		"WIEŻYCZKA",
		"TURRET"
	],
	"DEFENDER": [
		"OBROŃCA",
		"DEFENDER"
	],
	"ABILITY": [
		"ZDOLNOŚĆ",
		"ABILITY"
	],
	"VICTORY": [
		"ZWYCIĘSTWO",
		"VICTORY"
	],
	"DRAW": [
		"REMIS",
		"DRAW"
	],
	"DEFEAT": [
		"PORAŻKA",
		"DEFEAT"
	],
	"THE ENEMY VAULT HAS FALLEN": [
		"SKARBIEC WROGA ZOSTAŁ OPRÓŻNIONY",
		"THE ENEMY VAULT HAS FALLEN"
	],
	"BOTH VAULTS STAND EMPTY": [
		"OBA SKARBCE SĄ PUSTE",
		"BOTH VAULTS STAND EMPTY"
	],
	"YOUR VAULT HAS FALLEN": [
		"TWÓJ SKARBIEC ZOSTAŁ OPRÓŻNIONY",
		"YOUR VAULT HAS FALLEN"
	],
	"WAVE %d   ✦   YOUR GOLD %d   ✦   ENEMY GOLD %d": [
		"FALA %d   ✦   TWOJE ZŁOTO %d   ✦   ZŁOTO WROGA %d",
		"WAVE %d   ✦   YOUR GOLD %d   ✦   ENEMY GOLD %d"
	],
	"↻  PLAY AGAIN": [
		"↻  GRAJ PONOWNIE",
		"↻  PLAY AGAIN"
	],
	"⌂  RETURN TO MAIN MENU": [
		"⌂  WRÓĆ DO MENU",
		"⌂  RETURN TO MAIN MENU"
	],
	"ANIMATION STUDIO": [
		"STUDIO ANIMACJI",
		"ANIMATION STUDIO"
	],
	"LIVE ART • SAME ATLAS AS BATTLE": [
		"PODGLĄD JEDNOSTEK Z POLA BITWY",
		"LIVE ART • SAME ATLAS AS BATTLE"
	],
	"◀ HERO": [
		"◀ POSTAĆ",
		"◀ HERO"
	],
	"HERO ▶": [
		"POSTAĆ ▶",
		"HERO ▶"
	],
	"◀ ACTION": [
		"◀ AKCJA",
		"◀ ACTION"
	],
	"ACTION ▶": [
		"AKCJA ▶",
		"ACTION ▶"
	],
	"FLIP DIRECTION": [
		"ZMIEŃ KIERUNEK",
		"FLIP DIRECTION"
	],
	"CLOSE": [
		"ZAMKNIJ",
		"CLOSE"
	],
	"11 animated character roles. Base actions for every role, plus special sequences where available.": [
		"11 ról postaci. Podstawowe animacje każdej roli i dodatkowe sekwencje tam, gdzie są dostępne.",
		"11 animated character roles. Base actions for every role, plus special sequences where available."
	],
	"DWARF DEFENDER": [
		"KRASNOLUDZKI OBROŃCA",
		"DWARF DEFENDER"
	],
	"DWARF CARRIER": [
		"KRASNOLUDZKI TRAGARZ",
		"DWARF CARRIER"
	],
	"ELF RANGER": [
		"ELFI ŁOWCA",
		"ELF RANGER"
	],
	"ARCANE MAGE": [
		"TAJEMNY MAG",
		"ARCANE MAGE"
	],
	"GOBLIN RAIDER": [
		"GOBLIŃSKI ZŁODZIEJ",
		"GOBLIN RAIDER"
	],
	"GOBLIN SABOTEUR": [
		"GOBLIŃSKI SABOTAŻYSTA",
		"GOBLIN SABOTEUR"
	],
	"SHADOW WOLF": [
		"WILK CIENIA",
		"SHADOW WOLF"
	],
	"VOID SENTINEL": [
		"STRAŻNIK PUSTKI",
		"VOID SENTINEL"
	],
	"VOID STALKER": [
		"ŁOWCA PUSTKI",
		"VOID STALKER"
	],
	"VOID COLLECTOR": [
		"ZBIERACZ PUSTKI",
		"VOID COLLECTOR"
	],
	"VOID WEAVER": [
		"TKACZ PUSTKI",
		"VOID WEAVER"
	],
	"IDLE": [
		"SPOCZYNEK",
		"IDLE"
	],
	"WALK": [
		"RUCH",
		"WALK"
	],
	"ATTACK": [
		"ATAK",
		"ATTACK"
	],
	"HIT": [
		"TRAFIENIE",
		"HIT"
	],
	"DEATH": [
		"UPADEK",
		"DEATH"
	],
	"DEPOSIT": [
		"ODDANIE ZŁOTA",
		"DEPOSIT"
	],
	"CARRY": [
		"NIESIENIE ZŁOTA",
		"CARRY"
	],
	"RUN": [
		"BIEG",
		"RUN"
	],
	"SHIELD CHARGE": [
		"SZARŻA Z TARCZĄ",
		"SHIELD CHARGE"
	],
	"HAMMER STRIKE": [
		"CIOS MŁOTEM",
		"HAMMER STRIKE"
	],
	"BLOCK": [
		"BLOK",
		"BLOCK"
	],
	"EARTHQUAKE": [
		"TRZĘSIENIE ZIEMI",
		"EARTHQUAKE"
	],
	"BATTLE CRY": [
		"OKRZYK BOJOWY",
		"BATTLE CRY"
	],
	"PICK UP GOLD": [
		"PODNIESIENIE ZŁOTA",
		"PICK UP GOLD"
	],
	"CARRY GOLD": [
		"NIESIENIE ZŁOTA",
		"CARRY GOLD"
	],
	"ROLL": [
		"PRZEWRÓT",
		"ROLL"
	],
	"GOLD THROW": [
		"RZUT ZŁOTEM",
		"GOLD THROW"
	],
	"CELEBRATE": [
		"ŚWIĘTOWANIE",
		"CELEBRATE"
	],
	"LEAP": [
		"SKOK",
		"LEAP"
	],
	"POWER SHOT": [
		"MOCNY STRZAŁ",
		"POWER SHOT"
	],
	"DODGE": [
		"UNIK",
		"DODGE"
	],
	"ARROW VOLLEY": [
		"SALWA STRZAŁ",
		"ARROW VOLLEY"
	],
	"BLOOM": [
		"ROZKWIT",
		"BLOOM"
	],
	"TELEPORT": [
		"TELEPORTACJA",
		"TELEPORT"
	],
	"SHIELD": [
		"TARCZA",
		"SHIELD"
	],
	"BEAM": [
		"PROMIEŃ",
		"BEAM"
	],
	"RUNE": [
		"RUNA",
		"RUNE"
	],
	"SPRINT": [
		"SPRINT",
		"SPRINT"
	],
	"COMBO": [
		"KOMBINACJA",
		"COMBO"
	],
	"TAUNT": [
		"PROWOKACJA",
		"TAUNT"
	],
	"STEALTH": [
		"SKRADANIE",
		"STEALTH"
	],
	"SNEAK": [
		"PODKRADANIE",
		"SNEAK"
	],
	"BOMB": [
		"BOMBA",
		"BOMB"
	],
	"EXPLOSION": [
		"EKSPLOZJA",
		"EXPLOSION"
	],
	"SMOKE": [
		"DYM",
		"SMOKE"
	],
	"POUNCE": [
		"DOSKOK",
		"POUNCE"
	],
	"FRENZY": [
		"SZAŁ",
		"FRENZY"
	],
	"SHADOW DASH": [
		"PĘD CIENIA",
		"SHADOW DASH"
	],
	"HOWL": [
		"WYCIE",
		"HOWL"
	],
	"SPAWN": [
		"POJAWIENIE",
		"SPAWN"
	],
	"SPECIAL": [
		"SPECJALNA",
		"SPECIAL"
	],
	"MISSING SOURCE TEXTURE": [
		"BRAK TEKSTURY",
		"MISSING SOURCE TEXTURE"
	],
	"RIGHT": [
		"PRAWO",
		"RIGHT"
	],
	"LEFT": [
		"LEWO",
		"LEFT"
	],
	"SPECIAL ATLAS": [
		"ATLAS SPECJALNY",
		"SPECIAL ATLAS"
	],
	"EXTRA STRIP": [
		"DODATKOWA SEKWENCJA",
		"EXTRA STRIP"
	],
	"6-ROW ATLAS": [
		"ATLAS 6 RZĘDÓW",
		"6-ROW ATLAS"
	],
	"FRAME %d/%d • %s • %s": [
		"KLATKA %d/%d • %s • %s",
		"FRAME %d/%d • %s • %s"
	],
	"ROZPOCZNIJ GRĘ": [
		"ROZPOCZNIJ GRĘ",
		"START GAME"
	],
	"Księga gry": [
		"Księga gry",
		"Game guide"
	],
	"Ustawienia": [
		"Ustawienia",
		"Settings"
	],
	"WYBIERZ RASĘ": [
		"WYBIERZ RASĘ",
		"CHOOSE YOUR FACTION"
	],
	"Cztery style walki. Który jest twój?": [
		"Cztery style walki. Który jest twój?",
		"Four ways to fight. Which one is yours?"
	],
	"Poznaj tę rasę": [
		"Poznaj tę rasę",
		"Faction guide"
	],
	"Wróć": [
		"Wróć",
		"Back"
	],
	"GRAJ: %s": [
		"GRAJ: %s",
		"PLAY: %s"
	],
	"KSIĘGA GRY": [
		"KSIĘGA GRY",
		"GAME GUIDE"
	],
	"Jak grać": [
		"Jak grać",
		"How to play"
	],
	"Szukaj jednostki, pułapki, zdolności…": [
		"Szukaj jednostki, pułapki, zdolności…",
		"Search units, traps, abilities…"
	],
	"%d wpisów • statystyki: %s": [
		"%d wpisów • statystyki: %s",
		"%d entries • faction: %s"
	],
	"Brak wyników. Zmień kategorię lub skróć wyszukiwanie.": [
		"Brak wyników. Zmień kategorię lub skróć wyszukiwanie.",
		"No results. Change the category or try a shorter search."
	],
	"Pokaz działania": [
		"Pokaz działania",
		"Action demo"
	],
	"Spoczynek": [
		"Spoczynek",
		"Idle"
	],
	"Ruch": [
		"Ruch",
		"Move"
	],
	"Atak": [
		"Atak",
		"Attack"
	],
	"Trafienie": [
		"Trafienie",
		"Hit"
	],
	"Upadek": [
		"Upadek",
		"Defeat"
	],
	"Oddanie złota": [
		"Oddanie złota",
		"Deposit gold"
	],
	"Pauza": [
		"Pauza",
		"Pause"
	],
	"Odtwórz": [
		"Odtwórz",
		"Play"
	],
	"JAK DZIAŁA": [
		"JAK DZIAŁA",
		"HOW IT WORKS"
	],
	"KIEDY UŻYĆ": [
		"KIEDY UŻYĆ",
		"WHEN TO USE"
	],
	"Animacje": [
		"Animacje",
		"Animations"
	],
	"JAK GRAĆ": [
		"JAK GRAĆ",
		"HOW TO PLAY"
	],
	"Poznaj zasady. Zbuduj obronę. Wróć ze złotem.": [
		"Poznaj zasady. Zbuduj obronę. Wróć ze złotem.",
		"Learn the rules. Build your defenses. Bring the gold home."
	],
	"ZŁOTO JEST TWOIM ŻYCIEM": [
		"ZŁOTO JEST TWOIM ŻYCIEM",
		"GOLD IS YOUR LIFE"
	],
	"PRZYGOTOWANIE • 30 SEKUND": [
		"PRZYGOTOWANIE • 30 SEKUND",
		"PREPARATION • 30 SECONDS"
	],
	"ATAK • DO 60 SEKUND": [
		"ATAK • DO 60 SEKUND",
		"ATTACK • UP TO 60 SECONDS"
	],
	"ROZWIJAJ SKARBIEC": [
		"ROZWIJAJ SKARBIEC",
		"UPGRADE YOUR VAULT"
	],
	"BROŃ SWOICH ALEJEK": [
		"BROŃ SWOICH ALEJEK",
		"DEFEND YOUR LANES"
	],
	"RASY I ZDOLNOŚCI": [
		"RASY I ZDOLNOŚCI",
		"FACTIONS AND ABILITIES"
	],
	"ZWYCIĘSTWO": [
		"ZWYCIĘSTWO",
		"VICTORY"
	],
	"WRÓĆ DO MENU": [
		"WRÓĆ DO MENU",
		"MAIN MENU"
	],
	"USTAWIENIA": [
		"USTAWIENIA",
		"SETTINGS"
	],
	"Dostosuj oprawę do telefonu i swojego komfortu.": [
		"Dostosuj oprawę do telefonu i swojego komfortu.",
		"Adjust the game to your phone and comfort."
	],
	"JĘZYK": [
		"JĘZYK",
		"LANGUAGE"
	],
	"Język gry": [
		"Język gry",
		"Game language"
	],
	"Zmiana języka działa od razu i zostaje zapisana.": [
		"Zmiana języka działa od razu i zostaje zapisana.",
		"Your language changes immediately and is saved."
	],
	"JAKOŚĆ I BATERIA": [
		"JAKOŚĆ I BATERIA",
		"QUALITY AND BATTERY"
	],
	"Automatyczny ogranicza efekty przy utrzymujących się spadkach płynności. Oszczędny zmniejsza ruch i zużycie baterii.": [
		"Automatyczny ogranicza efekty przy utrzymujących się spadkach płynności. Oszczędny zmniejsza ruch i zużycie baterii.",
		"Auto reduces effects if performance stays low. Battery saver reduces motion and power use."
	],
	"Automatyczny": [
		"Automatyczny",
		"Automatic"
	],
	"Oszczędny • do 30 kl./s": [
		"Oszczędny • do 30 kl./s",
		"Battery saver • up to 30 FPS"
	],
	"Zrównoważony • do 60 kl./s": [
		"Zrównoważony • do 60 kl./s",
		"Balanced • up to 60 FPS"
	],
	"Wysoki • do 60 kl./s": [
		"Wysoki • do 60 kl./s",
		"High • up to 60 FPS"
	],
	"KOMFORT": [
		"KOMFORT",
		"COMFORT"
	],
	"Ogranicz ruch": [
		"Ogranicz ruch",
		"Reduce motion"
	],
	"Muzyka": [
		"Muzyka",
		"Music"
	],
	"Licznik płynności w bitwie": [
		"Licznik płynności w bitwie",
		"Show FPS in battle"
	],
	"Zmiany zapisują się od razu. Jakość efektów nie zmienia zasad, kosztów ani obrażeń.": [
		"Zmiany zapisują się od razu. Jakość efektów nie zmienia zasad, kosztów ani obrażeń.",
		"Changes are saved immediately. Visual quality does not change rules, prices or damage."
	],
	"oszczędny": [
		"oszczędny",
		"battery saver"
	],
	"zrównoważony": [
		"zrównoważony",
		"balanced"
	],
	"wysoki": [
		"wysoki",
		"high"
	],
	"Aktywny profil: %s": [
		"Aktywny profil: %s",
		"Active profile: %s"
	],
	"Wszystko": [
		"Wszystko",
		"All"
	],
	"Rasy": [
		"Rasy",
		"Factions"
	],
	"Jednostki": [
		"Jednostki",
		"Units"
	],
	"Obrona": [
		"Obrona",
		"Defense"
	],
	"Ulepszenia": [
		"Ulepszenia",
		"Upgrades"
	],
	"Zdolności": [
		"Zdolności",
		"Abilities"
	],
	"Zasady": [
		"Zasady",
		"Rules"
	],
	"Krasnoludy": [
		"Krasnoludy",
		"Dwarves"
	],
	"Gobliny": [
		"Gobliny",
		"Goblins"
	],
	"Elfy": [
		"Elfy",
		"Elves"
	],
	"Voidborn": [
		"Voidborn",
		"Voidborn"
	],
	"Pancerz i oszczędzanie": [
		"Pancerz i oszczędzanie",
		"Armor and savings"
	],
	"Szybkie wypady": [
		"Szybkie wypady",
		"Fast raids"
	],
	"Wytrzymałość i łupy": [
		"Wytrzymałość i łupy",
		"Endurance and loot"
	],
	"Tempo i duże łupy": [
		"Tempo i duże łupy",
		"Speed and rich loot"
	],
	"24% odsetek  •  +25% PŻ najeźdźców": [
		"24% odsetek  •  +25% PŻ najeźdźców",
		"24% interest  •  +25% raider HP"
	],
	"18% odsetek  •  +20% tempa  •  +5% łupu": [
		"18% odsetek  •  +20% tempa  •  +5% łupu",
		"18% interest  •  +20% speed  •  +5% loot"
	],
	"18% odsetek  •  +10% PŻ  •  +5% łupu": [
		"18% odsetek  •  +10% PŻ  •  +5% łupu",
		"18% interest  •  +10% HP  •  +5% loot"
	],
	"18% odsetek  •  +5% tempa  •  +8% łupu": [
		"18% odsetek  •  +5% tempa  •  +8% łupu",
		"18% interest  •  +5% speed  •  +8% loot"
	],
	"Odsetki: %d%% / falę": [
		"Odsetki: %d%% / falę",
		"Interest: %d%% / wave"
	],
	"Zdolność: %s": [
		"Zdolność: %s",
		"Ability: %s"
	],
	"4 role jednostek": [
		"4 role jednostek",
		"4 unit roles"
	],
	"Premie PŻ i tempa dotyczą najeźdźców. Obrońcy mają osobne statystyki.": [
		"Premie PŻ i tempa dotyczą najeźdźców. Obrońcy mają osobne statystyki.",
		"HP and speed bonuses apply to raiders. Defenders have separate stats."
	],
	"Darmowa fala": [
		"Darmowa fala",
		"Free wave"
	],
	"Zwiadowca": [
		"Zwiadowca",
		"Runner"
	],
	"Tragarz": [
		"Tragarz",
		"Carrier"
	],
	"Sabotażysta": [
		"Sabotażysta",
		"Saboteur"
	],
	"Koszt: %d złota": [
		"Koszt: %d złota",
		"Cost: %d gold"
	],
	"PŻ: %.0f": [
		"PŻ: %.0f",
		"HP: %.0f"
	],
	"Łup: %d złota": [
		"Łup: %d złota",
		"Loot: %d gold"
	],
	"Droga w jedną stronę: ~%.1f s": [
		"Droga w jedną stronę: ~%.1f s",
		"One-way trip: ~%.1f s"
	],
	"Obrońca": [
		"Obrońca",
		"Defender"
	],
	"Obrażenia: 26": [
		"Obrażenia: 26",
		"Damage: 26"
	],
	"Atak: co 0,9 s": [
		"Atak: co 0,9 s",
		"Attack: every 0.9 s"
	],
	"Kolce": [
		"Kolce",
		"Spikes"
	],
	"Sidła": [
		"Sidła",
		"Snare"
	],
	"Wieżyczka": [
		"Wieżyczka",
		"Turret"
	],
	"Obrażenia: %.0f": [
		"Obrażenia: %.0f",
		"Damage: %.0f"
	],
	"Ładunki: %d": [
		"Ładunki: %d",
		"Charges: %d"
	],
	"Przeładowanie: 0,6 s": [
		"Przeładowanie: 0,6 s",
		"Reload: 0.6 s"
	],
	"Maks. 5 obiektów / alejkę": [
		"Maks. 5 obiektów / alejkę",
		"Max. 5 objects / lane"
	],
	"Skarbiec • poziomy 0–5": [
		"Skarbiec • poziomy 0–5",
		"Vault • levels 0–5"
	],
	"Koszty: %d / %d / %d / %d / %d": [
		"Koszty: %d / %d / %d / %d / %d",
		"Costs: %d / %d / %d / %d / %d"
	],
	"Odsetki: %d%% → %d%%": [
		"Odsetki: %d%% → %d%%",
		"Interest: %d%% → %d%%"
	],
	"+4 p.p. / poziom": [
		"+4 p.p. / poziom",
		"+4 percentage points / level"
	],
	"Limit: poziom 5": [
		"Limit: poziom 5",
		"Limit: level 5"
	],
	"Trening najazdu": [
		"Trening najazdu",
		"Raid training"
	],
	"Koszty treningu: 120 / 200 / 280": [
		"Koszty treningu: 120 / 200 / 280",
		"Training costs: 120 / 200 / 280"
	],
	"3 poziomy": [
		"3 poziomy",
		"3 levels"
	],
	"PŻ: +12% / poziom": [
		"PŻ: +12% / poziom",
		"HP: +12% / level"
	],
	"Tempo: +8% / poziom": [
		"Tempo: +8% / poziom",
		"Speed: +8% / level"
	],
	"Raz na falę": [
		"Raz na falę",
		"Once per wave"
	],
	"Tylko przygotowania": [
		"Tylko przygotowania",
		"Preparation only"
	],
	"Złoto, życie i zwycięstwo": [
		"Złoto, życie i zwycięstwo",
		"Gold, life and victory"
	],
	"Trzy alejki": [
		"Trzy alejki",
		"Three lanes"
	],
	"Przygotowanie i atak": [
		"Przygotowanie i atak",
		"Preparation and attack"
	],
	"1000 złota na start": [
		"1000 złota na start",
		"1000 starting gold"
	],
	"%d s przygotowań": [
		"%d s przygotowań",
		"%d s preparation"
	],
	"%d s ataku": [
		"%d s ataku",
		"%d s attack"
	],
	"3 alejki": [
		"3 alejki",
		"3 lanes"
	],
	"Podgląd wstrzymany": [
		"Podgląd wstrzymany",
		"Preview paused"
	],
	"Kolce • 50 obrażeń • 3 ładunki": [
		"Kolce • 50 obrażeń • 3 ładunki",
		"Spikes • 50 damage • 3 charges"
	],
	"Sidła • zatrzymanie na 2,5 s": [
		"Sidła • zatrzymanie na 2,5 s",
		"Snare • stops enemies for 2.5 s"
	],
	"Wieżyczka • strzał co 0,6 s": [
		"Wieżyczka • strzał co 0,6 s",
		"Turret • fires every 0.6 s"
	],
	"Rozwój skarbca • poziom %d / 5": [
		"Rozwój skarbca • poziom %d / 5",
		"Vault upgrade • level %d / 5"
	],
	"Trening • więcej PŻ i szybszy ruch": [
		"Trening • więcej PŻ i szybszy ruch",
		"Training • more HP and speed"
	],
	"Obrońca • pilnuje swojej alejki": [
		"Obrońca • pilnuje swojej alejki",
		"Defender • guards its own lane"
	],
	"Poznaj styl swojej rasy": [
		"Poznaj styl swojej rasy",
		"Discover your faction's play style"
	],
	"Wyprawa po złoto": [
		"Wyprawa po złoto",
		"Raiding for gold"
	],
	"Powrót z łupem": [
		"Powrót z łupem",
		"Returning with loot"
	],
	"ARSENAŁ ↑": [
		"ARSENAŁ ↑",
		"ARSENAL ↑"
	],
	"SCHOWAJ ↓": [
		"SCHOWAJ ↓",
		"HIDE ↓"
	],
	"MENU": [
		"MENU",
		"MENU"
	],
	"BAZA": [
		"BAZA",
		"BASE"
	],
	"AKCJA": [
		"AKCJA",
		"ACTION"
	],
	"WRÓG": [
		"WRÓG",
		"ENEMY"
	],
	"ZŁOTO %d": [
		"ZŁOTO %d",
		"GOLD %d"
	],
	"WRÓG %d": [
		"WRÓG %d",
		"ENEMY %d"
	],
	"PRZYGOTOWANIE": [
		"PRZYGOTOWANIE",
		"PREPARATION"
	],
	"BITWA": [
		"BITWA",
		"BATTLE"
	],
	"ZBLIŻENIE": [
		"ZBLIŻENIE",
		"CLOSE VIEW"
	],
	"CAŁA MAPA": [
		"CAŁA MAPA",
		"FULL MAP"
	],
	"GRAJ PONOWNIE": [
		"GRAJ PONOWNIE",
		"PLAY AGAIN"
	],
	"ROZPOCZNIJ ATAK": [
		"ROZPOCZNIJ ATAK",
		"START RAID"
	],
	"BITWA TRWA": [
		"BITWA TRWA",
		"BATTLE IN PROGRESS"
	],
	"AKTYWNA": [
		"AKTYWNA",
		"ACTIVE"
	],
	"SKARBIEC %d/5": [
		"SKARBIEC %d/5",
		"VAULT %d/5"
	],
	"TRENING %d/3": [
		"TRENING %d/3",
		"TRAINING %d/3"
	],
	"ALEJKA %d": [
		"ALEJKA %d",
		"LANE %d"
	],
	"FALA %d • %s\n%d s • odsetki %d%%": [
		"FALA %d • %s\n%d s • odsetki %d%%",
		"WAVE %d • %s\n%d s • interest %d%%"
	],
	"Krasnoludy: 24% odsetek i +25% PŻ najeźdźców": [
		"Krasnoludy: 24% odsetek i +25% PŻ najeźdźców",
		"Dwarves: 24% interest and +25% raider HP"
	],
	"Gobliny: 18% odsetek, +20% tempa i +5% pojemności": [
		"Gobliny: 18% odsetek, +20% tempa i +5% pojemności",
		"Goblins: 18% interest, +20% speed and +5% capacity"
	],
	"Elfy: 18% odsetek, +10% PŻ i +5% pojemności": [
		"Elfy: 18% odsetek, +10% PŻ i +5% pojemności",
		"Elves: 18% interest, +10% HP and +5% capacity"
	],
	"Voidborn: 18% odsetek, +5% tempa i +8% pojemności": [
		"Voidborn: 18% odsetek, +5% tempa i +8% pojemności",
		"Voidborn: 18% interest, +5% speed and +8% capacity"
	],
	"TWÓJ SKARBIEC. TWOJA LEGENDA.": [
		"TWÓJ SKARBIEC. TWOJA LEGENDA.",
		"YOUR VAULT. YOUR LEGEND."
	],
	"Zdobądź złoto wroga. Ocal własny skarbiec.": [
		"Zdobądź złoto wroga. Ocal własny skarbiec.",
		"Steal the enemy's gold. Save your own vault."
	],
	"GALERIA POSTACI": [
		"GALERIA POSTACI",
		"CHARACTER GALLERY"
	],
	"Wybierz bohatera i poznaj jego ruchy": [
		"Wybierz bohatera i poznaj jego ruchy",
		"Choose a hero and explore its moves"
	],
	"◀ POSTAĆ": [
		"◀ POSTAĆ",
		"◀ HERO"
	],
	"POSTAĆ ▶": [
		"POSTAĆ ▶",
		"HERO ▶"
	],
	"ZMIEŃ KIERUNEK": [
		"ZMIEŃ KIERUNEK",
		"FLIP DIRECTION"
	],
	"WRÓĆ": [
		"WRÓĆ",
		"BACK"
	]
}

static func set_language(value: String) -> void:
	language = value if value in LANGUAGES else "en"
	TranslationServer.set_locale(language)

static func t(source: String) -> String:
	if not MESSAGES.has(source):
		return source
	return str(MESSAGES[source][0 if language == "pl" else 1])
