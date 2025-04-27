# How to connect to Kind cluster from local ?

## Using SSH Port forwarding

1. First, modify the Kind cluster's API server binding:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "0.0.0.0"
  apiServerPort: 6443
```

```bash
kind create cluster --config kind-cluster-config.yaml
```

2. Configure UFW on the Ubuntu server:

```bash
# Allow incoming connections to port 6443
sudo ufw allow 6443/tcp

# Reload UFW to apply changes
sudo ufw reload
```

3. Set up SSH port forwarding:
   On your local PC, create an SSH tunnel to forward the Kubernetes API port:

```bash
ssh -L 6443:127.0.0.1:6443 your_username@your_server_ip
```

4. Copy the kubeconfig from the server to your local machine:
   On the server:

```bash
# Check the current context
kubectl config view

# Copy the contents of the kubeconfig file
cat ~/.kube/config
```

On your local machine:

```bash
# Create or edit your local kubeconfig
mkdir -p ~/.kube
nano ~/.kube/config
```

Paste the contents from the server, but modify the server address to `https://localhost:6443`

5. Verify connection:

```bash
# On your local machine
kubectl cluster-info
kubectl get nodes
```

A few important security notes:

- This method uses SSH tunneling for secure access
- Ensure your SSH connection is secured with key-based authentication
- Consider using a VPN or more advanced network configuration for production environments

## Using NAT configure in `ufw`

1. Set enable ipv4 port_forwarding

```shell
net/ipv4/ip_forward=1
```

2. Add `before.rule`

```shell
# nat Table rules

*nat

:POSTROUTING ACCEPT [0:0]

# Forward traffic from ens37 through ens33.

-A POSTROUTING -s 103.171.90.179.0/24 -o eth0 -j MASQUERADE

-A POSTROUTING -d 192.168.20.14/24 -p tcp --dport 80 -j SNAT --to-source 192.168.20.15

# don't delete the 'COMMIT' line or these nat table rules won't be processed

COMMIT
```

3. Add `after.rule`

```shell
# nat Table rules

*nat

:PREROUTING ACCEPT [0:0]

# Forward traffic from eth1 through eth0.

-A PREROUTING -d 192.168.10.3/24 -p tcp --dport 80 -j DNAT --to-destination 192.168.20.14:80

# don't delete the 'COMMIT' line or these nat table rules won't be processed

COMMIT
```

4. `ufw reload`
