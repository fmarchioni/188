# 🔑 Punto chiave  : podman unshare NON si riferisce a un container specifico.

Si riferisce a:
👉 lo user namespace che Podman usa per i container rootless di quell’utente.

---

# 🎯 Obiettivo della demo

Dimostrare che:

> **`podman unshare` e un container rootless vedono il filesystem nello stesso modo**

---

# 0️⃣ Prerequisiti impliciti

* Podman **rootless**
* Utente `student`
* `/etc/subuid` configurato
* Directory host: `/tmp/www-demo`

---

# 1️⃣ Preparazione filesystem sull’host

```bash
mkdir -p /tmp/www-demo
echo "Hello from host" > /tmp/www-demo/index.html
```

Verifica permessi host **reali**:

```bash
ls -l /tmp/www-demo
```

Esempio:

```text
-rw-r--r--. 1 student student 16 index.html
```

---

# 2️⃣ Visione “container-style” con podman unshare

```bash
podman unshare ls -l /tmp/www-demo
```

Output tipico:

```text
-rw-r--r--. 1 root root 16 index.html
```

### Spiegazione (da dire)

> “Vedete?
> Lo stesso file ora è `root:root`.
> È così che lo vedrà **qualsiasi container rootless**.”

---

# 3️⃣ Avvio container UBI8 con bind mount

```bash
podman run --rm -it \
  -v /tmp/www-demo:/var/www/html:Z \
  registry.access.redhat.com/ubi8/ubi \
  /bin/bash
```

---

## 4️⃣ Dentro il container: verifica permessi

```bash
ls -l /var/www/html
```

Output:

```text
-rw-r--r--. 1 root root 16 index.html
```

👉 **identico a `podman unshare`**

---

## 5️⃣ Verifica identità nel container

```bash
id
```

```text
uid=0(root) gid=0(root)
```

Spieghi:

> “Sono root nel container,
> ma questo root **non è root sull’host**.”

---

## 6️⃣ Test pratico (accesso al file)

```bash
cat /var/www/html/index.html
```

✔️ Funziona (permesso di lettura)

```bash
echo "test" >> /var/www/html/index.html
```

❌ **Permission denied**

Spiegazione:

> “Il file è root:root *nel namespace*,
> ma non scrivibile da root-container → perché non è root host.”

---

## 7️⃣ Esci dal container

```bash
exit
```

---

# 🔁 Verifica finale sull’host

```bash
ls -l /tmp/www-demo/index.html
```

Contenuto **invariato**.

---

# 🧠 Messaggio chiave  

> “`podman unshare` è la preview esatta
> di come un bind mount apparirà nel container.”

> “Se non funziona con `unshare`,
> **non funzionerà nel container**.”

---
 
