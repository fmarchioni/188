# Troubleshooting a Container Using `nsenter`

How to execute a command available in the Host machine (ss) on the namespace of the container.

## 1. Create a Custom Network

From the workstation, create a new `podman` network:

```sh
podman network create podnet
```

This ensures the container has an isolated network environment for testing.

## 2. Run a Container in the Network

Start a `busybox` container with interactive mode enabled (`-it`), and connect it to the `podnet` network:

```sh
podman run -it --rm --name busy1 --network podnet busybox /bin/sh
```

- `-it`: Runs in interactive mode.
- `--rm`: Removes the container after it stops.
- `--name busy1`: Assigns a name to the container for easier reference.
- `--network podnet`: Connects the container to the custom network `podnet`.
- `busybox /bin/sh`: Starts the container with a shell.


## 3. Check Active Connections in the Container

Inside the container, run:

```sh
ss
```

As you can see, this command is not available in busybox!!
How to execute it with nsenter ???

## 3. Start a Listener Inside the Container

First, let's start a simple netcat (nc) listener on port `8001`:

```sh
nc -l -p 8001
```

This sets up a listening server inside the container, which can be used to test network connectivity.

## 5. Inspect the Container's Network Namespace from the Workstation

To troubleshoot networking issues, you can enter the container's network namespace using `nsenter`.

### a) Retrieve the Container's Process ID (PID)

From the workstation, run:

```sh
PID=$(podman inspect -f '{{.State.Pid}}' busy1)
echo $PID
```

- `podman inspect -f '{{.State.Pid}}' busy1'`: Retrieves the PID of the running container.
- `echo $PID`: Prints the PID for verification.

### b) Enter the Container's Network Namespace

Use `nsenter` to enter the container's network namespace and check socket status:

```sh
sudo nsenter -n -t $PID ss -pant
```

- `sudo nsenter`: Runs the command with elevated privileges.
- `-n`: Joins the network namespace of the target process.
- `-t $PID`: Targets the container’s process ID.
- `ss -pant`: Lists all active network connections with associated process details (`-p`), listening ports (`-a`), and TCP connections (`-t`).

## Conclusion

By using `nsenter`, you can troubleshoot a container's network namespace directly from the workstation. This is useful for debugging connectivity issues, verifying open ports, and inspecting active network connections inside a containerized environment.

Note: Container Processes are visible in the Host's process table. The command podman inspect simply helps us to trace and nsenter to execute commands in it. For example, Host's view of ncat in a Container:

```
frances+  225159  225156  0 08:17 pts/0    00:00:00 /bin/sh
frances+  225166  225159  0 08:17 pts/0    00:00:00 nc -l 8001
```
