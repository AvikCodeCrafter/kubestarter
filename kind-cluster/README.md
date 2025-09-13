# KIND Cluster Setup Guide

## 0. Update Linux and Install Docker

```bash
sudo apt-get update -y
sudo apt-get install docker.io -y
sudo systemctl enable docker
sudo systemctl start docker

```
## 1. Installing KIND and kubectl
Install KIND and kubectl using the provided script:
```bash

#!/bin/bash
# Production-ready installer for kind & kubectl (latest stable versions)
# Supports x86_64 and arm64 architectures on Linux
# Includes error handling and checksum validation

set -euo pipefail

INSTALL_DIR="/usr/local/bin"

log() {
  echo -e "\033[1;32m[INFO]\033[0m $1"
}

err() {
  echo -e "\033[1;31m[ERROR]\033[0m $1" >&2
  exit 1
}

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
  x86_64)   KIND_ARCH="amd64"; KUBE_ARCH="amd64" ;;
  aarch64)  KIND_ARCH="arm64"; KUBE_ARCH="arm64" ;;
  *)        err "Unsupported architecture: $ARCH" ;;
esac

# Install latest kind
install_kind() {
  KIND_VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | jq -r .tag_name)
  log "Installing kind ${KIND_VERSION} for ${KIND_ARCH}..."

  curl -Lo kind "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-${KIND_ARCH}"
  curl -Lo kind.sha256 "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-${KIND_ARCH}.sha256sum"

  # Validate checksum
  echo "$(cat kind.sha256)  kind" | sha256sum --check || err "kind checksum validation failed!"

  chmod +x kind
  sudo mv kind "$INSTALL_DIR/"
  rm -f kind.sha256

  kind version
}


# Install latest kubectl
install_kubectl() {
  KUBECTL_VERSION=$(curl -Ls https://dl.k8s.io/release/stable.txt)
  log "Installing kubectl ${KUBECTL_VERSION} for ${KUBE_ARCH}..."

  curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${KUBE_ARCH}/kubectl"
  curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${KUBE_ARCH}/kubectl.sha256"

  echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check || err "kubectl checksum validation failed!"

  chmod +x kubectl
  sudo mv kubectl "$INSTALL_DIR/"
  rm -f kubectl.sha256

  kubectl version --client
}

# Main execution
install_kind
install_kubectl

log "✅ kind & kubectl installation complete."

```

#Make it executable and run it

```bash
chmod +x install-kind-kubectl.sh
./install-kind-kubectl.sh

```


# To Give permission to Docker so that it can run without root user 

sudo usermod -aG docker $USER && newgrp docker

## 2. Setting Up the KIND Cluster
Create a kind-cluster-config.yaml file:

```yaml

kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4

nodes:
- role: control-plane
  image: kindest/node:v1.34.0
- role: worker
  image: kindest/node:v1.34.0
- role: worker
  image: kindest/node:v1.34.0
  extraPortMappings:
    - containerPort: 80
      hostPort: 80
      protocol: TCP
    - containerPort: 443
      hostPort: 443
      protocol: TCP
```
Create the cluster using the configuration file:

```bash

kind create cluster --config kind-cluster-config.yaml --name my-kind-cluster
```
Verify the cluster:

```bash
kubectl config get-contexts
kubectl get nodes
kubectl cluster-info
kubectl cluster-info --context kind-kind-cluster
kubectl config use-context kind-kind-cluster
```
## 3. Accessing the Cluster
Use kubectl to interact with the cluster:
```bash

kubectl cluster-info
alias k=kubectl
```


## 4. Setting Up the Kubernetes Dashboard
Deploy the Dashboard
Apply the Kubernetes Dashboard manifest:
```bash

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
```
Create an Admin User
Create a dashboard-admin-user.yml file with the following content:

```yaml

apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
```
Apply the configuration:

```bash

kubectl apply -f dashboard-admin-user.yml
```
Get the Access Token
Retrieve the token for the admin-user:

```bash

kubectl -n kubernetes-dashboard create token admin-user
```
Copy the token for use in the Dashboard login.

Access the Dashboard
Start the Dashboard using kubectl proxy:

```bash

kubectl proxy
```
Open the Dashboard in your browser:

```bash

http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```
Use the token from the previous step to log in.

## 5. Deleting the Cluster
Delete the KIND cluster:
```bash

kind delete cluster --name my-kind-cluster
```

## 6. Notes

Multiple Clusters: KIND supports multiple clusters. Use unique --name for each cluster.
Custom Node Images: Specify Kubernetes versions by updating the image in the configuration file.
Ephemeral Clusters: KIND clusters are temporary and will be lost if Docker is restarted.

