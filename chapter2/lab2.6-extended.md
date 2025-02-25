# Lab 2.6 esteso

## Task: Modificare le applicazioni `podman-info-cities` e `podman-info-times` per includere Roma

### File da modificare
- `city.go`
- `times.go`

### Modifiche richieste
- Aggiungere Roma (`ROM`) come città con Timezone 2
- Costruire le due applicazioni con i nomi `times` e `cities`
- Avviare le due applicazioni e verificare che l'API fornisca le informazioni per `ROM`

## Soluzione

```sh
lab start basics-exposing

podman network create cities
```

## Modifiche applicative

### `city.go`
```go
var Cities = map[string]*CityInfo{
    "MAD": NewCityInfo("Madrid", 3223000, "Spain"),
    "BKK": NewCityInfo("Bangkok", 10539000, "Thailand"),
    "ROM": NewCityInfo("Roma", 104455500, "Italy"),
    "SAN": NewCityInfo("San Diego", 1415000, "United States of America"),
}
```

### `times.go`
```go
var CityTimezones = map[string]int{
    "MAD": 2,
    "ROM": 2,
    "BKK": 7,
    "SAN": -7,
    "LON": 1,
}
```

## Build e avvio dei container

```sh
cd ~/DO188/labs/basics-exposing

# Costruzione delle immagini
cd /home/student/DO188/labs/basics-exposing/podman-info-times
podman build -t times .

cd /home/student/DO188/labs/basics-exposing/podman-info-cities
podman build -t cities .

# Avvio delle applicazioni sulla rete cities
podman run --name times --network cities -p 8080:8080 -d times 
podman run --name cities --network cities -p 8090:8090 -d -e TIMES_APP_URL=http://times:8080/times cities

# Test 1
podman run --rm --network cities registry.ocp4.example.com:8443/ubi8/ubi-minimal:8.5 curl -s http://times:8080/times/ROM && echo

# Test 2
curl -s http://localhost:8090/cities/ROM | jq
