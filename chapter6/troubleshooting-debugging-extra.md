# Esercizio: Aggiunta di un Endpoint per la Lista di Snack

In questo esercizio, lavorerai nel laboratorio `troubleshooting-debugging` per aggiungere un nuovo endpoint all'applicazione Node.js. Questo endpoint permetterà di visualizzare la lista degli snack disponibili.

## Obiettivo

Aggiungere un endpoint `/snacks/list` che restituisce un elenco in formato JSON degli snack disponibili.

---

## Passaggi

### 1. Ferma il contenitore esistente

```bash
podman stop nodebug
```

### 2. Posizionati nella directory del laboratorio

```bash
cd DO188/labs/troubleshooting-debugging/
```

### 3. Modifica il file `index.js`

Apri `index.js` con il tuo editor di testo preferito (es. `vim`, `nano`, `code`).

#### Codice di esempio aggiornato

```js
const express = require("express");
const PORT_NUMBER = 8080;
const app = express();

const available_snacks = ["apple", "cheese", "cracker", "lunchmeat", "olive"];

app.get("/echo", (req, res) => {
  const message = req.query.message;
  res.send(message);
});

app.get("/snacks", (req, res) => {
  const search = req.query.search;
  for (const snack of available_snacks) {
    if (snack === search) {
      res.send(`yes, we have ${search}s!\n`);
      return;
    }
  }
  res.send(`sorry, we don't have any ${search}s :(`);
});

// ✅ Nuovo endpoint per ottenere la lista degli snack disponibili
app.get("/snacks/list", (req, res) => {
  res.json(available_snacks); // Restituisce l'elenco come array JSON
});

app.listen(PORT_NUMBER, "0.0.0.0", () => {
  console.log(`app started on port ${PORT_NUMBER}`);
});
```

> 💡 **Nota**: assicurati che non ci siano errori di sintassi e che l'app venga avviata correttamente.

---

### 4. Avvia nuovamente il contenitore in modalità debug

```bash
podman run -d --rm --name nodebug -p 8080:8080 -p 9229:9229 -v .:/opt/app-root/src:Z nodebug npm run debug
```

---

### 5. Testa il nuovo endpoint

Per verificare che il nuovo endpoint funzioni, esegui il seguente comando:

```bash
curl localhost:8080/snacks/list
```

Dovresti vedere un output simile a:

```json
["apple","cheese","cracker","lunchmeat","olive"]
```

---

## Suggerimenti e Miglioramenti

- Puoi estendere l'elenco degli snack leggendo i dati da un file o un database in futuro.
- Aggiungi dei test automatici per verificare che gli endpoint rispondano correttamente.
- Per una migliore esperienza utente, considera l'aggiunta di una semplice interfaccia frontend.

---

## Fine esercizio

Hai completato l'esercizio con successo se:
- Il contenitore si avvia senza errori
- L'endpoint `/snacks/list` restituisce correttamente la lista degli snack
