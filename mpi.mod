param nodeCount, >= 0 integer; # liczba węzłów/nodes w DataCenter
param servicesCount, >= 0 integer; # liczba usług 

set Nodes;      # zbiór węzłów

param node_cpu {Nodes}, >= 0, integer; # funkcja/tablica/mapa która zwraca CPU dla node od danym id
param node_ram {Nodes}, >= 0, integer; # funkcja/tablica/mapa która zwraca RAM dla node od danym id

set ContainerImages;

param containerImage_cpu {ContainerImages}, >= 0, integer; #mapa która zwraca CPU dla danego containerImage
param containerImage_ram {ContainerImages}, >= 0, integer; #mapa która zwraca RAM dla danego containerImage
param containerImage_sau {ContainerImages}, >= 0, integer; #mapa która zwraca SAU dla danego containerImage

set InterestMatrix;

param service_SAU {InterestMatrix} >= 0, integer; #mapa która zwraca SAU dla danej usług

# rozwiązanie; dla każdego node ile jest odpalonych intancji kontenerów dla każdej usługi
var AllocationMatrix{ n in Nodes, 1..servicesCount }, >=0;
# np. AllocationMatrix[1][2] = 4 na node1 dla service2 mamy 4 instancje

# # to juz som kryteria oceny rozwiązania
var node_cpu_load {Nodes}, >=0, integer;  # ile CPU na tym node jest zajęte
var node_ram_load {Nodes}, >=0, integer;  # ile RAM na tym node jest zajęte
var node_load {Nodes}, >=0;               # mean(node_cpu_load/node_cpu, node_ram_load/node_ram)

# C O N S T R A I N T Y

# constraint na to, żeby pokryć zainteresowanie usługami
subject to sau_satisfaction_constraint { s in InterestMatrix }:		
  sum { n in 1..nodeCount } AllocationMatrix[ n, s ] * containerImage_sau[s] >= service_SAU[ s ];

# constraint na to, żeby na żadnym węźle nie przekroczyć CPU
subject to node_cpu_limit { n in Nodes }:	
   sum { s in 1..servicesCount} AllocationMatrix[n, s] * containerImage_cpu[s] <= node_cpu[n];

# constraint na to, żeby na żadnym węźle nie przekroczyć RAM
subject to node_ram_limit { n in Nodes }:	
   sum { s in 1..servicesCount} AllocationMatrix[n, s] * containerImage_ram[s] <= node_ram[n];
