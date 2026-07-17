# PDSC Workshop 2026 — Frontend

Next.js dApp for the Foundry workshop contracts: wallet connect, register, and claim ERC-20 / ERC-721 / ERC-1155 rewards.

## Stack

- Next.js (App Router) + TypeScript + Tailwind
- wagmi + viem
- RainbowKit wallet modal

## Setup

```shell
# from repo root — deploy contracts first (Anvil running)
./script/deploy.sh all http://127.0.0.1:8545

cd frontend
cp .env.example .env.local
# paste the four deployed addresses into .env.local

npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

## Wallet tips (local Anvil)

1. Add network: chain id `31337`, RPC `http://127.0.0.1:8545`
2. Import an Anvil private key into MetaMask (first Anvil account is fine for demos)
3. Connect → Join workshop → Claim token / badge / items

## Env vars

| Variable | Purpose |
|----------|---------|
| `NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID` | WalletConnect Cloud project id |
| `NEXT_PUBLIC_RPC_URL` | Anvil / local RPC |
| `NEXT_PUBLIC_WORKSHOP_ADDRESS` | `PDSCWorkshop2026` |
| `NEXT_PUBLIC_TOKEN_ADDRESS` | `PDSCWorkshopToken` |
| `NEXT_PUBLIC_BADGE_ADDRESS` | `PDSCWorkshopBadge` |
| `NEXT_PUBLIC_ITEMS_ADDRESS` | `PDSCWorkshopItems` |
