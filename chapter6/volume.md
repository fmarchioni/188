# Effetto dell’istruzione `VOLUME` in un Containerfile (Podman)

Questo mini–tutorial mostra **cosa fa realmente l’istruzione `VOLUME`** in un Containerfile e come Podman gestisce la **persistenza dei dati** a seconda di come viene avviato il container.

---

## 🎯 Obiettivo

Capire che:

* `VOLUME` **non copia dati nell’immagine**
* `VOLUME` crea un **volume gestito da Podman** al runtime
* la persistenza del volume dipende dall’uso (o meno) di `--rm`

---

## 📦 Containerfile di partenza

```Dockerfile
FROM registry.access.redhat.com/ubi9/ubi

# Creo un utente applicativo
RUN useradd -u 1001 -r -g 0 appuser

# Dichiaro un volume
VOLUME /tmp

# Cambio utente di default
USER 1001
```

### Cosa dichiara questo file

* l’immagine espone un **punto di mount persistente**: `/tmp`
* il volume non ha nome esplicito → **volume anonimo**
* il container gira come utente non-root (`1001`)

---

## 1️⃣ Build dell’immagine

```bash
podman build -t test .
```

Verifica iniziale:

```bash
podman volume ls
```

👉 Nessun volume presente (la build **non crea volumi**).

---

## 2️⃣ Avvio del container SENZA `--rm`

```bash
podman run test
```

Ora controlla i volumi:

```bash
podman volume ls
```

Esempio output concettuale:

```
DRIVER      VOLUME NAME
local       aa8848271b1d843079c01988f9ad1fd9dc5ac95c3958f45483771c52c32572a5
```

### Spiegazione

* Podman ha creato **automaticamente un volume anonimo**
* Il volume è collegato a `/tmp` nel container
* Il volume **persiste anche se il container termina**

---

## 3️⃣ Rimozione manuale del volume

```bash
podman volume rm -f aa8848271b1d843079c01988f9ad1fd9dc5ac95c3958f45483771c52c32572a5
```

Verifica:

```bash
podman volume ls
```

👉 Nessun volume presente.

---

## 4️⃣ Avvio del container CON `--rm`

```bash
podman run --rm test
```

Controllo finale:

```bash
podman volume ls
```

Risultato:

```
(nessun output)
```

### Spiegazione

* Podman crea comunque il volume per `/tmp`
* Alla terminazione del container:

  * container **rimosso**
  * volume anonimo **rimosso automaticamente**

---


## 📌 Riepilogo rapido

| Caso                   | Volume creato | Volume persistente |
| ---------------------- | ------------- | ------------------ |
| `podman run test`      | ✅             | ✅                  |
| `podman run --rm test` | ✅             | ❌                  |
| Build immagine         | ❌             | ❌                  |

---

## importante

Senza `-v` o `--mount`:

* il volume è **anonimo**
* non è facilmente riutilizzabile
* è pensato per **uso temporaneo o runtime**

Per persistenza controllata:

```bash
podman run -v mytmp:/tmp test
```

---
 
