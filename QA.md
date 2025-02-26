# Come posso proseguire nella build di Podman in caso di errori ?

In caso di errori (es. files mancanti) la build di un'immagine si interrompe.
Esiste un workaround che consiste nel mettere una istruzione in OR in aggiunta al comando che fallisce.
Esempio:

```Containerfile
FROM        registry.redhat.io/ubi8/ubi:8.6  
LABEL       description="This is a custom httpd container image"  
RUN         yum install -y httpd  
EXPOSE      80  
ENV         LogLevel "info"  
ADD         http://someserver.com/filename.pdf /var/www/html  || true
COPY        ./src/   /var/www/html/  
USER        apache  
ENTRYPOINT  ["/usr/sbin/httpd"] 
CMD         ["-D", "FOREGROUND"]
```

In questo caso, anche se l'istruzione ADD fallisce nel recupero del filename.pdf, la build continua poichè l'istruzione
è in OR con il booleano true


# Quali sono i files di configurazione della Network di Podman ?

Podman supporta due diversi backend per la gestione della rete dei container:

1. **CNI (Container Network Interface)** - Storicamente il metodo predefinito per la gestione delle reti in Podman.
2. **Netavark** - Un nuovo backend più integrato con Podman, introdotto per migliorare le performance e la sicurezza.

Di seguito sono spiegati i file di configurazione per entrambi i sistemi e come personalizzare il range IP della rete utilizzata da Podman.

---

## Configurazione della rete con CNI

Quando Podman utilizza **CNI**, le configurazioni della rete si trovano nei seguenti percorsi:

- **Rootful (eseguito come root)**: `/etc/cni/net.d/`
- **Rootless (eseguito come utente normale)**: `~/.config/cni/net.d/`

### Modifica del file di configurazione della rete

Per modificare il range IP assegnato ai container, bisogna modificare il file di rete esistente (solitamente `87-podman-bridge.conflist`) o crearne uno nuovo.

#### Esempio di configurazione per CNI con subnet personalizzata

```json
{
    "cniVersion": "0.4.0",
    "name": "custom-podman-network",
    "plugins": [
        {
            "type": "bridge",
            "bridge": "cni-podman0",
            "isGateway": true,
            "ipMasq": true,
            "ipam": {
                "type": "host-local",
                "ranges": [
                    [
                        {
                            "subnet": "192.168.100.0/24",
                            "rangeStart": "192.168.100.100",
                            "rangeEnd": "192.168.100.200"
                        }
                    ]
                ],
                "routes": [
                    { "dst": "0.0.0.0/0" }
                ]
            }
        },
        {
            "type": "portmap",
            "capabilities": { "portMappings": true }
        }
    ]
}
```

Dopo aver creato/modificato il file, riavvia Podman:
```bash
systemctl restart podman
```

Se usi **rootless**, puoi eseguire:
```bash
podman system reset  # (Attenzione: questo resetta anche altri dati!)
```

---

## Configurazione della rete con Netavark

Se Podman è configurato per usare **Netavark** invece di CNI, i file di configurazione si trovano nei seguenti percorsi:

- **Rootful**: `/etc/containers/networks/`
- **Rootless**: `~/.config/containers/networks/`

Puoi definire le reti in formato JSON.

### Esempio di configurazione per Netavark con subnet personalizzata

Salva il file in `/etc/containers/networks/custom-net.json` o `~/.config/containers/networks/custom-net.json`:

```json
{
    "name": "custom-net",
    "id": "d34db33f-0000-0000-0000-000000000000",
    "driver": "bridge",
    "network_interface": "podman0",
    "subnets": [
        {
            "subnet": "192.168.200.0/24",
            "gateway": "192.168.200.1"
        }
    ],
    "dns_enabled": true,
    "internal": false,
    "ipv6_enabled": false
}
```

Dopo aver salvato il file, riavvia Podman per applicare la configurazione:
```bash
systemctl restart podman
```

Puoi anche verificare la rete con:
```bash
podman network ls
```

e per ispezionarla:
```bash
podman network inspect custom-net
```

---

## Creazione di una rete personalizzata con Podman CLI

Se non vuoi modificare i file manualmente, puoi creare una rete personalizzata direttamente da CLI con:

```bash
podman network create \
  --subnet=192.168.100.0/24 \
  --gateway=192.168.100.1 \
  custom-net
```

E poi eseguire un container su questa rete:
```bash
podman run --rm -dt --network custom-net --name test-container nginx
```

## Riassunto:

- **Se usi CNI**, modifica i file in `/etc/cni/net.d/` o `~/.config/cni/net.d/`.
- **Se usi Netavark**, configura le reti in `/etc/containers/networks/` o `~/.config/containers/networks/`.
- **Puoi anche creare le reti con il comando `podman network create` senza modificare i file manualmente.**

