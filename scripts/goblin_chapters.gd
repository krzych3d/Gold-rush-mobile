extends RefCounted
## The first two playable chapters of Thieves of Fate. Further chapters are not
## advertised as playable. Their revelations remain outside the narrator's POV.
const MISSIONS = [
	{"id": "goblin_contract", "race": 1, "level": 1, "requires": "", "map": "dwarves", "enemy": 0, "waves": 4, "target": 1, "gold": 1400, "rule": "heist", "artifact_lane": 1, "portrait": "rikk",
	"title": ["Zlecenie od nieznajomej", "The Stranger's Contract"],
	"setting": ["Vargheim • ta sama noc, druga strona bramy", "Vargheim • the same night, the other side of the gate"],
	"objective": ["Najmij najeźdźcę i ukradnij Kamień Pamięci środkową alejką. Dostarcz artefakt do własnego skarbca w 4 falach; złoto nie zastąpi przedmiotu.", "Hire a raider and steal the Memory Stone through the middle lane. Bring the artefact to your vault within 4 waves; gold cannot replace the item."],
	"recap": ["Rikk Złoty Kieł zarabia kradzieżą rzeczy, których możni nie chcą przyznać się posiadać. Nix, jego przyjaciółka i wynalazczyni, przygotowuje drogi ucieczki. Przybyli do Vargheim na królewski pogrzeb. Rikk pamięta gwiazdę, której brak nad wieżą. Nix twierdzi, że nigdy jej tam nie było.", "Rikk Goldfang steals things the powerful will not admit to owning. His friend Nix, an inventor, prepares the escape routes. They came to Vargheim for the royal funeral. Rikk remembers a star missing above the tower. Nix says it was never there."],
	"briefing": ["Środkowa alejka prowadzi do Kamienia Pamięci. Pierwszy płatny najeźdźca, który dotrze nią do wrogiego skarbca, otworzy zamek wytrychem Nix i zabierze artefakt. Każdy z trzech płatnych typów ma wytrych; darmowa fala jedynie odwraca uwagę straży i kradnie zwykłe złoto. Dopiero jego powrót do domu kończy kradzież. Jeśli zginie albo skończy się czas fali, kamień wróci do komory. Odsetki i dostarczone monety nie zastąpią przedmiotu. Masz najwyżej cztery fale.", "The middle lane leads to the Memory Stone. Your first paid raider to reach the enemy vault along it opens the lock with Nix's lockpick and takes the artefact. All three paid roles have a lockpick; free waves distract the guards and steal ordinary gold. The theft succeeds only when that carrier returns home. If the carrier falls or the wave times out, the stone returns to its chamber. Interest and delivered coins cannot replace the item. You have at most four waves."],
	"intro": ["""Gobliny opowiadają o Matce Tysiąca Nici, która utkała wszystkie możliwe historie. Dobry złodziej nie przecina jej splotu. Wyciąga jedną nić i sprawia, że nikt nie zauważa różnicy. Rikk wolał dotąd historie bez bogów: w nich łatwiej negocjować cenę.

Nieznajoma: Ukradnij śmierć. Krasnoludy zamknęły jej węzeł w Kamieniu Pamięci. Usuniesz go, a tysiące uwięzionych dostaną drogę na zewnątrz.
Rikk: Zamknięte drzwi rozumiem. Śmierć zwykle przychodzi sama. Kto zapłaci za jej wyniesienie?

Kobieta kładzie na stole dwie monety. Na pierwszej Nix widzi własną dłoń z oparzeniem, którego jeszcze nie ma. Na drugiej stoi Vargheim bez jednej z wież. Kiedy zasłania je palcem, obrazy nie znikają. Nieznajoma zna także imię matki Rikka, którego nie ma w żadnym miejskim rejestrze.

Nix: Płacisz jutrem. Co stanie się z ludźmi w tych domach?
Nieznajoma: To, co już im zrobiono, będzie mogło się skończyć. Popatrzcie pod ołtarz, zanim nazwiecie ich ratunek kradzieżą.

Pod posadzką królewskiej twierdzy słyszą głosy. Każdy urywa się, gdy nad nimi dźwięczy nowa moneta. Rikk zna ten odgłos z targów: dźwięk podpisywania umowy. Nie zna umowy, którą można podpisywać po śmierci.

Rikk: Bierzemy kamień. Żadnych domów, żadnych imiennych monet na zapłatę. Pokaż mi drogę do komory.
Nix: Środkowa alejka. Daj mojemu oddziałowi zapłatę, a każdy najęty zwiadowca, tragarz czy sabotażysta dostanie wytrych do zamka. Darmowi najeźdźcy odciągną straż. Wyrwanie przedmiotu nie wystarczy. Nasi muszą go przynieść z powrotem. Przygotuję schronienie po tej stronie bramy. I tym razem wrócisz także ty.""", """Goblins tell of the Mother of a Thousand Threads, who wove every possible story. A good thief does not cut her weave. He slips out one thread and leaves nobody noticing the difference. Rikk has preferred stories without gods: their prices are easier to negotiate.

Stranger: Steal death. The dwarves bound its knot inside the Memory Stone. Remove it and thousands of prisoners will have a way out.
Rikk: I understand locked doors. Death usually lets itself in. Who pays for carrying it out?

The woman lays two coins on the table. On the first, Nix sees her hand with a burn it does not yet bear. On the second, Vargheim stands without one of its towers. Covering the coins does not erase the images. The stranger also knows Rikk's mother's name, absent from every city register.

Nix: You are paying with tomorrow. What happens to the people in those houses?
Stranger: What has already been done to them will be allowed to end. Look beneath the altar before you call their rescue theft.

Beneath the royal fortress they hear voices. Each breaks off when a fresh coin rings above them. Rikk knows that sound from markets: the signing of a contract. He does not know a contract that can be signed after death.

Rikk: We take the stone. No houses, no name-coins as payment. Show me the road to the chamber.
Nix: The middle lane. Pay for a squad and every hired runner, carrier or saboteur gets a lockpick. Free raiders draw off the guards. Pulling the item free is not enough. Our people must bring it back. I will prepare a refuge on this side of the gate. And this time you come back too."""],
	"mid": ["""Nix: Pod ołtarzem jest przecięta runa. Ktoś był tu przed nami. Jej krawędź jeszcze świeci, jakby ostrze zostawiło kawałek poranka.
Rikk: Nieznajoma powiedziała, że to my otworzymy komorę. Dlaczego zapomniała wspomnieć o poprzednim gościu?

W kamieniu odbija się krasnolud z monetą przy sercu. Stoi po przeciwnej stronie walki. Nie widzi Rikka; patrzy w miejsce, w którym jeszcze przed chwilą było czyjeś okno. Rikk chciałby wiedzieć, czy patrzą na ten sam moment.

Nix: Oznaczona droga nadal prowadzi do kamienia. Jeśli nasz człowiek go niesie, osłoń jego powrót. Samo złoto niczego tutaj nie odwiąże.""", """Nix: A rune beneath the altar has been cut. Someone was here before us. Its edge still shines, as though a blade left a piece of morning behind.
Rikk: The stranger said we would open the chamber. Why did she forget to mention its previous visitor?

The stone reflects a dwarf holding a coin against his heart. He stands beyond the fighting. He does not see Rikk; he is looking where somebody's window stood a moment ago. Rikk wishes he knew whether they are watching the same moment.

Nix: The marked road still leads to the stone. If our carrier has it, cover the return. Gold alone will untie nothing here."""],
	"outro": ["""Kamień przekracza próg schronienia. Nix otwiera jego miedzianą klatkę; ze środka wyciąga się cienka nić. Za nią nadchodzą tysiące głosów. Po raz pierwszy żaden nie brzmi jak rozkaz.

Rikk: To miało ich uwolnić.
Po drugiej stronie bramy ktoś krzyczy: «Złodziej!». Rikk widzi jak w dymie znika zarys miasta. Nie widzi ciał. Nie widzi też nikogo, komu mógłby powiedzieć, że słyszał więźniów pod ołtarzem.

Nix: Spójrz na moją dłoń.
Poparzyła ją przy zamku klatki. Rana układa się dokładnie jak na monecie. Nieznajoma nie zmieniła jutra, żeby im zapłacić. Wiedziała, które jutro od nich kupuje.

Rikk zabiera pusty kamień do Szeptowiska. Chce odnaleźć zleceniodawczynię i dowiedzieć się, gdzie wyszły uwolnione głosy. Przy pierwszej miejskiej bramie widzą kondukt. Trumna porusza się od środka. Żałobnicy nie uciekają. Zmęczeni przytrzymują wieko, jakby próbowali dokończyć zwykłą pracę.""", """The stone crosses the refuge threshold. Nix opens its copper cage; a thin thread slips out. Thousands of voices follow. For the first time none sounds like an order.

Rikk: This was meant to free them.
Beyond the gate someone shouts: 'Thief!' Rikk sees the city's outline vanish into smoke. He sees no bodies. Nor can he find anyone to tell about the prisoners he heard beneath the altar.

Nix: Look at my hand.
The cage lock has burned her. The wound matches the coin exactly. The stranger did not change tomorrow to pay them. She knew which tomorrow she was buying.

Rikk takes the empty stone to Whispermarket. He wants to find their employer and learn where the freed voices went. At the first city gate they meet a funeral procession. The coffin moves from within. The mourners do not run. Exhausted, they hold down the lid as though trying to finish an ordinary job."""]},
	{"id": "goblin_funeral", "race": 1, "level": 1, "requires": "goblin_contract", "map": "goblins", "enemy": 1, "waves": 3, "target": 0, "gold": 1350, "rule": "undying", "portrait": "nix",
	"title": ["Miasto bez pogrzebów", "The City Without Funerals"],
	"setting": ["Szeptowisko • świt po kradzieży", "Whispermarket • dawn after the theft"],
	"objective": ["Utrzymaj schronienie przez 3 fale. Goblińscy najeźdźcy i obrońcy obu stron wracają raz na falę, słabsi po każdym powrocie.", "Hold the refuge for 3 waves. Goblin raiders and defenders on both sides rise once per wave, weaker after each return."],
	"recap": ["Rikk i Nix wynieśli Kamień Pamięci z Vargheim, wierząc, że uwolnią więźniów. Miasto zniknęło im z oczu, a przepowiedziane na zapłacie oparzenie pojawiło się na dłoni Nix. Wracają do Szeptowiska szukać nieznajomej. Tymczasem w ich mieście nie udaje się dokończyć żadnego pogrzebu.", "Rikk and Nix took the Memory Stone from Vargheim, believing they would free prisoners. The city vanished from their view, and Nix suffered the burn predicted on their payment. They return to Whispermarket to find the stranger. Meanwhile nobody in their city can finish a funeral."],
	"briefing": ["Przetrwaj trzy fale i zachowaj złoto w skarbcu schronienia. Pierwszy upadek goblińskiego najeźdźcy lub obrońcy w danej fali uruchamia dwusekundowy powrót. Maksymalne PŻ spadają do 60%; najeźdźcy mają też 80% dotychczasowego tempa i 70% pojemności. Drugi upadek wyłącza z tej fali. Łup pozostaje przy wstającym najeźdźcy. Zasada dotyczy obu armii. Ocalały obrońca może wrócić ponownie w następnej fali i znów osłabnąć.", "Survive three waves and keep gold in the refuge vault. A goblin raider's or defender's first fall in each wave begins a two-second return. Maximum HP falls to 60%; raiders also retain 80% of their previous speed and 70% of their capacity. A second fall removes them from that wave. A rising raider keeps carried loot. The rule affects both armies. A surviving defender can rise again next wave and weaken again."],
	"intro": ["""W Szeptowisku śmierć miała własny zawód. Nosiciele zamykali oczy, rozplątywacze oddawali rodzinie imię, a Nix naprawiała mechanizmy dzwonów. Teraz nosiciele siedzą na pustych marach. Dzwony milczą, bo nikt nie potrafi ogłosić końca.

Rikk: Uwolniliśmy kogoś, kto zamykał drogę zmarłym. Dlaczego wracają tutaj?
Nix: Nie wiem jeszcze, czy uwolniliśmy więźnia, czy zabraliśmy strażnika. Kamień jest pusty, ale jego węzeł ciągnie do naszych imion. Daj mi czas, żebym go odczytała.

Kobieta przy warsztacie tuli męża, który od miesięcy chciał umrzeć. On pamięta ból i nie pamięta jej twarzy. Kilka domów dalej strażnicy przestają powstrzymywać tłum. Żaden rozkaz nie tłumaczy, jak bronić miasta przed ludźmi, którzy nie mogą go opuścić nawet przez śmierć.

Nix: Zabezpiecz trzy drogi do schronienia. Tam są chorzy i dzieci. Wśród napastników są ich krewni. Ciało podnosi się po pierwszym upadku, ale nie odzyskuje sił. Kolejny upadek odbiera mu możliwość walki.
Rikk: A nasi?
Nix: Tak samo. Ta nić nie rozpoznaje sztandarów.

Rikk kładzie dwie monety od nieznajomej przy pustym kamieniu. Na odwrocie jednej widzi siebie stojącego obok Nix. Jego twarz jest jeszcze widoczna. Miejsce na imię wygląda, jakby nikt nigdy nie przyłożył do niego matrycy.

Rikk: Odnajdziemy ją. Najpierw osłoń schronienie. Nie pozwolę, żeby ten kondukt przeszedł przez następny dom.""", """In Whispermarket, death had its own professions. Bearers closed the eyes, unweavers returned a name to the family, and Nix repaired the bells. Now the bearers sit upon empty biers. The bells are silent because nobody can announce an ending.

Rikk: We freed someone who was blocking the dead. Why are they coming back here?
Nix: I do not yet know whether we freed a prisoner or removed a keeper. The stone is empty, but its knot pulls at our names. Give me time to read it.

A woman beside the workshop holds her husband, who has wanted to die for months. He remembers pain and cannot remember her face. A few houses away, guards stop holding back the crowd. No order explains how to defend a city from people who cannot leave it even through death.

Nix: Secure the three roads to the refuge. The sick and children are there. Some attackers are their relatives. A body rises after its first fall, but strength does not return. The next fall leaves it unable to fight.
Rikk: Our people too?
Nix: The same. This thread does not recognise banners.

Rikk sets the stranger's two coins beside the empty stone. On the reverse of one he sees himself standing beside Nix. His face is still visible. The space for his name looks as though no die has ever touched it.

Rikk: We will find her. Protect the refuge first. I will not let this procession pass through another home."""],
	"mid": ["""Nix: Wracają słabsi. Znika nie tylko siła ciała. Za każdym razem kamień gubi część wzoru. Ten człowiek znał swoje imię przed pierwszym upadkiem. Teraz odpowiada na każde.

Rikk: Powiedziała, że uwolnimy tysiące dusz. Słyszałem je. Nie wymyśliłem tego, żeby wziąć zapłatę.
Nix: Wierzę ci. Prawda w umowie nie gwarantuje, że zapisano w niej wszystko. Ktoś przemilczał, do czego był przywiązany drugi koniec nici.

Z ulicy dobiega prośba o otwarcie bramy. Nie wiadomo, czy woła ktoś szukający schronienia, czy ktoś, kto pamięta tylko tę jedną drogę. Rikk nie odwraca się do monet. Po raz pierwszy musi wybrać, na co patrzeć, bez podpowiedzi jutra.""", """Nix: They return weaker. It is not only bodily strength. Each time the stone loses part of the pattern. That man knew his name before his first fall. Now he answers to every name.

Rikk: She said we would free thousands of souls. I heard them. I did not invent that to take the payment.
Nix: I believe you. A truth in a contract does not mean the whole contract was written. Someone left out what the thread's other end was tied to.

From the street comes a plea to open the gate. They cannot tell whether it is someone seeking refuge or someone who remembers only that one road. Rikk does not turn towards the coins. For the first time he must choose where to look without tomorrow's advice."""],
	"outro": ["""Trzeci napór ustaje. Schronienie stoi. Ci, których trzeba było odsunąć od bramy, nadal oddychają pod opieką nosicieli. Żaden z nich nie pyta o zdobyte złoto. Pytają, czy jutro ból zacznie się od nowa.

Nix: Znalazłam drugi koniec. Nie wiedzie do grobu. Wiedzie na Targ Utraconych Imion. Ktoś sprzedał tam nasze prawo do końca, a węzeł Vargheim tylko trzymał rachunek w jednym miejscu.
Rikk: Można go odkupić?
Nix: Pewnie. Pytanie, czym sprzedawca nazwie zapłatę.

Rikk odwraca przyszłą monetę. Twarz obok Nix jest teraz mniej wyraźna. Zakrywa ją kciukiem, zanim przyjaciółka spojrzy. Nie chce, żeby kolejna rzecz znaleziona w jego kieszeni powiedziała jej, co ma stracić.

Przy wyjściu Nix naprawia mały dzwon. Zawiesza go bez sznura. «Kiedy będziemy wiedzieli, dla kogo ma zabrzmieć, wrócimy» — mówi. Rikk bierze pusty kamień. Tym razem idzie na targ oddać coś, czego nikt nie powinien był móc kupić.

ZŁODZIEJE PRZEZNACZENIA • CIĄG DALSZY NASTĄPI""", """The third assault ends. The refuge stands. Those who had to be pushed back from its gate are still breathing in the bearers' care. Nobody asks how much gold was won. They ask whether tomorrow the pain begins again.

Nix: I found the other end. It does not lead to a grave. It leads to the Market of Lost Names. Someone sold our right to an ending there. The Vargheim knot merely kept the account in one place.
Rikk: Can we buy it back?
Nix: Probably. The question is what the seller will call payment.

Rikk turns over the future coin. The face beside Nix is less distinct now. He covers it with his thumb before his friend can look. He does not want another thing found in his pocket to tell her what she must lose.

At the exit Nix repairs a little bell and hangs it without a rope. 'When we know whom it should ring for, we will return,' she says. Rikk takes the empty stone. This time he goes to the market to give back something nobody should have been able to buy.

THIEVES OF FATE • TO BE CONTINUED"""]}
]
