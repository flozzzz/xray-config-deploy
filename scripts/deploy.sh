#!/usr/bin/env bash
set -euo pipefail

SERVER="${1:-}"
if [[ -z "$SERVER" ]]; then
  echo "Usage: $0 <server-name>" >&2
  exit 1
fi

REPO_DIR="${REPO_DIR:-$HOME/xray-config-deploy}"
XRay_CONFIG_DIR="${XRay_CONFIG_DIR:-/usr/local/etc/xray}"
CURRENT_CONFIG="$XRay_CONFIG_DIR/config.json"
BACKUP_CONFIG="$REPO_DIR/config.json.backup"
TEMPLATE="$REPO_DIR/config/config.${SERVER}.json.template"
TMP_CONFIG="$(mktemp)"

cleanup() {
  rm -f "$TMP_CONFIG"
}
trap cleanup EXIT

if [[ ! -f "$TEMPLATE" ]]; then
  echo "Template not found: $TEMPLATE" >&2
  exit 1
fi

: "${UUID1:?UUID1 is required}"
: "${UUID2:?UUID2 is required}"
: "${UUID3:?UUID3 is required}"
: "${PRIVATE_KEY:?PRIVATE_KEY is required}"
: "${SHORTIDS1:?SHORTIDS1 is required}"

if [[ -n "${UUID4:-}" ]]; then
  :
fi

if [[ -f "$CURRENT_CONFIG" ]]; then
  cp "$CURRENT_CONFIG" "$BACKUP_CONFIG"
fi

if [[ "$SERVER" == "server1" ]]; then
  envsubst '$UUID1 $UUID2 $UUID3 $PRIVATE_KEY $SHORTIDS1 $SHORTIDS2 $SERVER1_PATH' \
    < "$TEMPLATE" > "$TMP_CONFIG"
else
  envsubst '$UUID1 $UUID2 $UUID3 $UUID4 $PRIVATE_KEY $SHORTIDS1' \
    < "$TEMPLATE" > "$TMP_CONFIG"
fi

cp "$TMP_CONFIG" "$CURRENT_CONFIG"

systemctl restart xray
sleep 3

if ! systemctl is-active --quiet xray; then
  echo "xray failed to start"
  systemctl status xray --no-pager -l || true
  journalctl -u xray -n 50 --no-pager || true

  echo "rolling back..."

  if [[ -f "$BACKUP_CONFIG" ]]; then
    cp "$BACKUP_CONFIG" "$CURRENT_CONFIG"
    systemctl restart xray || true
  fi

  exit 1
fi

echo "xray works, deploy successful"
