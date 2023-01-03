# tutaj taki mały git:
# były linijki takie 36 i 33: var link_fibreCount { Links }, >= 0, integer;   oraz  var demandPath_signalCount { d in Demands, 1..demand_maxPath[d]}, >= 0, integer;
# teraz są takie same ale bez integer

param maxNode, >= 0, integer; 						      	# pierwsze paramtetr - numer ostatniego węzła, maxymalny numer węzła --> liczba węzłów w sieci

set Nodes=1..maxNode;						   		           # zbiór węzłów

set Links;									                     # zbiór łączy
									                            	# żeby stworzyć łącze to musisz podać
param link_nodeA { Links }, in Nodes;						# węzeł początkowy
param link_nodeZ { Links }, in Nodes;						# węzeł końcowy 

param link_fibreMax { Links }, >= 0, default 1000;   # number of modules c(e)	# liczba modułów    liczba fibre, które przekładają się na signale (lambdy)    
param link_fibreUsageCost { Links }, >= 0, default 1; # module cost ksi(e)	# ile kosztuje jeden moduł            ile kosztuje jeden fibre
param link_fibreSignalMax { Links }, >= 0, default 2; # module M		# ile jeden moduł daje capacity       ile jeden fibre daje signal'ów



set Demands;									                            # zbiór demand'ów
param demand_volume { Demands }, >= 0, default 0; 				# h(d), demand_volume to tablica, do której można się odwoływać po numerach jak Demands,

param demand_maxPath { Demands }, >= 0, default 0; 				# liczba scieżek demand'a

set Demand_pathLinks { d in Demands, dp in 1..demand_maxPath[d] } within Links; # zbiór scieżek dla demandów, to jest tak jakby dwuwymiarowa tablica -> ma dwa indeksy ten zbiór
										# pierwsz indeks to numer demanda (d in Demands), drugi indeks to numer ścieżki w demandzie
										# within Links oznacza, że przyjmowane wartości mają znajdować się w numerach Links

# KONIEC PARAMETRÓW I TAKICH TAM, PRZECHODZIMY DO ZADANIA
# DEKLARACJA RÓŻNYCH ZMIENNYCH

# deklaracja zmiennej, która dla każdego demanda, dla każdej jego ścieżki trzyma ile położyliśmy na nią demand volume (czyli Flow Allocation x) funkcja x(d,p)
var demandPath_signalCount { d in Demands, 1..demand_maxPath[d]}, >= 0; 	# flow x(d,p), oni jako signal nazywają jedną lambdę, więc demandPath-signalCount, to będzie "licznik lambd dla danej ścieżki demandu

var link_signalCount { Links }, >= 0; 						# link load l(e,x), licznik lambd (signalów) dla danego łącza (tablica numerowana tak samo jako Links)		
var link_fibreCount { Links }, >= 0;					# y(e, x)         , DDAP:link_size, liczba modułów (fibre), które są potrzebne, aby przenieść wymaganą liczbą lambd (signalów)

var z, integer; # link overload                                                 # zmienna z jest określona dla każdego z Links (funkcja Y(Links,demandPath_signalCount)), a tu jest po prostu jej max wartość

# DEKLARACJA OGRANICZEŃ NA TE ZMIENNE


subject to demand_satisfaction_constraint { d in Demands }:			# dla zmiennej dp w przedziale od 1 do liczby pathów danego demanda, suma x(d,dp) ma być równa volume tego demanda
  sum { dp in 1..demand_maxPath[ d] } demandPath_signalCount[ d, dp ] = demand_volume[ d ];
  
subject to link_signalCount_constraint { l in Links }:				# do zmiennej l(e,x) przypisane jest suma po demandach `d`, po jego pathah `dp` to z tym k to jest chyba zapis ze dany link należy do danej ścieżki dp, jeśli 										# tak, to przypisujemy 1, i jeśli to wyjdzie większe od 0 (czyli jeden) to zliczamy x(d,dp)
										# czyli de facto jest to policzenie zmiennej l(e,x)
  link_signalCount[ l ] = sum { d in Demands, dp in 1..demand_maxPath[ d ]: sum{ k in Demand_pathLinks[ d, dp ]: k = l } 1 > 0 } demandPath_signalCount[ d, dp ];
  
subject to link_fibreCount_constraint { l in Links }: 				# y(e,x) >= l(e,x)/M, definicja DDAP::link_size
  link_fibreCount[ l ] >= link_signalCount[ l] / link_fibreSignalMax[ l] ;

subject to link_signalCount_constraint2 { l in Links }:				# dla kazdego linka liczba na nim modułów razy ile jeden moduł daje capacity plus `z` jest większe od l(e,x) (link load)
										# czyli zauważ, że tutaj naturalnie `z` wyjdzie nam jako link overload, czyli ile za dużo położyliśmy lub ile brakuje
										# jak na plusie to brakuje, na minusie to za dużo mamy niż trzeba
  link_fibreMax[ l ] * link_fibreSignalMax[ l] + z >= sum { d in Demands, dp in 1..demand_maxPath[ d ]: sum{ k in Demand_pathLinks[ d, dp ]: k = l } 1 > 0 } demandPath_signalCount[ d, dp ];
  

### OBJECTIVY ZADANIA	

										# zminimalizuje sumę po linkach ich liczbę modułow razy koszt modułu
minimize capitalCost:
  sum { l in Links } link_fibreCount[ l ] * link_fibreUsageCost[ l];

										# problem mówi, co trzeba zminimalizować lub zmaksymalizować, linijka przerwy, a potem jakich contraintów trzeba się przy tym trzymać
problem ddap:
   capitalCost,
  
   demandPath_signalCount, link_signalCount, link_fibreCount,  
   demand_satisfaction_constraint, link_signalCount_constraint, link_fibreCount_constraint
;

 
minimize maxLinkOverload:
  z;

problem dap:
  maxLinkOverload,
   
  demandPath_signalCount, z,  
  demand_satisfaction_constraint, link_signalCount_constraint2
;
