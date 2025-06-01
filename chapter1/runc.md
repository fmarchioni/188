# Container Internals: runc, Namespaces e Cgroups

Questa guida fornisce una panoramica rapida e chiara sui concetti fondamentali per comprendere l'esecuzione di container con `runc`, senza usare Docker o Podman.

---

## 🧰 Cos'è `runc`

`runc` è un **low-level container runtime** conforme allo standard [OCI (Open Container Initiative)](https://opencontainers.org/). 
Permette di eseguire un container a partire da un root filesystem (`rootfs`) e un file di configurazione (`config.json`) che descrive il contenitore.

---

## 🧱 Concetti Fondamentali

### 🔒 Namespaces

I **Linux namespaces** isolano differenti aspetti di un processo:

| Namespace       | Isolamento                            |
|-----------------|----------------------------------------|
| `pid`           | Processi                               |
| `net`           | Interfacce e configurazioni di rete    |
| `mnt`           | Mount points (filesystem)              |
| `uts`           | Hostname e domainname                  |
| `ipc`           | Comunicazioni inter-processo           |
| `user`          | Identità utente e privilegi            |
| `cgroup`        | Gruppi di controllo                    |

Quando un container è avviato con `runc`, ciascuno di questi aspetti può essere isolato (e lo è di default nel file `config.json` generato con `runc spec`).

---

### 📊 Cgroups (Control Groups)

I **control groups** permettono di **limitare, monitorare e isolare** l'utilizzo di risorse da parte di un gruppo di processi.

| Risorsa     | Controllabile con Cgroups |
|-------------|----------------------------|
| CPU         | Tempo CPU utilizzato       |
| Memoria     | Limiti di utilizzo RAM     |
| I/O         | Accesso a dischi           |
| PIDs        | Numero massimo di processi|

Con `runc`, le impostazioni dei cgroups si trovano nella sezione `resources` del `config.json`.

---

## 🧪 Prima di Eseguire `start-container.sh`

Assicurati che il tuo sistema supporti:

- **cgroups v2** montati su `/sys/fs/cgroup`
- Kernel Linux moderno (>= 4.x)
- Pacchetti: `runc`, `wget`, `tar`, `sudo`

Puoi verificare i namespaces supportati con:

```bash
lsns
```

E i cgroups montati con:

```bash
mount | grep cgroup
```

---

## 📌 Conclusione

Usare `runc` direttamente ti dà un controllo completo su come viene eseguito un container. È anche il miglior modo per **studiare cosa fa Docker "sotto il cofano"**.

Esempio di Container creato con "runc"

```bash
#!/bin/bash
set -e

CONTAINER_NAME=mycontainer
ROOTFS_DIR=$PWD/$CONTAINER_NAME/rootfs

# 1. Crea cartelle
mkdir -p "$ROOTFS_DIR"
cd "$CONTAINER_NAME"

# 2. Scarica e scompatta Alpine rootfs
if [ ! -f alpine-minirootfs.tar.gz ]; then
  wget -O alpine-minirootfs.tar.gz https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/x86_64/alpine-minirootfs-3.19.1-x86_64.tar.gz
fi
tar -xf alpine-minirootfs.tar.gz -C rootfs

# 3. Crea config.json
runc spec

# 4. Modifica config.json per usare /bin/sh (opzionale: jq o sed)
sed -i 's#"sh"#"sh"#;s#"args": \[.*\]#"args": ["sh"]#' config.json

# 5. Avvia container
echo "Avvio container isolato con runc..."
sudo runc run $CONTAINER_NAME

```

Ti ritroverai in una shell isolata, dentro un container basato su Alpine Linux.

---
 
