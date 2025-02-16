# Guida all'uso di Podman con httpd

## 1. Scaricare l'immagine HTTPD
Per ottenere l'immagine di Apache HTTPD basata su UBI8:
```sh
podman pull registry.access.redhat.com/ubi8/httpd-24:latest
```

## 2. Eseguire il container HTTPD temporaneamente
Avvia il container e rimuovilo al termine dell'esecuzione:
```sh
podman run --rm --name httpd httpd-24
```

## 3. Verificare i container in esecuzione
Mostra l'elenco dei container attualmente attivi:
```sh
podman ps
```

## 4. Aprire Podman Desktop
Se hai installato Podman Desktop, puoi utilizzarlo per gestire i container graficamente.

## 5. Eseguire HTTPD esponendo la porta 8080
Avvia il container esponendo la porta 8080 per accedere al server da fuori:
```sh
podman run --rm --name httpd -p 8080:8080 httpd-24
```
Ora puoi accedere alla pagina di default del server HTTPD da una workstation tramite:
```
http://localhost:8080
```

## 6. Eseguire HTTPD in modalità "detached"
Avvia il container in background (detached mode) esponendo la porta 8080:
```sh
podman run -d --rm --name httpd -p 8080:8080 httpd-24
```

## 7. Arrestare il container HTTPD
Per fermare il container HTTPD in esecuzione:
```sh
podman stop httpd
```

## 8. Visualizzare le immagini disponibili
Elenca le immagini presenti nel sistema:
```sh
podman images
