# Podman Compose e Cleanup con systemd

---

## Podman Compose come unità systemd

Crea il file `/etc/systemd/system/podman-compose@.service`. Assicurati di utilizzare il percorso corretto per il binario `podman-compose` nel tuo ambiente (nell'esempio è `/usr/local/bin`).

```ini
[Unit]
Description=%i service con podman-compose
# Non è necessario collegare questo servizio a docker.service, dato che Podman non utilizza un daemon centrale

[Service]
Type=oneshot
RemainAfterExit=true
WorkingDirectory=/etc/podman/compose/%i
ExecStart=/usr/local/bin/podman-compose up -d --remove-orphans
ExecStop=/usr/local/bin/podman-compose down

[Install]
WantedBy=multi-user.target
```

Posiziona il file di configurazione (ad esempio, podman-compose.yml o il file rinominato opportunamente) nella directory /etc/podman/compose/myservice e avvia il servizio con:

```shell
systemctl start podman-compose@myservice
```
