## Esempio di Containerfile con effetto "matrix rain"

Con questo esempio potete avviare un Container che utilizza l'immagine Alpine creando in avvio un effetto "Matrix rain".

Come eseguirlo:

```bash
podman build -t matrix .

podman run --rm -it matrix
```
