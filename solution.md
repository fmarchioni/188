# 🗝️ Il signor Brando e la chiave SSH impossibile

**Mistero:**  
Come ha fatto il signor Brando ad aggiungere una chiave SSH su un nodo OpenShift,  
nonostante il file system **immutabile** di CoreOS?

---

**Soluzione:**  
La chiave pubblica SSH è stata aggiunta nella sezione  
`spec.config.passwd.users.sshAuthorizedKeys` di un oggetto **MachineConfig**.  
Al successivo aggiornamento del **Machine Config Operator (MCO)**, il nodo ha  
rigenerato la sua configurazione usando **Ignition**, rendendo la chiave parte  
dell'immagine ostree e quindi **persistente e supportata**.

---

## Esempio di MachineConfig

```yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  name: 99-master-ssh
  labels:
    machineconfiguration.openshift.io/role: master   # oppure "worker", a seconda di dove vuoi applicarlo
spec:
  config:
    ignition:
      version: 3.2.0
    passwd:
      users:
        - name: core
          sshAuthorizedKeys:
            - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDf1234567890abcDEFghiJKLmnopQRStuvwXYZ... chiave_pubblica
