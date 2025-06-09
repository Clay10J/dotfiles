#!/usr/bin/env bash
set -e

TITLE="SSH key $(hostname)"
# Only run once
if op item list --category SSH_KEY --vault Personal \
   | grep -qF "$TITLE"; then
  exit 0
fi

# Ensure we're signed in
if ! op whoami &>/dev/null; then
  eval "$(op signin)"
fi

# Paths to the keypair
KEY_PRIV="$HOME/.ssh/id_ed25519"
KEY_PUB="$HOME/.ssh/id_ed25519.pub"

# Create a single SSH_KEY item with both fields
op item create \
  --category SSH_KEY \
  --title "$TITLE" \
  --vault Personal \
  --fields \
    privateKey="$(<"$KEY_PRIV")" \
    publicKey="$(<"$KEY_PUB")"

echo "🔐 Stored SSH key in 1Password as '$TITLE'"

