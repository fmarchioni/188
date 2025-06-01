# Demonstrating Podman Networking Modes: `pasta` vs `bridge`

This document illustrates how Podman containers behave differently when using `pasta` (rootless, isolated) vs `bridge` networks, including both rootless and rootful scenarios.

---

## 🔹 Example 1: Rootless container using `pasta` network (default when no `--net` specified)

### Step 1: Start a container running an HTTP server
```bash
podman run --rm --name web1 -p 8080:8080 registry.access.redhat.com/ubi8/httpd-24:latest
```
This launches `web1` in rootless mode using the default `pasta` network.

### Step 2: Try accessing it from another container
```bash
podman run --rm --name client1 registry.access.redhat.com/ubi8/nginx-120 curl http://web1:8080
```
❌ This fails. Containers running in `pasta` mode are isolated and **cannot reach each other** using names or IPs.

### Step 3: Clean up
```bash
podman stop $(podman ps -q)
```

---

## 🔹 Example 2: Rootless containers using a shared `bridge` network

### Step 1: Create a bridge network
```bash
podman network create my-net
```

### Step 2: Start a container in that network
```bash
podman run --rm -d --net my-net --name web1 registry.access.redhat.com/ubi8/httpd-24:latest
```

### Step 3: Access it from another container on the same network
```bash
podman run --rm --net my-net registry.access.redhat.com/ubi8/httpd-24:latest curl http://web1:8080
```
✅ This works! Containers in the same `bridge` network can communicate using names (DNS) or IP.

### Step 4: Clean up
```bash
podman stop $(podman ps -q)
```

---

## 🔹 Example 3: Rootful containers and `bridge` networking

### Step 1: Start a rootful container with port mapping
```bash
sudo podman run --rm --name web1 -p 8080:8080 registry.access.redhat.com/ubi8/httpd-24:latest
```

### Step 2: Try accessing it by name (will fail)
```bash
sudo podman run --rm --name client1 registry.access.redhat.com/ubi8/httpd-24:latest curl http://web1:8080
```
❌ Name resolution doesn't work across containers by default.

### Step 3: Get the container IP
```bash
sudo podman inspect web1 | grep IPAddress
```

### Step 4: Access using the IP address
```bash
sudo podman run --rm --name client1 registry.access.redhat.com/ubi8/httpd-24:latest curl http://10.88.0.3:8080
```
✅ This works! Rootful containers in `bridge` network can be accessed via their IP address.

---

## ✅ Summary

| Scenario                       | Communication Works? | Notes |
|-------------------------------|-----------------------|-------|
| Rootless + pasta (default)    | ❌ No                 | Isolated network namespace |
| Rootless + bridge             | ✅ Yes                | Custom network with DNS |
| Rootful + bridge              | ✅ (IP only)          | DNS off by default |

