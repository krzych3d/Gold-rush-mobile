extends RefCounted
## Player-facing reference built from the same constants and stat calculator as battle.
const CATEGORIES := ["Wszystko", "Rasy", "Jednostki", "Obrona", "Ulepszenia", "Zdolności", "Zasady"]
const RACE_TITLES := ["Krasnoludy", "Gobliny", "Elfy", "Voidborn"]
const RACE_STYLES := ["Pancerz i oszczędzanie", "Szybkie wypady", "Wytrzymałość i łupy", "Tempo i duże łupy"]
const RACE_COPY := [
	"Krasnoludy budują przewagę dzięki oszczędnościom. Ich najeźdźcy mają o 25% więcej punktów życia, a bazowe odsetki wynoszą 28% po fali.",
	"Gobliny wysyłają najeźdźców szybszych o 20%. Szybciej docierają do skarbca i wracają ze złotem. Bazowe odsetki: 18% po fali.",
	"Elfi najeźdźcy mają o 10% więcej punktów życia i mieszczą dodatkowe 10 złota. Bazowe odsetki: 18% po fali.",
	"Kosmiczni zabójcy Voidborn wysyłają najeźdźców szybszych o 10%, z miejscem na dodatkowe 15 złota. Bazowe odsetki: 18% po fali."
]
const RACE_TIPS := [
	"Zostaw część złota w skarbcu. Wyższe odsetki działają od oszczędności pozostałych po zakupach.",
	"Wybierz słabiej bronioną alejkę i łącz szybkie wypady z większym transportem złota.",
	"Chroń powracających tragarzy. Większa pojemność daje zysk dopiero po bezpiecznym powrocie.",
	"Przed trudnym wypadem aktywuj Shadow Step: najeźdźca ominie pierwszy napotkany efekt pułapki."
]
const ABILITY_COPY := [
	"Iron Wall dodaje 60 aktualnych i maksymalnych PŻ każdemu TWOJEMU OBROŃCY obecnemu w chwili aktywacji. Nie wzmacnia obrońców kupionych później.",
	"Goblin Frenzy zwiększa prędkość wszystkich twoich najeźdźców nadchodzącej fali o 35%, oprócz ich stałej premii rasowej.",
	"Moon Blessing dodaje 35 miejsc na złoto każdemu twojemu najeźdźcy nadchodzącej fali, oprócz stałej premii elfów.",
	"Shadow Step zwiększa prędkość twoich najeźdźców o 18% w nadchodzącej fali. Każdy z nich jednorazowo omija pierwszy napotkany efekt pułapki."
]

static func portrait(race: int) -> String:
	return "res://assets/epic/portraits/%s.jpg" % ["dwarves", "goblins", "elves", "voidborn"][race]

static func card_art(race: int, item: String) -> String:
	var prefix: String = ["dwarf_", "goblin_", "elf_", ""][race]
	var filename: String = "ability_void" if race == 3 and item == "ability" else prefix + item
	return "res://assets/ui/direct/%s.png" % filename

static func _entry(id: String, category: String, title: String, body: String, tip: String, art: String, demo: String, race: int, role: int = 0) -> Dictionary:
	return {"id": id, "category": category, "title": title, "body": body, "tip": tip,
		"art": art, "demo": demo, "race": race, "role": role, "stats": [], "limit": ""}

static func entries(game, race: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for index in 4:
		var entry := _entry("race_%d" % index, "Rasy", RACE_TITLES[index], RACE_COPY[index], RACE_TIPS[index], portrait(index), "race", index)
		entry["stats"] = [RACE_STYLES[index], "Odsetki: %d%% / falę" % roundi(game.interest_rate(index, 0) * 100.0), "Zdolność: " + str(game.ABILITY_NAMES[index]), "4 role jednostek"]
		entry["limit"] = "Premie PŻ i tempa dotyczą najeźdźców. Obrońcy mają osobne statystyki."
		result.append(entry)
	var names := ["Darmowa fala", "Zwiadowca", "Tragarz", "Sabotażysta"]
	var ids := ["free_wave", "runner", "carrier", "saboteur"]
	var bodies := [
		"Najeźdźcy dołączają bez opłaty na każdej alejce po rozpoczęciu ataku. Zbierają złoto i wracają do twojego skarbca tak samo jak płatne jednostki.",
		"Szybki najeźdźca do wypadów na skarbiec. Kradnie złoto, odwraca się i wraca tą samą alejką. Zysk trafia do ciebie po powrocie.",
		"Powolny i wytrzymały najeźdźca z dużą pojemnością na złoto. To transport łupu; nie jest dodatkowym obrońcą skarbca.",
		"Rozbraja pierwsze napotkane kolce lub sidła bez obrażeń od tej pułapki. Może to zrobić raz na wyprawę. Nie rozbraja wieżyczek."
	]
	var tips := ["Wesprzyj falę zakupami na wybranej alejce. Darmowe jednostki też korzystają z premii rasy i treningu.", "Użyj na słabiej bronionej alejce. Mniej PŻ oznacza duże ryzyko wobec kolców.", "Wyślij obok szybszych jednostek. Chroń drogę powrotną, aby nie stracić dużego łupu.", "Kup przed tragarzem, gdy na trasie są kolce albo sidła. Wieżyczkę pokonaj większą grupą."]
	for index in 4:
		var kind: int = index - 1
		var stats: Dictionary = game.raider_stats(kind, race, false, 0)
		var art_name: String = "runner" if kind < 0 else ids[index]
		var entry := _entry(ids[index], "Jednostki", names[index], bodies[index], tips[index], card_art(race, art_name), "unit", race, kind)
		entry["stats"] = ["Koszt: %d złota" % (0 if kind < 0 else game.COSTS[kind]), "PŻ: %.0f" % float(stats["health"]), "Łup: %d złota" % int(stats["capacity"]), "Droga w jedną stronę: ~%.1f s" % (1.0 / float(stats["speed"]))]
		entry["limit"] = "Statystyki rasy bez treningu i zdolności. Maks. 6 płatnych jednostek na falę, 4 na alejce." if kind >= 0 else "Po 2, 3, 4, 5 i 7 jednostek na alejce w falach 1–5; od fali 5 po 7."
		result.append(entry)
	var defender := _entry("defender", "Obrona", "Obrońca", "Pozostaje na wybranej alejce i atakuje pobliskich wrogów. Zadaje 26 obrażeń co 0,9 s, gdy ma cel w zasięgu. Przetrwałe jednostki bronią w kolejnych falach.", "Rozstaw przed atakiem. Jako krasnolud najpierw kup obrońców, a potem aktywuj Iron Wall.", card_art(race, "defender"), "defender", race)
	defender["stats"] = ["Koszt: %d złota" % game.GUARD_COST, "PŻ: %.0f" % game.GUARD_HP, "Obrażenia: 26", "Atak: co 0,9 s"]
	defender["limit"] = "Maks. 3 twoich obrońców na alejce. Każdy zakup uszczupla skarbiec."
	result.append(defender)
	var trap_names := ["Kolce", "Sidła", "Wieżyczka"]
	var trap_ids := ["spikes", "snare", "turret"]
	var trap_bodies := ["Zadają 40 obrażeń przy uruchomieniu. Mają 3 ładunki. Pojedynczy najeźdźca uruchamia dane kolce tylko raz.", "Zadają 25 obrażeń i zatrzymują najeźdźcę na 2,5 s. Mają 2 ładunki. To zatrzymanie, a nie trwałe obniżenie szybkości.", "Strzela w przeciwników na swojej alejce: 11 obrażeń co 0,6 s. Działa również w kolejnych falach i nie jest rozbrajana przez sabotażystę."]
	for index in 3:
		var entry := _entry(trap_ids[index], "Obrona", trap_names[index], trap_bodies[index], "Broń zagrożonej alejki i łącz z obrońcą. Uważaj na sabotażystów." if index < 2 else "Połącz z sidłami: zatrzymany przeciwnik dłużej pozostaje pod ostrzałem.", card_art(race, trap_ids[index]), trap_ids[index], race)
		entry["stats"] = ["Koszt: %d złota" % game.TRAP_COSTS[index], "Obrażenia: %.0f" % float(game.TRAP_DAMAGE[index]), "Ładunki: %d" % game.TRAP_CHARGES[index] if index < 2 else "Przeładowanie: 0,6 s", "Maks. 5 obiektów / alejkę"]
		entry["limit"] = "Buduj podczas przygotowań. Wybrana alejka dotyczy każdego nowego zakupu."
		result.append(entry)
	var bank := _entry("bank", "Ulepszenia", "Skarbiec • poziomy 0–5", "Złoto jest jednocześnie twoim życiem i walutą. Każdy poziom skarbca dodaje 4 punkty procentowe do odsetek po fali. Poziomy 1–5 mają osobne budynki w grze.", "Odsetki liczą się od pozostałego złota; minimalna wypłata to 20. Nie wydawaj ostatnich monet na ulepszenie.", card_art(race, "bank"), "bank", race)
	bank["stats"] = ["Koszty: %d / %d / %d / %d / %d" % [game.BANK_BASE_COST, game.BANK_BASE_COST + game.BANK_STEP_COST, game.BANK_BASE_COST + 2 * game.BANK_STEP_COST, game.BANK_BASE_COST + 3 * game.BANK_STEP_COST, game.BANK_BASE_COST + 4 * game.BANK_STEP_COST], "Odsetki: %d%% → %d%%" % [roundi(game.interest_rate(race, 0) * 100.0), roundi(game.interest_rate(race, 5) * 100.0)], "+4 p.p. / poziom", "Limit: poziom 5"]
	bank["limit"] = "Ulepszenie kosztuje złoto z twojego skarbca. Zero złota kończy mecz od razu."
	result.append(bank)
	var raid := _entry("raid", "Ulepszenia", "Trening najazdu", "Każdy poziom dodaje najeźdźcom 12% bazowych PŻ i 8% bazowego tempa. Premie treningu mnożą statystyki po uwzględnieniu rasy i zdolności. Działa w kolejnych falach.", "Kup trening, gdy planujesz wysyłać więcej jednostek. Nie zwiększa pojemności łupu ani siły obrońców.", card_art(race, "raid"), "raid", race)
	raid["stats"] = ["Koszt: %d / poziom" % game.RAID_COST, "3 poziomy", "PŻ: +12% / poziom", "Tempo: +8% / poziom"]
	raid["limit"] = "Maksymalnie +36% PŻ i +24% tempa. Zakupy tylko w przygotowaniach."
	result.append(raid)
	for index in 4:
		var entry := _entry("ability_%d" % index, "Zdolności", str(game.ABILITY_NAMES[index]), ABILITY_COPY[index], "Aktywuj w przygotowaniach przed rozpoczęciem ataku." if index != 0 else "Najpierw zatrudnij obrońców, potem wzmocnij ich zdolnością.", card_art(index, "ability"), "ability", index)
		entry["stats"] = ["Koszt: %d złota" % game.ABILITY_COST, RACE_TITLES[index], "Raz na falę", "Tylko przygotowania"]
		entry["limit"] = "Gotowość odnawia się przy kolejnej fali. Nie aktywuje się w czasie ataku."
		result.append(entry)
	var rules := [
		["gold", "Złoto, życie i zwycięstwo", "Zaczynasz z 1000 złota. Zakupy oraz kradzieże zmniejszają zawartość skarbca. Gdy skarbiec jednej strony osiąga zero, mecz kończy się natychmiast. Skradzione monety zwiększają twój skarbiec dopiero po powrocie najeźdźcy.", "Zachowuj rezerwę. Śmierć złodzieja z łupem zwraca monety obrabowanej stronie.", "bank"],
		["lanes", "Trzy alejki", "Dotknij górnej, środkowej lub dolnej alejki. Płatni najeźdźcy, obrońcy i pułapki trafiają na aktualnie wybraną trasę. Darmowa fala rusza wszystkimi trzema.", "Obserwuj wroga i wzmacniaj zagrożoną trasę. Pustej alejki nie osłania obrońca z sąsiedniej.", "unit"],
		["phases", "Przygotowanie i atak", "Masz 30 sekund na zakupy. Możesz rozpocząć atak wcześniej przyciskiem najazdu. Atak trwa do 60 sekund lub do powrotu i usunięcia wszystkich najeźdźców. Potem otrzymujesz odsetki i zaczyna się następna fala.", "Niedostarczony łup po końcu czasu wraca do obrabowanej strony. Walka trwa do opróżnienia skarbca.", "unit"]
	]
	for rule in rules:
		var entry := _entry(rule[0], "Zasady", rule[1], rule[2], rule[3], "res://assets/ui/direct/gold_bar.png", rule[4], race)
		entry["stats"] = ["1000 złota na start", "%d s przygotowań" % int(game.PREP_TIME), "%d s ataku" % int(game.ATTACK_TIME), "3 alejki"]
		result.append(entry)
	return result

static func find(game, race: int, id: String) -> Dictionary:
	for entry in entries(game, race):
		if entry["id"] == id:
			return entry
	return {}
