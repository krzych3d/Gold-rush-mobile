extends RefCounted
## Chapters III–VII. All mechanical values are consumed by campaign_runtime.gd.
const MISSIONS = [
	{"id": "dwarf_coin", "race": 0, "level": 1, "requires": "dwarf_mountain", "map": "dwarves", "enemy": 0, "waves": 4, "target": 240, "gold": 1500, "rule": "debt", "portrait": "borin",
	"title": ["Cena jednej monety", "The Price of One Coin"],
	"objective": ["Dostarcz 240 złota pamięci w 4 falach. Każde wydane 100 złota daje nowym wrogom +8% PŻ (maks. +80%).", "Deliver 240 memory gold within 4 waves. Every 100 gold spent gives new enemies +8% HP (up to +80%)."],
	"setting": ["Mennica Imion • po odkryciu podziemnych komór", "The Mint of Names • after the discovery below"],
	"recap": ["Złoto z komór zachowało głosy zmarłych zużywanych przez kapłanów. Wysokie odsetki Vargheim mają cenę, której nikt nie podawał w rachunkach. Thorgar i Borin docierają do mennicy, aby odnaleźć rejestr przyjętych monet i ustalić, kto podpisał rozkazy.", "The chamber gold preserved the voices of dead people consumed by the priests. Vargheim’s generous interest has a cost no account ever recorded. Thorgar and Borin reach the mint to find the register of name-coins and learn who signed the orders."],
	"briefing": ["Wynieś i dostarcz 240 złota pamięci w najwyżej czterech falach. Każde wydane 100 złota zwiększa PŻ nowo przybywających wrogów o 8%, do maksymalnie 80%. Zakupy nie wzmacniają wstecz już obecnych wrogów. Odsetki nie zwiększają długu i nie liczą się jako dostawa.", "Bring home 240 memory gold within four waves. Every 100 gold spent raises the HP of newly arriving enemies by 8%, up to 80%. Purchases do not strengthen enemies already present. Interest neither increases the debt nor counts as delivered gold."],
	"intro": ["""W piecach mennicy nie pali się węgiel. Ciepło płynie ze złotych naczyń, nad którymi wiszą tabliczki z nazwiskami. Borin rozpoznaje rozwiązania własnego mistrza. Przez lata naprawiał przewody odprowadzające to ciepło do domów; nigdy nie pytał, dlaczego kuźnia nie potrzebuje opału.

Borin: Matryce są jeszcze ciepłe. Ktoś wyszedł tuż przed nami.
Thorgar: Na tej monecie jest moje imię. Myślałem, że imienną monetę dostaje się tylko raz.
Borin: Twoje imię jest na całej partii. A pod nim słowo: poręczyciel.

Głos z prasy: Strażnik przynosi monetę. Korona bierze na siebie dług. Kiedy strażnik odmawia służby, dług wraca do niego. Wydaj złoto, Thorgarze. Za każdą zapłatą dostaniemy nowe ciało.

Z kanałów wychodzą strażnicy z pustymi oczodołami. Ich zbroje zrastają się z kolejnymi warstwami złota. Borin odczytuje na prasie runę z królewskich rachunków: zakup budzi nowego wierzyciela. Zwykłe oszczędzanie nie odblokuje rejestru; trzeba także wynieść zapisane monety.

Thorgar: Przywieźliśmy tu zmarłych. Teraz zabierzemy stąd dowody.
Borin: Wybieraj wydatki, bracie. Potrzebujemy drogi powrotnej, ale każda nowa zapłata uzbroi tych, którzy dopiero nadejdą. Odsetki nie uruchamiają runy. Nikt nie odda nam wydanego złota.""", """The mint’s furnaces burn no coal. Their heat flows from golden vessels labelled with family names. Borin recognises his teacher’s designs. For years he maintained the pipes carrying this warmth into people’s homes; he never asked why the forge needed no fuel.

Borin: The dies are still warm. Someone left just before we arrived.
Thorgar: This coin bears my name. I thought we received only one name-coin in a lifetime.
Borin: Your name is on the entire batch. Under it: guarantor.

Voice from the press: The guard brings a coin. The Crown assumes the debt. When the guard refuses service, the debt returns to him. Spend your gold, Thorgar. Each payment will buy us another body.

Guards with empty eye sockets emerge from the channels. Fresh layers of gold fuse with their armour. Borin reads a rune he knows from royal accounts: a purchase wakes another creditor. Saving alone will not unlock the register; they must also carry its recorded coins away.

Thorgar: We brought the dead here. Now we take the evidence out.
Borin: Choose your purchases, brother. We need a safe return route, but every new payment arms those yet to arrive. Interest does not trigger the rune. Nobody will refund the gold we spend."""],
	"mid": ["""Borin: Znalazłem rozkaz zamknięcia monet po zarazie. Jest tu twoja pieczęć. Mój znak widnieje pod planem przewodów.
Thorgar: Powiedzieli mi, że groby muszą zostać zamknięte. Że inaczej cierpienie wróci do miasta.

Eira: Powiedzieli: będą służyć dalej. Stałam obok ciebie, kiedy czytałeś ten napis na bramie. Spytałam, czy to znaczy na zawsze.
Thorgar: Odpowiedziałem, że to zaszczyt.

Borin: Jest jeszcze dokument z jutrzejszą datą. To twój podpis, ale rozkazu jeszcze nie wydano.
Prasa podejmuje rytm serca. Thorgar odsuwa pióro leżące obok rejestru. Nie jest pewien, czy próbuje uniknąć przyszłości, czy właśnie ją zaczyna.""", """Borin: I found the order sealing the coins after the plague. It bears your seal. My mark is beneath the pipe designs.
Thorgar: They told me the graves had to be sealed. Otherwise the suffering would return to the city.

Eira: They said: they will go on serving. I stood beside you when you read those words on the gate. I asked whether that meant forever.
Thorgar: I told you it was an honour.

Borin: There is another document, dated tomorrow. That is your signature, but the order has not been issued yet.
The press takes up the rhythm of a heartbeat. Thorgar pushes aside the pen beside the register. He does not know whether he is avoiding the future or beginning it."""],
	"outro": ["""W rejestrze obok nazwisk nie zapisano kwot. Zapisano ostatnie słowa. Skryba oznaczał bunt czerwienią, zgodę czernią. Eira ma przy imieniu czerwoną kreskę: «Nie oddawaj mnie królowi».

Thorgar: Pamiętam. Miała gorączkę. Uznałem, że nie wie, co mówi.
Eira: Teraz nie mam gorączki. Rozbij moją monetę, tato. Nie szukaj dla mnie drugiego ciała. Otwórz drogę, żebyśmy mogli odejść.

Borin: Nie rozbijaj jej przy piecu. Moneta jest połączona z resztą skarbca. Trzeba najpierw zdjąć królewską pieczęć. Rejestr wskazuje Salę Przodków. Dziś odbywa się tam uczta pogrzebowa.

Na końcu księgi ktoś dopisał listę żywych, których monety mają trafić do pieców przed zimą. Thorgar rozpoznaje swoich strażników. Zabiera całą księgę. Idzie na ucztę jako człowiek współodpowiedzialny, nie jako ten, który przyszedł oskarżać niewinnych.""", """The register lists no sums beside the names. It records final words. The clerk marked refusal in red, consent in black. A red stroke stands beside Eira’s name: ‘Do not give me to the king.’

Thorgar: I remember. She had a fever. I decided she did not know what she was saying.
Eira: I have no fever now. Break my coin, Father. Do not find me another body. Open the way so we can leave.

Borin: Do not break it beside a furnace. The coin is bound to the rest of the vault. We must lift the royal seal first. The register points to the Ancestors’ Hall. The funeral feast is being held there tonight.

Someone has added a list of living people whose coins must feed the furnaces before winter. Thorgar recognises his guards. He takes the whole book. He goes to the feast bearing his own share of the blame, not as an innocent arriving to accuse."""]},
	{"id": "dwarf_feast", "race": 0, "level": 1, "requires": "dwarf_coin", "map": "dwarves", "enemy": 0, "waves": 4, "target": 0, "gold": 1600, "rule": "boss", "boss_hp": 440, "boss_name": ["Król bez twarzy", "The Faceless King"], "portrait": "thorgar",
	"title": ["Uczta bez twarzy", "The Faceless Feast"],
	"objective": ["Pokonaj Króla bez twarzy w 4 falach. Jego rany pozostają między falami. Poniżej połowy PŻ przyspiesza o 35%.", "Defeat the Faceless King within 4 waves. His wounds persist between waves. Below half HP he moves 35% faster."],
	"setting": ["Sala Przodków • uczta pogrzebowa", "The Ancestors’ Hall • the funeral feast"],
	"recap": ["Rejestr mennicy dowiódł udziału obu braci w działaniu skarbca. Eira poprosiła ojca, by pozwolił jej odejść. Borin ostrzegł, że samo rozbicie monety przy działającej pieczęci niczego nie uwolni. Klucz do pieczęci jest w Sali Przodków, gdzie kapłani przywołują królewskie przysięgi.", "The mint’s register proved that both brothers helped sustain the vault. Eira asked her father to let her go. Borin warned that breaking her coin while the seal remains active will free nobody. The seal’s key lies in the Ancestors’ Hall, where the priests summon the royal oaths."],
	"briefing": ["Pokonaj Króla bez twarzy w najwyżej czterech falach. Zapowiedź w górnym panelu podaje jego linię. Boss zachowuje rany między falami; poniżej połowy PŻ przyspiesza o 35%. Łącz sidła, obrońców i wieżyczki, a po fali sprawdzaj następną trasę. Dostawy złota nie są warunkiem tej misji.", "Defeat the Faceless King within four waves. The upper HUD announces his lane. His wounds persist between waves; below half HP he moves 35% faster. Combine snares, defenders and towers, and check his next route after each wave. Gold deliveries are not required for this mission."],
	"intro": ["""Przy stole stoją zbroje nieżyjących strażników. Wśród nich siedzą żywi kapłani, z twarzami zasłoniętymi złotem. Na miejscu króla nie ma ciała z dzisiejszego pogrzebu. Jest pusta korona i maska, która mówi jednocześnie wieloma głosami.

Borin: Nie wskrzesili pogrzebanego króla. Zebrali tutaj wszystkie przysięgi złożone koronie. Ta postać pilnuje ich zamiast człowieka. Dopóki trwa, pieczęć uzna każde otwarcie skarbca za zdradę.

Król bez twarzy: Oddaliśmy wam ciepłe domy, chleb i odsetki. Wy oddaliście nam imiona. Twoi ludzie przysięgali służyć do końca. Gdzie widzisz krzywdę, dowódco?
Thorgar: W tym, że koniec nigdy nie nadchodzi.
Król bez twarzy: Usłyszałeś to dopiero, gdy przemówiła twoja córka.

Thorgar nie zaprzecza. Kładzie otwarty rejestr na stole; kapłan odsuwa od siebie stronę z imieniem własnej matki. Maska obraca się w stronę bram. Na jednej z trzech dróg zapalają się runy królewskiego orszaku.

Thorgar: Nie zasłużyłem na ich wdzięczność. Ale mogę przestać wykonywać ten rozkaz.
Borin: Utrzymaj go pod ostrzałem. Jeśli odejdzie po fali, wróci inną drogą z tymi samymi ranami. Przy połowie sił rzuci się naprzód. Nie zostawiaj wtedy samotnej wieży.""", """The dead guards’ armour stands around the table. Living priests sit among it with their faces covered in gold. The king’s place holds no body from today’s funeral. There is an empty crown and a mask speaking with many voices at once.

Borin: They have not raised the buried king. They gathered every oath sworn to the Crown. This figure enforces them in his place. While it stands, the seal treats any opening of the vault as treason.

Faceless King: We gave you warm homes, bread and interest. You gave us names. Your people swore to serve until the end. Where is the harm, Commander?
Thorgar: The end never comes.
Faceless King: You heard that only when your own daughter spoke.

Thorgar does not deny it. He lays the open register on the table; a priest pushes away the page bearing his own mother’s name. The mask turns towards the gates. Royal procession runes light up one of the three roads.

Thorgar: I have earned no gratitude from them. But I can stop carrying out this order.
Borin: Keep it under fire. If it withdraws after a wave, it returns along another road with the same wounds. At half strength it will rush forward. Do not leave a tower to face it alone."""],
	"mid": ["""Maska odsuwa się od korony. Pod nią nie ma twarzy. W miękkim złocie odciśnięto małą dłoń, jak na tabliczkach, którymi dzieci podpisują pierwszą przysięgę.

Borin: Zobowiązywali nas, zanim umieliśmy czytać. Moja dłoń też jest w takim rejestrze.
Thorgar: Więc niech usłyszą pierwszą przysięgę, której nie dotrzymam. Moje dziecko nie należy do korony.

Postać wycofuje się z orszakiem. Borin oznacza drogę jej powrotu. Rany nie zniknęły; trzeba przenieść obronę na zapowiadaną linię. Kapłani pozostają przy stole, pilnując własnych monet.""", """The mask lifts away from the crown. There is no face beneath it. A small handprint marks the soft gold, like the tablets children use to sign their first oath.

Borin: They bound us before we could read. My hand is in a register like that too.
Thorgar: Then let them hear the first oath I will not keep. My child does not belong to the Crown.

The figure withdraws with its procession. Borin marks the road it will take back. Its wounds remain; the defence must move to the announced lane. The priests stay at the table, guarding their own coins."""],
	"outro": ["""Maska pęka. Puste zbroje padają, a żywi kapłani nagle odzyskują własne głosy. Najstarszy z nich nie prosi o litość. Wskazuje przewody biegnące spod stołu do miejskich pieców.

Kapłan: Widzisz te domy za oknem? Bez skarbca dzieci zamarzną. Jeśli otworzysz komory, nie wyprodukujemy tyle ciepła i żywności, ile obiecaliśmy rodzinom.
Borin: To ty obiecałeś. Oni zapłacili zmarłymi. A teraz chcesz, żeby zapłacili jeszcze żywymi z twojej listy.

Thorgar: Dostaniecie czas na zwykłe piece i zwykłą pracę. Nie dostaniecie kolejnych imion. Otwórz drogę do królewskiej twierdzy.
Kapłan odwraca wzrok. Straż za drzwiami dostała już inny rozkaz.

Na placu tłum żąda zwrotu monet. Ktoś podnosi rejestr, ktoś inny pochodnię. Zanim Thorgar zdąży przemówić, pierwszy dom zostaje oznaczony jako dom zdrajcy. Zdjęcie jednej pieczęci nie zakończyło wojny. Pozwoliło żywym usłyszeć, o co walczą.""", """The mask breaks. Empty armour falls, and the living priests suddenly recover their own voices. The oldest does not ask for mercy. He points to the pipes running from beneath the table to the city’s furnaces.

Priest: See those houses? Without the vault, children will freeze. If you open the chambers, we cannot provide the heat and food we promised their families.
Borin: You made the promise. They paid with their dead. Now you want the living on your list as well.

Thorgar: You will have time to build ordinary stoves and do ordinary work. You will receive no more names. Open the road to the royal fortress.
The priest looks away. The guards outside have already received another order.

In the square, a crowd demands the coins back. Someone raises the register; someone else raises a torch. Before Thorgar can speak, the first house is marked as a traitor’s home. Lifting one seal has not ended the war. It has let the living hear what they are fighting over."""]},
	{"id": "dwarf_sons", "race": 0, "level": 1, "requires": "dwarf_feast", "map": "dwarves", "enemy": 0, "waves": 4, "target": 3, "gold": 1800, "rule": "escort", "portrait": "borin", "decision": "dwarf_refugees",
	"title": ["Synowie przekleństwa", "Sons of the Curse"],
	"objective": ["Ocal 3 z 4 grup uchodźców. Co falę grupa po 10 s wraca oznaczoną linią; wyślij sabotażystów, by usunęli pułapki. Sam powrót grupy nie daje złota.", "Save 3 of 4 refugee groups. Each wave a group returns along the marked lane after 10 s; send saboteurs to clear its traps. Refugees award no gold."],
	"setting": ["Vargheim • brama wygnanych podczas zamieszek", "Vargheim • the Exiles’ Gate during the riots"],
	"recap": ["Pieczęć królewskich przysiąg została złamana, ale skarbiec nadal więzi dusze. Ujawnienie rejestru podzieliło miasto. Straż tłumi bunt, a buntownicy niszczą zapasy korony. Rodziny uciekają ku tunelom; bracia muszą otworzyć im drogę, zanim ruszą na twierdzę.", "The royal oath-seal is broken, but the vault still holds the souls. The exposed register has divided the city. Guards suppress the revolt; rebels destroy royal supplies. Families flee towards the tunnels. The brothers must clear a way for them before advancing on the fortress."],
	"briefing": ["Ocal co najmniej trzy z czterech grup. Każda fala uruchamia jedną eskortę po 10 sekundach; górny panel wskazuje trasę. Wyślij sabotażystów przed grupą i osłoń powrót. Pułapki rytualne mają więcej ładunków. Błękitny krąg oznacza uchodźców. Ich przybycie zwiększa licznik ocalałych, a nie złoto.", "Save at least three of four groups. Each wave starts one escort after 10 seconds; the upper HUD names its route. Send saboteurs ahead and cover the return. Ritual traps have extra charges. A cyan ring marks refugees. Their arrival increases the saved counter, not your gold."],
	"intro": ["""Przy bramie płoną domy tych, którzy zażądali zwrotu monet. Po drugiej stronie buntownicy podpalają królewskie spichlerze. Z dymu wychodzą ludzie niosący dzieci i tarcze, pod którymi chowają chorych. Oba sztandary każą im zawrócić.

Borin: Za tunelem czekają cztery grupy. Są tam rodziny strażników i tych, których straż aresztowała. Rozdzielili ich przy kapłańskich zaporach.
Thorgar: Dokąd prowadzi droga?
Borin: Do naszej bramy. Ale rytualne pułapki mają dość ładunków, żeby zatrzymać całą grupę. Najpierw musimy oczyścić jej alejkę.

Strażnik: Tam są także rodziny buntowników. Rozkaz zabrania ich wpuszczać.
Thorgar: Pod Kamiennym Brodem nie pytałem, czyja matka ugotowała wam chleb. Dziś też nie zapytam. Osłaniaj tych, którzy wracają.

Borin zaznacza trasę pierwszej grupy błękitnym znakiem. Po rozpoczęciu fali potrzebuje dziesięciu sekund, żeby wyprowadzić ją z kryjówki. To czas dla sabotażystów, by rozbroili drogę. W kolejnej fali uchodźcy wybiorą inną alejkę.

Borin: Nie niosą dla nas złota, bracie. Niosą tylko siebie.
Thorgar: Właśnie dlatego nie wolno mi uznać straconej grupy za koszt zakupu. Otwieraj przejście.""", """Homes whose families demanded their coins back burn beside the gate. Across the square, rebels set fire to royal granaries. People emerge from the smoke carrying children and shields sheltering the sick. Both banners order them to turn back.

Borin: Four groups are waiting beyond the tunnel. Guards’ families and the families of those the guards arrested. The priests’ barriers split them apart.
Thorgar: Where does the road lead?
Borin: To our gate. But the ritual traps have enough charges to stop a whole group. We must clear its lane first.

Guard: Some are rebels’ families. Our orders forbid admitting them.
Thorgar: At Stone Ford I did not ask whose mother baked your bread. I will not ask today. Cover the people coming back.

Borin marks the first group’s route in cyan. Once a wave begins, he needs ten seconds to bring them out of hiding. That gives the saboteurs time to disarm the road. The next wave’s refugees take a different lane.

Borin: They are not bringing us gold, brother. Only themselves.
Thorgar: That is why I cannot count a lost group as the price of a purchase. Open the passage."""],
	"mid": ["""Dowódca straży zdejmuje hełm. Thorgar uczył go kiedyś nosić tarczę; Borin naprawiał mu pierwszą zabawkę. Chłopak nie patrzy na miecz dowódcy. Patrzy na matkę stojącą wśród uchodźców.

Strażnik: Jeśli ich przepuszczę, powieszą ją za pomoc buntownikom. Jeśli zatrzymam, zginie w tunelu. Powiedz mi, jaki rozkaz mam wykonać.
Thorgar: Ten, z którym zdołasz potem stanąć przed nią. Ja zbyt długo wybierałem wygodniejszy.

Borin: Następna grupa ruszy inną drogą. Sprawdź znak w górnym panelu, zanim kupisz oddział. Pułapki nie zapytają, czyje dzieci prowadzą ci ludzie.""", """The guard captain removes his helmet. Thorgar once taught him to hold a shield; Borin repaired his first toy. The young man is not looking at his commander’s sword. He is looking at his mother among the refugees.

Guard: If I let them through, she hangs for helping rebels. If I stop them, she dies in the tunnel. Tell me which order to obey.
Thorgar: The one you can stand before her with afterwards. I chose the convenient order for far too long.

Borin: The next group takes another road. Check the mark in the upper HUD before buying a squad. The traps will not ask whose children these people are leading."""],
	"outro": ["""Ocaleni zbierają się pod osłoną bramy. Brakuje części tobołków, ktoś szuka drugiego buta dziecka. Strażnicy i buntownicy dzielą między siebie wodę. Nikt nie potrafi powiedzieć, kiedy staną się znowu przeciwnikami.

Borin: Możemy otworzyć główną bramę dla wszystkich. Rodziny wejdą jawnie, a strażnicy, którym pomożemy, staną przy naszych liniach. Ale twierdza zobaczy sygnał i król przygotuje silniejszą obronę.

Thorgar: A tunele?
Borin: Przeprowadzę ich po cichu. Twierdza nie dostanie ostrzeżenia. Nikt jednak nie dołączy do twoich oddziałów, bo będziemy musieli pilnować rodzin pod ziemią. Ich też trzeba policzyć i nakarmić.

Chłopak z tarczą czeka obok matki. Thorgar zna oba rachunki. Nie ma w nich rubryki, która zmieściłaby strach ocalałych. Decyzja określi, z jaką armią bracia staną pod królewską twierdzą.""", """The survivors gather beneath the gate’s shelter. Bundles are missing; someone searches for a child’s second shoe. Guards and rebels share their water. Nobody can say when they will become enemies again.

Borin: We can open the main gate to everyone. The families enter openly, and guards whose people we help will stand on our lanes. But the fortress will see the signal. The king will prepare a stronger defence.

Thorgar: And the tunnels?
Borin: I can lead them through quietly. The fortress gets no warning. But nobody can join your squads; we will have to watch the families underground. They still need counting and feeding.

The young man with the shield waits beside his mother. Thorgar knows both accounts. Neither has a column large enough for the survivors’ fear. His decision will shape the army the brothers bring to the royal fortress."""],
	"choices": [
		{"id": "open", "label": ["OTWÓRZ BRAMY", "OPEN THE GATES"], "detail": ["Przyjmij także rodziny strażników. W rozdziale VI król zyska 80 PŻ; ocaleni przyślą obrońcę na każdą linię.", "Admit the guards' families too. In chapter VI the King gains 80 HP; survivors send a defender to every lane."], "ending": ["Bramy zostają otwarte. Strażnik kładzie przed Thorgarem tarczę. «Moja matka jest w środku. Teraz brońmy jej razem».", "The gates open. The guard lays his shield at Thorgar's feet. 'My mother is inside. Let us protect her together.'"]},
		{"id": "hidden", "label": ["UKRYJ ICH W TUNELACH", "HIDE THEM IN THE TUNNELS"], "detail": ["Borin poprowadzi wszystkich pod górą. Rozdział VI: król ma o 60 PŻ mniej; brak dodatkowej straży.", "Borin leads everyone beneath the mountain. Chapter VI: the King has 60 less HP; no additional guards."], "ending": ["Borin znika w tunelu z ostatnią rodziną. «Tym razem policzę wszystkich» — obiecuje. Thorgar pozostaje przy zamkniętej bramie.", "Borin vanishes into the tunnel with the last family. 'This time I will count everyone,' he promises. Thorgar remains at the sealed gate."]}
	]},
	{"id": "dwarf_throne", "race": 0, "level": 1, "requires": "dwarf_sons", "map": "dwarves", "enemy": 0, "waves": 5, "target": 180, "gold": 1700, "rule": "siege", "boss_hp": 500, "boss_name": ["Ostatni król", "The Last King"], "portrait": "thorgar",
	"title": ["Tron z kości", "The Bone Throne"],
	"objective": ["Pokonaj Ostatniego króla i dostarcz 180 złota w 5 falach. Od fali 2 jedna linia drży i spowalnia obie armie o 45%.", "Defeat the Last King and deliver 180 gold within 5 waves. From wave 2 one trembling lane slows both armies by 45%."],
	"setting": ["Królewska twierdza • nad sercem góry", "The royal fortress • above the mountain’s heart"],
	"recap": ["Rodziny opuściły zagrożone tunele. Sposób ich przyjęcia zmienił siły obu stron. Bracia idą do twierdzy po ostatni rejestr przysiąg: tylko on pozwoli otworzyć serce skarbca. Król został pochowany, lecz jego związana z tronem wola nadal wydaje rozkazy.", "The families have escaped the threatened tunnels. How they were received has changed both armies. The brothers go to the fortress for the final ledger of oaths: it is needed to open the vault’s heart. The king was buried, but his will remains bound to the throne and still gives orders."],
	"briefing": ["W najwyżej pięciu falach pokonaj Ostatniego króla i dostarcz 180 złota. Oba cele są wymagane. Rany bossa pozostają między falami. Od drugiej fali drżąca linia spowalnia obie armie o 45%. Wybór z rozdziału V zmienia PŻ króla i liczbę sojuszniczych obrońców; sprawdź aktualny stan w panelu.", "Within five waves, defeat the Last King and deliver 180 gold. Both objectives are required. Boss wounds persist between waves. From wave two, a trembling lane slows both armies by 45%. Your chapter V choice changes the king’s HP and allied defenders; check the current state in the HUD."],
	"intro": ["""Tron opiera się na kościach większych niż filary sali. Na jego stopniach leżą świeże kwiaty z królewskiego pogrzebu. Nad pustą zbroją unosi się twarz zmarłego władcy. Złamali strażnika jego przysiąg; teraz stanęli przed tym, który czerpał z nich władzę.

Thorgar: Dzisiaj odprowadziliśmy cię do grobu.
Ostatni król: Pochowaliście ciało. Nie zwolniliście króla ze służby. Ktoś musi utrzymać to miasto przy życiu.
Borin: Więc nawet tobie obiecano spoczynek, którego nie zamierzano dać.

Ostatni król: W czasie zarazy brakowało rąk do pracy, nie grobów. Odsetki opłaciły zboże. Ciepło uratowało dzieci. Nie możemy zwrócić tego, co już wydaliśmy.
Thorgar: Wydaliście ludzi. Ja ich przynosiłem. Dlatego ten rachunek zakończymy tutaj.

Borin wskazuje główny rejestr pod królewską pieczęcią. Wygrana nad władcą nie wystarczy: zapisane złoto musi wrócić do ich skarbca. Bez niego ostatnia komora pozostanie zamknięta. Pod posadzką rozlega się głuchy wdech.

Borin: Od drugiej fali jedna droga zacznie drżeć. Zwolni wszystkich, także wracających z łupem. Sprawdzaj jej położenie przy każdej zmianie fali. Ludzie, którym pomogliśmy przy bramie, już zdecydowali, jak mogą nas wesprzeć.""", """Bones larger than the hall’s pillars support the throne. Fresh flowers from the royal funeral lie on its steps. The dead ruler’s face hangs above empty armour. The brothers have broken the keeper of his oaths; now they face the one whose power depended on them.

Thorgar: We carried you to your grave today.
Last King: You buried a body. You did not release a king from service. Someone must keep this city alive.
Borin: Then even you were promised a rest they never meant to grant.

Last King: During the plague we lacked working hands, not graves. Interest paid for grain. Warmth saved children. We cannot return what we have already spent.
Thorgar: You spent people. I brought them to you. That is why we end this account here.

Borin points to the main ledger beneath the royal seal. Defeating the ruler will not be enough: the recorded gold must reach their vault. Without it, the last chamber stays locked. A dull inhalation sounds beneath the floor.

Borin: From the second wave, one road will tremble. It slows everyone, including those returning with loot. Check its location at each wave change. The people we helped at the gate have already decided how they can support us."""],
	"mid": ["""Borin: Pieczęć kamienia pamięci otwiera się od wewnątrz. Ktoś jest przy ołtarzu, po drugiej stronie walki!
W dymie błyska gobliński złoty kieł. Drobna dłoń odrywa artefakt od podstawy. Thorgar widzi złodzieja, lecz odgłos pękającej posadzki zagłusza wypowiedziane słowa.

Nie słyszy: «To miało ich uwolnić». Nie widzi też, kto wcześniej rozciął ochronne runy. Kiedy odwraca się ku miastu, w oknach na moment odbija się inne niebo.

Thorgar: Zabrał kamień. Borin, ile mamy czasu?
Borin: Nie wiem. Dokończmy to, po co przyszliśmy. Musimy wynieść rejestr, zanim zniknie droga do serca. Drżenie przesuwa się na następną linię.""", """Borin: The memory stone’s seal is opening from within. Someone is at the altar, beyond the fighting!
A goblin’s golden fang flashes in the smoke. A small hand tears the artefact from its stand. Thorgar sees a thief, but the cracking floor drowns out the words.

He does not hear: ‘This was meant to free them.’ Nor does he see who cut the protective runes beforehand. When he turns towards the city, its windows briefly reflect another sky.

Thorgar: He took the stone. Borin, how long do we have?
Borin: I do not know. Finish what we came for. We need the ledger before the road to the heart disappears. The tremor is moving to the next lane."""],
	"outro": ["""Głos króla urywa się. Z otwartej pieczęci bracia wynoszą zapisane złoto. Wtedy huk przetacza się przez Vargheim. Za oknem zamiast domów zostaje poszarpana pustka. Thorgar szuka płomieni i ludzi na ulicach. Nie widzi ani jednego, ani drugiego.

Thorgar: Ten złodziej… zniszczył miasto.
Borin: Gdzie są gruzy? Gdzie ciała? Bracie, ja nie rozumiem tego, co widzę.
Eira: Zostańcie przy drodze. Reszta jeszcze was pamięta.

Thorgar chce wrócić do placu, ale schody kończą się nad ciemnością. Borin ciągnie go ku przejściu otwartemu przez rejestr. Za nimi ocalały rodziny przy zewnętrznej bramie. Przed nimi pozostało serce skarbca.

Na kamieniu w przejściu znów widać ślad piątego herbu. Uszkodzona płaskorzeźba przedstawia rodzinę; twarze usunięto tak starannie, że nie sposób ich odtworzyć. Thorgar dotyka monety Eiry. Nie wie, czy właśnie stracił kolejne miasto, czy nadal może coś ocalić. Schodzi, bo inna droga już nie istnieje.""", """The king’s voice breaks off. The brothers carry the recorded gold through the open seal. Then a roar rolls across Vargheim. Jagged emptiness replaces the houses beyond the window. Thorgar searches for flames and people in the streets. He sees neither.

Thorgar: That thief… he destroyed the city.
Borin: Where is the rubble? Where are the bodies? Brother, I do not understand what I am seeing.
Eira: Stay on the road. The rest still remembers you.

Thorgar tries to return to the square, but the stairs end above darkness. Borin pulls him towards the passage opened by the ledger. Behind them, families survive at the outer gate. Ahead lies the vault’s heart.

The fifth crest appears again on a stone inside the passage. The damaged carving depicts a family; its faces were removed too carefully to reconstruct. Thorgar touches Eira’s coin. He does not know whether he has lost another city or can still save something. He descends because no other road remains."""]},
	{"id": "dwarf_oath", "race": 0, "level": 1, "requires": "dwarf_throne", "map": "void", "enemy": 3, "waves": 5, "target": 360, "gold": 1800, "rule": "collapse", "boss_hp": 480, "boss_name": ["Echo przysięgi", "The Oath's Echo"], "portrait": "eira", "decision": "dwarf_oath",
	"title": ["Ostatnia przysięga", "The Last Oath"],
	"objective": ["Pokonaj Echo i dostarcz 360 złota w 5 falach. Od fali 2 zapadająca się linia zadaje wszystkim 5 PŻ/s; zmienia się co falę.", "Defeat the Echo and deliver 360 gold within 5 waves. From wave 2 a collapsing lane deals 5 HP/s to everyone; it changes each wave."],
	"setting": ["Serce skarbca • po katastrofie Vargheim", "The vault’s heart • after the Vargheim catastrophe"],
	"recap": ["Król upadł, a kradzież kamienia pamięci zbiegła się ze zniknięciem Vargheim. Thorgar obwinia goblińskiego złodzieja; Borin nie znajduje gruzów. Rejestr otworzył ostatnie przejście. Eira nadal prosi o wolność, lecz coś przemawiające głosem Thorgara obiecuje przywrócić ją do życia.", "The king has fallen, and the theft of the memory stone coincided with Vargheim’s disappearance. Thorgar blames the goblin thief; Borin can find no rubble. The ledger opened the last passage. Eira still asks for freedom, but something using Thorgar’s voice promises to bring her back to life."],
	"briefing": ["Pokonaj Echo i dostarcz 360 złota w najwyżej pięciu falach. Oba cele są wymagane. Od drugiej fali oznaczona, zmieniająca się linia zadaje 5 PŻ na sekundę jednostkom i obrońcom obu stron. Po zwycięstwie wybierzesz los dusz. Decyzja zostanie zapisana; powtórzenie misji jej nie zmieni.", "Defeat the Echo and deliver 360 gold within five waves. Both objectives are required. From wave two, the marked rotating lane deals 5 HP per second to units and defenders on both sides. After victory you choose the souls’ fate. The choice is saved; replaying the mission cannot change it."],
	"intro": ["""Za ostatnimi drzwiami nie ma stosu skarbów. Są tysiące cienkich złotych nici prowadzących do imion wyrytych pod szkłem. Moneta Eiry ogrzewa dłoń Thorgara. Każdy jej puls gasi na chwilę czyjeś imię.

Głos: Jedna moneta. Jedna córka. Twoje przysięgi zaprowadziły cię wystarczająco daleko. Dam jej ciało.
Thorgar: Co stanie się z pozostałymi?
Głos: Ich pamięć stanie się oddechem. Nie zostanie nikt, kto mógłby cię oskarżyć.

Borin: To ta sama obietnica, którą kupiono nasze ciepłe domy. Tylko cenę nazwano inaczej. Jeśli przerwiesz wszystkie więzi, zmarli odejdą. Jeśli skierujesz je do Eiry, odejdą ich imiona. Nie umiem ci obiecać trzeciej drogi.

Złoto zbiera się w postać noszącą zbroję Thorgara. To Echo przysięgi z dnia pogrzebu: obietnicy, że odda wszystko, aby jeszcze raz usłyszeć córkę. Pilnuje nici, które trzeba odzyskać, zanim wolno będzie zdecydować o ich losie.

Thorgar: Najpierw odbierzemy mu prawo do wybierania za nas.
Eira: Pamiętaj tylko, o co prosiłam. To, że mnie słyszysz, nie znaczy, że chcę wrócić.

Pod jedną drogą kruszeją runy. Od drugiej fali zapadająca się linia będzie ranić każdego, kto na niej pozostanie. Borin staje obok brata. Nie odwróci wzroku, nawet jeśli nie zdoła powstrzymać jego decyzji.""", """Beyond the last doors there is no heap of treasure. Thousands of thin golden threads lead to names carved beneath glass. Eira’s coin warms Thorgar’s hand. With each pulse, another name briefly goes dark.

Voice: One coin. One daughter. Your oaths have brought you far enough. I will give her a body.
Thorgar: What happens to the others?
Voice: Their memory becomes breath. Nobody will remain to accuse you.

Borin: That is the promise which bought our warm homes. Only the name of the price has changed. Break every bond and the dead pass on. Turn them towards Eira and their names pass out of existence. I cannot promise you a third road.

Gold gathers into a figure wearing Thorgar’s armour. It is the Echo of the oath he swore at her funeral: to give anything to hear his daughter once more. It guards the threads they must recover before they can decide their fate.

Thorgar: First we take away its right to choose for us.
Eira: Just remember what I asked. Hearing me does not mean I want to return.

Runes crumble beneath one road. From the second wave, a collapsing lane will wound everyone who remains on it. Borin stands beside his brother. He will not look away, even if he cannot prevent his decision."""],
	"mid": ["""Echo zdejmuje hełm. Ma twarz Thorgara z dnia pogrzebu Eiry. Bez gniewu wyciąga dłoń, jak wtedy, gdy przyjmował od kapłana pustą misę po jej monecie.

Echo: Powiedziałeś, że oddasz wszystko. Wreszcie możesz dotrzymać słowa.
Thorgar: Wszystko, co należy do mnie. Przez lata nie pytałem, czyje życie wpisuję do rachunku.
Eira: Tato. Teraz słyszysz także ich.

Borin: Nie skończyliśmy. Wynieś pozostałe nici i osłoń powrót oddziałów. Sama wygrana z Echem nie otworzy więzi. Sprawdzaj zapadającą się linię; ani zmarli, ani żywi nie są na niej bezpieczni.""", """The Echo removes its helmet. It wears Thorgar’s face from the day of Eira’s funeral. Without anger, it offers a hand, as he did when the priest returned the empty bowl that had held her coin.

Echo: You said you would give anything. Now you can keep your word.
Thorgar: Anything that is mine to give. For years I never asked whose life I was entering in the account.
Eira: Father. Now you can hear them too.

Borin: We are not finished. Bring the remaining threads home and cover our squads’ return. Defeating the Echo alone will not open the bonds. Watch the collapsing lane; neither living nor dead are safe upon it."""],
	"outro": ["""Echo rozpada się, a odzyskane monety odpowiadają na dotyk Thorgara. Każda nić może zostać przecięta. Każda może też zostać wpleciona w jedno życie. Po raz pierwszy żadna pieczęć nie narzuca mu rozkazu.

Borin: Jeśli uwolnisz wszystkich, Eira odejdzie razem z nimi. Ocaleni będą musieli przetrwać bez daru skarbca. Pomogę im budować, ale nie obiecam, że nikogo nie stracimy.

Borin: Jeśli ją przywrócisz, zużyjesz pamięć pozostałych. Ich imiona znikną. Nawet my możemy zapomnieć, za kogo zapłaciliśmy. Ona będzie żyła z tą ceną. Nie umiem nazwać tego ratunkiem za ciebie.

Eira: Nie musisz mnie znowu oddawać królowi. Nie musisz też stać się nim dla mnie.
Thorgar patrzy na dłoń brata, na monetę córki i na tysiące imion. To nie jest wybór między pamięcią a zapomnieniem. To wybór, czy ma prawo zdecydować za wszystkich tylko dlatego, że zna jedno imię lepiej od innych.""", """The Echo breaks apart, and the recovered coins answer Thorgar’s touch. Every thread can be cut. Every thread can also be woven into a single life. For the first time no seal gives him an order.

Borin: Free everyone and Eira goes with them. The survivors must live without the vault’s gift. I will help them build, but I cannot promise we will lose nobody.

Borin: Bring her back and you consume the others’ memories. Their names disappear. Even we may forget whom we spent. She will live with that price. I cannot call it a rescue on your behalf.

Eira: You do not have to give me to the king again. You do not have to become him for me either.
Thorgar looks at his brother’s hand, his daughter’s coin and the thousands of names. He must decide whether knowing one name better than the others gives him any right to choose for them all."""],
	"choices": [
		{"id": "release", "label": ["UWOLNIJ WSZYSTKICH", "RELEASE EVERYONE"], "detail": ["Zniszcz skarbiec. Eira i pozostali zmarli odejdą. Krasnoludy stracą dar odsetek w opowieści.", "Destroy the vault. Eira and the other dead pass on. The dwarves lose their gift of interest in the story."], "ending": ["Thorgar zaciska dłoń. Moneta pęka.\n\nEira: Teraz możesz mnie pamiętać.\n\nPo raz pierwszy skarbiec jest cichy. Zimę trzeba będzie przeżyć bez darów przodków. Borin stawia przy pustej bramie zwykły piec.\n\nO świcie Thorgar nie słyszy dzwoneczka. To boli bardziej niż krzyk. I właśnie dlatego wie, że oddał jej wolność.\n\nDZIEDZICTWO KRWI • KONIEC", "Thorgar closes his hand. The coin breaks.\n\nEira: Now you may remember me.\n\nFor the first time the vault is silent. They must survive winter without ancestral gifts. Borin builds an ordinary stove by the empty gate.\n\nAt dawn Thorgar cannot hear the little bell. It hurts more than the screaming. That is how he knows he has set her free.\n\nLEGACY OF BLOOD • END"]},
		{"id": "restore", "label": ["PRZYWRÓĆ EIRĘ", "BRING EIRA BACK"], "detail": ["Przywróć córkę kosztem pozostałych dusz. Ich imiona znikną. Eira będzie pamiętać cenę.", "Restore your daughter at the cost of the other souls. Their names vanish. Eira remembers the price."], "ending": ["Eira bierze pierwszy oddech. Tysiące monet stają się gładkie.\n\nBorin nie pamięta, po co przyszedł do skarbca. Thorgar nie pamięta twarzy poległych. Eira pamięta wszystkich.\n\nGdy ojciec wyciąga do niej rękę, pyta: «Który z nich nauczył cię, że tak wygląda miłość?»\n\nNa niebie gaśnie kolejna gwiazda. Tym razem Thorgar tego nie zauważa.\n\nDZIEDZICTWO KRWI • KONIEC", "Eira takes her first breath. Thousands of coins turn smooth.\n\nBorin forgets why he came to the vault. Thorgar forgets the faces of the fallen. Eira remembers every one.\n\nWhen her father reaches for her, she asks: 'Which of them taught you that this is what love looks like?'\n\nAnother star disappears. This time Thorgar does not notice.\n\nLEGACY OF BLOOD • END"]}
	]}
]
