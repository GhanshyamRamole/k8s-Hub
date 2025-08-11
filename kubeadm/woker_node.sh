#!/bin/bash
# Kubernetes Worker Node Setup Script (Idempotent & Robust)
# Usage:
#   1) Pass join command as argument:
#        sudo ./k8s_worker_setup.sh "kubeadm join 1.2.3.4:6443 --token ... --discovery-token-ca-cert-hash sha256:..."
#   2) Or place join command file at /root/k8s_join_command.sh and run:
#        sudo ./k8s_worker_setup.sh
#   3) Or run without args and paste the join command when prompted.
#
# Notes:
#   - Assumes prerequisites (containerd, kubeadm, etc.) are installed.
#   - Will start containerd if stopped.
#   - Logs to /var/log/k8s_worker_setup.log
#
set -euo pipefail
LOG_FILE="/var/log/k8s_worker_setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "========================================================="
echo "🚀 Kubernetes Worker Node Setup Script Started: $(date -Is)"
echo "========================================================="

JOIN_CMD_FILE="/root/k8s_join_command.sh"
KUBEADM_JOIN="${1:-}"

# --- Helpers ---
err_exit() {
  echo "❌ $*" >&2
  exit 1
}

require_root() {
  if [[ $EUID -ne 0 ]]; then
    err_exit "This script must be run as root (sudo)."
  fi
}

command_exists() {
  command -v "$1" &>/dev/null
}

cleanup_old_state() {
  echo "🧹 Cleaning previous kubeadm state (if any)..."
  kubeadm reset -f || true
  rm -rf /etc/cni/net.d /var/lib/cni /var/lib/kubelet /etc/kubernetes || true
  systemctl stop kubelet || true
}

free_ports() {
  # Worker ports that sometimes block join or kubelet start
  local ports=(10250 10255 30000-32767)
  echo "🔍 Checking/killing processes on common K8s ports..."
  for p in 10250 10255 10256 30000 32767 10259 10257 6443 2380; do
    if ss -ltnp "( sport = :$p )" &>/dev/null || lsof -i :"$p" &>/dev/null; then
      echo "⚠️ Port $p is in use — attempting to kill owner processes..."
      lsof -ti :"$p" | xargs -r -n1 kill -9 || true
    fi
  done
}

ensure_containerd() {
  if ! command_exists containerd; then
    err_exit "containerd is not installed. Please run the prerequisites script first."
  fi
  echo "▶ Ensuring containerd is running..."
  systemctl enable --now containerd
  if ! systemctl is-active --quiet containerd; then
    err_exit "containerd failed to start. Check $LOG_FILE and containerd logs."
  fi
  echo "✅ containerd is active."
}

ensure_kubeadm() {
  if ! command_exists kubeadm; then
    err_exit "kubeadm is not installed. Install kubeadm on this node first."
  fi
}

get_join_cmd_interactive() {
  echo
  echo "❗ No join command provided as argument or file."
  echo "Please paste the full 'kubeadm join ...' command (single line), then press ENTER:"
  read -r PASTE_CMD
  if [[ -z "${PASTE_CMD// /}" ]]; then
    err_exit "Empty join command provided. Aborting."
  fi
  echo "$PASTE_CMD"
}

validate_join_cmd() {
  local cmd="$1"
  if [[ "$cmd" != kubeadm\ join* ]]; then
    err_exit "Join command appears invalid. It should start with 'kubeadm join'."
  fi
}

# --- Main ---
require_root
ensure_kubeadm
ensure_containerd
cleanup_old_state
free_ports

# Determine join command source: CLI arg > /root/k8s_join_command.sh > prompt
if [[ -n "$KUBEADM_JOIN" ]]; then
  JOIN_CMD="$KUBEADM_JOIN"
  echo "ℹ️ Using join command from argument."
elif [[ -f "$JOIN_CMD_FILE" ]]; then
  JOIN_CMD="$(<"$JOIN_CMD_FILE")"
  echo "ℹ️ Using join command from $JOIN_CMD_FILE."
else
  JOIN_CMD="$(get_join_cmd_interactive)"
fi

validate_join_cmd "$JOIN_CMD"

# Append CRI socket explicitly if not present (safe default for containerd)
if [[ "$JOIN_CMD" != *"--cri-socket"* ]]; then
  JOIN_CMD="$JOIN_CMD --cri-socket unix:///run/containerd/containerd.sock"
  echo "ℹ️ Appended --cri-socket unix:///run/containerd/containerd.sock to join command."
fi

echo "🔒 Saving join command to /root/k8s_join_command_used.sh"
echo "#!/bin/bash" > /root/k8s_join_command_used.sh
echo "$JOIN_CMD" >> /root/k8s_join_command_used.sh
chmod 700 /root/k8s_join_command_used.sh

# Run the join (with verbose logging). Will exit non-zero on failure.
echo "▶ Running kubeadm join (this may take 30s–2min)..."
set -x
# run join
$JOIN_CMD
set +x

# Start & enable kubelet
echo "▶ Enabling and starting kubelet..."
systemctl enable --now kubelet

# Wait & verify node registers with control plane (best-effort; cannot query master)
echo "⏳ Waiting a short time for kubelet to start..."
sleep 8

echo "========================================================="
echo "✅ Worker node setup finished at: $(date -Is)"
echo "📜 Log file: $LOG_FILE"
echo "🔎 If join failed, inspect kubelet & containerd logs:"
echo "    journalctl -u kubelet -xe"
echo "    journalctl -u containerd -xe"
echo "========================================================="

