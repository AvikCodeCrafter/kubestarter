
#!/bin/bash
# Installer for kind & kubectl (latest stable versions)
# Supports x86_64 and arm64 architectures on Linux
# Simplified: no checksum validation

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
  chmod +x kind
  sudo mv kind "$INSTALL_DIR/"

  kind version
}

# Install latest kubectl
install_kubectl() {
  KUBECTL_VERSION=$(curl -Ls https://dl.k8s.io/release/stable.txt)
  log "Installing kubectl ${KUBECTL_VERSION} for ${KUBE_ARCH}..."

  curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${KUBE_ARCH}/kubectl"
  chmod +x kubectl
  sudo mv kubectl "$INSTALL_DIR/"

  kubectl version --client
}

# Main execution
install_kind
install_kubectl

log "✅ kind & kubectl installation complete."

