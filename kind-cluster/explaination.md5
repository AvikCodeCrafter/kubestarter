# 🚀 kind & kubectl Installer

This repository provides a simple Bash script to install the latest versions of **[kind](https://kind.sigs.k8s.io/)** (Kubernetes in Docker) and **[kubectl](https://kubernetes.io/docs/reference/kubectl/)** (the Kubernetes CLI).

The script supports:
- ✅ Linux (x86_64 and arm64)
- ✅ Automatic latest version detection
- ✅ Quick developer setup

---

## 📋 Features
- Detects system architecture (`x86_64` / `arm64`)
- Installs **latest stable releases** of `kind` and `kubectl`
- Places binaries in `/usr/local/bin`
- Prints installed versions for confirmation

⚠️ **Note:** This script skips checksum validation for simplicity.  
For production use, you should add integrity verification.

---

## 🔧 Requirements
- `bash`
- `curl`
- `jq`
- `sudo` privileges (for moving binaries to `/usr/local/bin`)

---

## 📥 Installation

Clone this repository and run the installer:

```bash
git clone https://github.com/your-username/kind-kubectl-installer.git
cd kind-kubectl-installer
chmod +x install.sh
./install.sh
