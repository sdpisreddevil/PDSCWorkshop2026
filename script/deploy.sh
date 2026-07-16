#!/usr/bin/env bash
# Deploy PDSC Workshop 2026 contracts to a specific RPC.
#
# Usage:
#   ./script/deploy.sh registration [rpc]
#   ./script/deploy.sh token [rpc]          # needs WORKSHOP_ADDRESS
#   ./script/deploy.sh badge [rpc]          # needs WORKSHOP_ADDRESS
#   ./script/deploy.sh all [rpc]            # deploys registration + token + badge
#
# Examples:
#   ./script/deploy.sh all http://127.0.0.1:8545
#   ./script/deploy.sh registration sepolia
#   WORKSHOP_ADDRESS=0x... ./script/deploy.sh token http://127.0.0.1:8545

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ -f .env ]]; then
  # shellcheck disable=SC1091
  set -a
  source .env
  set +a
fi

TARGET="${1:-}"
if [[ -z "$TARGET" ]]; then
  echo "Usage: ./script/deploy.sh <registration|token|badge|all> [rpc-url-or-name]"
  exit 1
fi
shift

RPC="${1:-${RPC_URL:-}}"
if [[ -z "$RPC" ]]; then
  echo "Error: no RPC provided. Pass an RPC URL/name or set RPC_URL in .env"
  exit 1
fi

# If first remaining arg is the RPC we used, shift it off for forge extras.
if [[ "${1:-}" == "$RPC" ]]; then
  shift
fi

if [[ -z "${PRIVATE_KEY:-}" ]]; then
  echo "Error: PRIVATE_KEY is not set (add it to .env or export it)."
  exit 1
fi

case "$TARGET" in
  registration|workshop)
    SCRIPT="script/PDSCWorkshop2026.s.sol:PDSCWorkshop2026Script"
    ;;
  token|erc20)
    if [[ -z "${WORKSHOP_ADDRESS:-}" ]]; then
      echo "Error: WORKSHOP_ADDRESS is required to deploy the token."
      exit 1
    fi
    SCRIPT="script/PDSCWorkshopToken.s.sol:PDSCWorkshopTokenScript"
    ;;
  badge|nft|erc721)
    if [[ -z "${WORKSHOP_ADDRESS:-}" ]]; then
      echo "Error: WORKSHOP_ADDRESS is required to deploy the badge."
      exit 1
    fi
    SCRIPT="script/PDSCWorkshopBadge.s.sol:PDSCWorkshopBadgeScript"
    ;;
  all)
    SCRIPT="script/DeployAll.s.sol:DeployAllScript"
    ;;
  *)
    echo "Unknown target: $TARGET"
    echo "Use: registration | token | badge | all"
    exit 1
    ;;
esac

echo "Deploying: $TARGET"
echo "  RPC:    $RPC"
echo "  Script: $SCRIPT"
if [[ -n "${WORKSHOP_ADDRESS:-}" ]]; then
  echo "  Workshop: $WORKSHOP_ADDRESS"
fi
echo ""

forge script "$SCRIPT" \
  --rpc-url "$RPC" \
  --private-key "$PRIVATE_KEY" \
  --broadcast \
  "$@"
