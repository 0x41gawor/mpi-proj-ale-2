# --------------------------------- P A R A M E T E R S ---------------------------------

param nodeCount, >= 0 integer; # liczba węzłów/nodes w DataCenter
param servicesCount, >= 0 integer; # liczba usług 

set Nodes;      # zbiór węzłów

param node_cpu_capacity {Nodes}, >= 0, integer; # funkcja/tablica/mapa która zwraca CPU dla node od danym id
param node_ram_capacity {Nodes}, >= 0, integer; # funkcja/tablica/mapa która zwraca RAM dla node od danym id

set ContainerImages;

param containerImage_cpu {ContainerImages}, >= 0, integer; #mapa która zwraca CPU dla danego containerImage
param containerImage_ram {ContainerImages}, >= 0, integer; #mapa która zwraca RAM dla danego containerImage
param containerImage_sau {ContainerImages}, >= 0, integer; #mapa która zwraca SAU dla danego containerImage

set InterestMatrix;

param service_SAU {InterestMatrix} >= 0, integer; #mapa która zwraca SAU dla danej usług

# --------------------------------- V A R I A B L E S ---------------------------------

# rozwiązanie; dla każdego node ile jest odpalonych intancji kontenerów dla każdej usługi
var AllocationMatrix{ n in Nodes, 1..servicesCount }, >=0, integer;
# np. AllocationMatrix[1][2] = 4 na node1 dla service2 mamy 4 instancje


# -------------------------------- S U B J E C T   T O --------------------------------

# constraint na to, żeby pokryć zainteresowanie usługami
subject to sau_satisfaction_constraint { s in InterestMatrix }:		
  sum { n in 1..nodeCount } AllocationMatrix[ n, s ] * containerImage_sau[s] >= service_SAU[ s ];

# constraint na to, żeby na żadnym węźle nie przekroczyć CPU
subject to node_cpu_limit { n in Nodes }:	
   sum { s in 1..servicesCount} AllocationMatrix[n, s] * containerImage_cpu[s] <= node_cpu_capacity[n];

# constraint na to, żeby na żadnym węźle nie przekroczyć RAM
subject to node_ram_limit { n in Nodes }:	
   sum { s in 1..servicesCount} AllocationMatrix[n, s] * containerImage_ram[s] <= node_ram_capacity[n];

# -------------------------------- M I N I M I Z E --------------------------------
minimize cpu_usage:
   sum {n in Nodes} (AllocationMatrix[n,1]*containerImage_cpu[1] + AllocationMatrix[n,2]*containerImage_cpu[2] + AllocationMatrix[n,3]*containerImage_cpu[3]);

problem gap:
   cpu_usage,

   AllocationMatrix, sau_satisfaction_constraint, node_cpu_limit, node_ram_limit
;