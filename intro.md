# mpi-proj-ale-drugi

## Słowniczek

**centrum danych**

**węzeł** - hardware, komputer, wyposażenie centrum danych, na których można uruchomić VM lub kontener

**kontener** - wiadomka

**usługa** - którą oferuje przedsiębiorstwo (facebook, netflix) za pośrednictwem *centrum danych*, dla zwykłych ludzi za pośrednictwem internetu. Usługą może być jakiś serwer HTTP (netflix/facebook takimi są), serwer FTP, serwer SMTP itp. Czyli generalnie coś gdzie zwykły człowiek wysyła żądanie, a serwer mu odpowiada. 

**Macierz zainteresowań ruchowym** - daną usługą w danej chwili czasowej jest dane zainteresowanie ruchowe wyrażane jako np. liczba żądań na sekundę

**Obraz kontenera (container image)** - wiadomka, charakteryzowany przez usługę, którą realizuje i zużywane zasoby oraz obsługiwany ruch przez jedną instancję Pod

**Pod (Instancja obrazu kontenera)** - wiadomka też

**Zasoby** - np. ilość rdzeniu CPU oraz pamięć RAM wyrażona w GB

## Opis problemu 

Jest centrum danych, a w nim *węzły*. Centrum danych świadczy jakieś *usługi*. Tych usług może być kilka. W danym momencie/danej chwili czasowej na te usługi jest różne zainteresowanie ruchowe. Pararell centrum danych ma zapisane u siebie *obrazy kontenerów*, które te usługi realizują. Każda intancja kontenera (*Pod*) zajmuje określoną część zasobów. *Pody* można uruchamiać na *węzłach*. Każdy *węzeł* ma swoje określone zasoby. Zadaniem centrum danych jest, to aby zapewnić dostępność usługi. Czyli dla każdej usługi musi uruchomiona odpowiednia liczba kontenerów, aby dały one radę pokryć zainteresowanie ruchowe. Z drugiej strony bez sensu jeśli dla danej usługi uruchomiona jest liczba kontenerów, która łącznie daje dużo ponad to niż wskazuje na to zainteresowanie ruchowe usługi. Tu wchodzi optymalizacja sumaryczna. Z trzeciej strony chcemy, aby *węzły* były równo obciążone, bo tak  - dużo jest powodów na to.

### Matematyczny opis problemu ale na przykładzie

#### Definicja kontenerów

Np.

HTTP-service pro2000 instance: 20kSAU 2GBRAM, 4CPU 
FTP-deamon extra instance  : 10kSAU 2GBRAM, 6CPU

> k - kilo
>
> SAU - Simultaneously Active Users

#### INPUT 

- zasoby data center. Definicja *węzłów* i ich *zasobów*.
- macierz zainteresowań. Mówi ile w tym momencie jest SAU na daną usługę.

#### Algorytm

wylicza ile potrzeba instancji kontenerów, żeby zaspokoić chwilowe zainteresowanie na daną usługę następnie tworzy pod'y w odpowiedniej ilość i rozmieszcza je na węzłach
Funkcją celu tego rozmieszczania jest minimalizacja takiej zmiennej:
mean - średnie procentowe wykorzystanie node'ów
var x = Math.Min(Zbiór{dla każdego węzła `i` : |mean - obiążenie(i)|}).

#### Output

Dla każdego węzła powiedziane jest ile instacji kontenerów z danego obrazu jest uruchomione.

## Model

**Usługa**

```Go
type Service struct {
	Id   Int //nazwa nie jest potrzebna tbh, takie zbiory to i tak się same idkują
    SAU  Int // w milionach czy coś
}
```

**Węzeł**

```go
type Node struct {
	Id   Int //nazwa nie jest potrzebna tbh, takie zbiory to i tak się same idkują
    CPU  Int // [liczba procków]
    RAM  Int // [GB]
}
```

**Obraz Kontenera**

```go
type ContainerImage struct {
	ServiceId   Int //wiadomka
    CPU         Int // ile jedna instancja zajmuje procków [liczba procków]
    RAM         Int // ile jedna instancja zajmuje RAM [GB]
    SAU         Int // ile jedna instacja jest w stanie obsłużyć SAU
}
```

**Macierz zainteresowań ruchowych**

```go
type InterestMatrix struct {
	Id   Int       // ID usługi
    SAU  Int       // SAU na usługę
}
```

**OUTPUT**

```go
type AllocationtMatrix struct {
	NodeId             Int         // Id węzła
    ContainerInstances ArrayOfInt  // tablice gdzie indeksami są ID usług a wartościami liczba Pod'ów
}
```

### Przykład

//TODO Wymyśl przykład, opisz słownie, potem zasymuluj algorytm i to wszystko zrzuytuj na model.