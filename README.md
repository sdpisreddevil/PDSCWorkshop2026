# PDSC Workshop 2026 — Sample Project

End-to-end workshop: Foundry smart contracts (registration + ERC-20 / ERC-721 / ERC-1155), deploy scripts, a bash helper, and a Next.js frontend with wallet connection.

---

## Table of contents

1. [Prerequisites](#1-prerequisites)
2. [Create a Foundry project](#2-create-a-foundry-project)
3. [Install dependencies](#3-install-dependencies)
4. [Project layout](#4-project-layout)
5. [Write & understand the contracts](#5-write--understand-the-contracts)
6. [Build & test with Forge](#6-build--test-with-forge)
7. [Configure environment variables](#7-configure-environment-variables)
8. [Run a local chain (Anvil)](#8-run-a-local-chain-anvil)
9. [Deploy with Forge scripts](#9-deploy-with-forge-scripts)
10. [Deploy with the bash helper](#10-deploy-with-the-bash-helper)
11. [Build the Next.js frontend](#11-build-the-nextjs-frontend)
12. [Connect wallet & try the dApp](#12-connect-wallet--try-the-dapp)
13. [Useful Foundry commands](#13-useful-foundry-commands)

---

## 1. Prerequisites

Install these before starting:

| Tool | Purpose | Install |
|------|---------|---------|
| [Foundry](https://book.getfoundry.sh/getting-started/installation) | `forge`, `cast`, `anvil` | `curl -L https://foundry.paradigm.xyz \| bash` then `foundryup` |
| [Node.js](https://nodejs.org/) (v20+) | Frontend | nvm / official installer |
| Git | Submodules & version control | OS package manager |
| MetaMask (or similar) | Wallet for the dApp | Browser extension |

Verify:

```shell
forge --version
anvil --version
node -v
npm -v
```

---

## 2. Create a Foundry project

If you are starting from scratch (this repo already exists — skip if cloning):

```shell
forge init PDSCSampleProject
cd PDSCSampleProject
```

`forge init` creates:

- `src/` — contracts  
- `test/` — Forge tests  
- `script/` — deploy scripts  
- `lib/forge-std` — standard testing library  
- `foundry.toml` — project config  

Clone this workshop repo instead:

```shell
git clone <your-repo-url> PDSCSampleProject
cd PDSCSampleProject
git submodule update --init --recursive
```

---

## 3. Install dependencies

### OpenZeppelin Contracts

```shell
forge install OpenZeppelin/openzeppelin-contracts
```

Ensure `foundry.toml` has remappings and skips dependency tests:

```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc_version = "0.8.27"

remappings = [
    "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
    "forge-std/=lib/forge-std/src/",
]

skip = ["lib/**"]

[rpc_endpoints]
anvil = "http://127.0.0.1:8545"
sepolia = "${SEPOLIA_RPC_URL}"
mainnet = "${MAINNET_RPC_URL}"
```

### Frontend deps (later step)

```shell
cd frontend && npm install && cd ..
```

---

## 4. Project layout

```text
PDSCSampleProject/
├── src/
│   ├── PDSCWorkshop2026.sol      # Registration (join + fee)
│   ├── PDSCWorkshopToken.sol     # ERC-20 reward
│   ├── PDSCWorkshopBadge.sol     # ERC-721 attendance badge
│   └── PDSCWorkshopItems.sol     # ERC-1155 starter pack
├── test/
│   ├── PDSCWorkshop2026.t.sol
│   ├── PDSCWorkshopToken.t.sol
│   ├── PDSCWorkshopBadge.t.sol
│   └── PDSCWorkshopItems.t.sol
├── script/
│   ├── PDSCWorkshop2026.s.sol    # Deploy registration
│   ├── PDSCWorkshopToken.s.sol   # Deploy ERC-20
│   ├── PDSCWorkshopBadge.s.sol   # Deploy ERC-721
│   ├── PDSCWorkshopItems.s.sol   # Deploy ERC-1155
│   ├── DeployAll.s.sol           # Deploy full suite
│   └── deploy.sh                 # Bash helper around forge script
├── frontend/                     # Next.js + wagmi + RainbowKit
├── foundry.toml
├── .env.example
└── README.md
```

---

## 5. Write & understand the contracts

All token contracts read `PDSCWorkshop2026.isRegistered(user)` so only attendees can claim.

| Contract | Standard | Main user action |
|----------|----------|------------------|
| `PDSCWorkshop2026` | Custom | `join()` — pay joining fee (default `0.000001 ETH`) |
| `PDSCWorkshopToken` | ERC-20 | `claimReward()` — one-time PDSC tokens |
| `PDSCWorkshopBadge` | ERC-721 | `claimBadge()` — one attendance NFT |
| `PDSCWorkshopItems` | ERC-1155 | `claimStarterPack()` — pass + swag + certificate |

Admin (Ownable) can update the joining fee, mint extras, and withdraw fees.

---

## 6. Build & test with Forge

```shell
# Compile
forge build

# Run all workshop tests
forge test --match-path 'test/PDSCWorkshop*' -vv

# Single suite
forge test --match-contract PDSCWorkshop2026Test -vv
forge test --match-contract PDSCWorkshopTokenTest -vv
forge test --match-contract PDSCWorkshopBadgeTest -vv
forge test --match-contract PDSCWorkshopItemsTest -vv

# Gas snapshot (optional)
forge snapshot
```

You should see all tests passing before deploying.

---

## 7. Configure environment variables

```shell
cp .env.example .env
```

Edit `.env`:

```env
RPC_URL=http://127.0.0.1:8545

# Anvil account #0 (demo only — never use on mainnet)
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# Optional: set after deploying registration alone
# WORKSHOP_ADDRESS=0x...

# Optional claim size for ERC-20 (wei). Default = 100 ether
# CLAIM_AMOUNT=100000000000000000000

# Optional named RPCs used by foundry.toml
# SEPOLIA_RPC_URL=https://ethereum-sepolia-rpc.publicnode.com
```

`.env` is gitignored. Never commit real private keys.

---

## 8. Run a local chain (Anvil)

Open a dedicated terminal and leave it running:

```shell
anvil
```

Defaults:

- RPC: `http://127.0.0.1:8545`
- Chain ID: `31337`
- Pre-funded accounts printed in the terminal (use account `#0` for demos)

---

## 9. Deploy with Forge scripts

With Anvil running and `.env` configured, you can deploy using `forge script` directly.

### Deploy everything at once

```shell
forge script script/DeployAll.s.sol:DeployAllScript \
  --rpc-url http://127.0.0.1:8545 \
  --private-key $PRIVATE_KEY \
  --broadcast
```

### Deploy one contract at a time

```shell
# 1) Registration
forge script script/PDSCWorkshop2026.s.sol:PDSCWorkshop2026Script \
  --rpc-url http://127.0.0.1:8545 \
  --private-key $PRIVATE_KEY \
  --broadcast

# 2) ERC-20 (needs WORKSHOP_ADDRESS from step 1)
export WORKSHOP_ADDRESS=0x...   # paste from previous logs
forge script script/PDSCWorkshopToken.s.sol:PDSCWorkshopTokenScript \
  --rpc-url http://127.0.0.1:8545 \
  --private-key $PRIVATE_KEY \
  --broadcast

# 3) ERC-721
forge script script/PDSCWorkshopBadge.s.sol:PDSCWorkshopBadgeScript \
  --rpc-url http://127.0.0.1:8545 \
  --private-key $PRIVATE_KEY \
  --broadcast

# 4) ERC-1155
forge script script/PDSCWorkshopItems.s.sol:PDSCWorkshopItemsScript \
  --rpc-url http://127.0.0.1:8545 \
  --private-key $PRIVATE_KEY \
  --broadcast
```

Copy the printed contract addresses — you need them for the frontend.

### Deploy to a named / remote RPC

```shell
# Using foundry.toml [rpc_endpoints] name
forge script script/DeployAll.s.sol:DeployAllScript \
  --rpc-url sepolia \
  --private-key $PRIVATE_KEY \
  --broadcast

# Or any URL
forge script script/DeployAll.s.sol:DeployAllScript \
  --rpc-url https://ethereum-sepolia-rpc.publicnode.com \
  --private-key $PRIVATE_KEY \
  --broadcast
```

---

## 10. Deploy with the bash helper

`script/deploy.sh` wraps the Forge scripts: loads `.env`, checks `PRIVATE_KEY` / `WORKSHOP_ADDRESS`, and passes `--rpc-url` + `--broadcast`.

Make it executable (once):

```shell
chmod +x script/deploy.sh
```

### Usage

```shell
./script/deploy.sh <target> [rpc-url-or-name]
```

| Target | What it deploys | Needs |
|--------|-----------------|-------|
| `registration` | `PDSCWorkshop2026` | `PRIVATE_KEY` |
| `token` | `PDSCWorkshopToken` | `PRIVATE_KEY` + `WORKSHOP_ADDRESS` |
| `badge` | `PDSCWorkshopBadge` | `PRIVATE_KEY` + `WORKSHOP_ADDRESS` |
| `items` | `PDSCWorkshopItems` | `PRIVATE_KEY` + `WORKSHOP_ADDRESS` |
| `all` | Full suite | `PRIVATE_KEY` |

### Examples

```shell
# Full suite on local Anvil
./script/deploy.sh all http://127.0.0.1:8545

# Uses RPC_URL from .env if you omit the second arg
./script/deploy.sh all

# Registration only, then tokens separately
./script/deploy.sh registration http://127.0.0.1:8545
# → copy address into .env as WORKSHOP_ADDRESS=0x...
./script/deploy.sh token http://127.0.0.1:8545
./script/deploy.sh badge http://127.0.0.1:8545
./script/deploy.sh items http://127.0.0.1:8545

# Named endpoint from foundry.toml
./script/deploy.sh all sepolia
```

Save the four addresses from the console output for the next step.

---

## 11. Build the Next.js frontend

The dApp lives in `frontend/` (Next.js App Router, TypeScript, Tailwind, wagmi, RainbowKit).

### Install & configure

```shell
cd frontend
cp .env.example .env.local
```

Edit `frontend/.env.local` with addresses from deploy:

```env
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your_walletconnect_project_id
NEXT_PUBLIC_RPC_URL=http://127.0.0.1:8545

NEXT_PUBLIC_WORKSHOP_ADDRESS=0x...
NEXT_PUBLIC_TOKEN_ADDRESS=0x...
NEXT_PUBLIC_BADGE_ADDRESS=0x...
NEXT_PUBLIC_ITEMS_ADDRESS=0x...
```

Get a free WalletConnect Cloud project id at [cloud.walletconnect.com](https://cloud.walletconnect.com) (injected MetaMask still works for local demos).

### Run

```shell
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

Optional production build:

```shell
npm run build
npm start
```

More frontend detail: [`frontend/README.md`](frontend/README.md).

---

## 12. Connect wallet & try the dApp

1. **Add Anvil to MetaMask**
   - Network name: `Anvil`
   - RPC URL: `http://127.0.0.1:8545`
   - Chain ID: `31337`
   - Currency: `ETH`

2. **Import an Anvil account**  
   Paste a private key from the Anvil terminal (account `#0` is fine for demos).

3. **In the dApp**
   1. Connect wallet  
   2. **Join workshop** (pays joining fee)  
   3. **Claim PDSC tokens** (ERC-20)  
   4. **Claim badge** (ERC-721)  
   5. **Claim starter pack** (ERC-1155)

Flow matches the on-chain rules: register first, then claim each reward once.

---

## 13. Useful Foundry commands

```shell
forge build          # compile
forge test           # tests
forge fmt            # format Solidity
forge snapshot       # gas snapshots
anvil                # local node
cast <subcommand>    # chain / calldata helpers

# Example: read joining fee after deploy
cast call $WORKSHOP_ADDRESS "joiningFee()(uint256)" --rpc-url http://127.0.0.1:8545
```

Docs: [https://book.getfoundry.sh/](https://book.getfoundry.sh/)

---

## Quick start (already cloned)

If this repo is already set up, the shortest path is:

```shell
# Terminal 1
anvil

# Terminal 2
cp .env.example .env   # set PRIVATE_KEY (Anvil #0 is fine locally)
./script/deploy.sh all http://127.0.0.1:8545

# Terminal 3
cd frontend
cp .env.example .env.local   # paste the 4 addresses
npm install && npm run dev
```

Then connect MetaMask to Anvil and walk through join → claim.
