"use client";

import { useAccount, useChainId } from "wagmi";
import { contracts, shortAddress } from "@/lib/contracts";
import { Header } from "./Header";
import { RegisterPanel } from "./RegisterPanel";
import { TokenPanel } from "./TokenPanel";
import { BadgePanel } from "./BadgePanel";
import { ItemsPanel } from "./ItemsPanel";

function ConfigBanner() {
  const missing = [
    !contracts.workshop.address && "WORKSHOP",
    !contracts.token.address && "TOKEN",
    !contracts.badge.address && "BADGE",
    !contracts.items.address && "ITEMS",
  ].filter(Boolean);

  if (missing.length === 0) return null;

  return (
    <div className="border border-[var(--warn)]/40 bg-[var(--warn-soft)] px-4 py-3 font-mono text-xs text-[var(--warn)]">
      Missing contract addresses in <code>.env.local</code>: {missing.join(", ")}. Deploy
      with <code>./script/deploy.sh all</code> and paste the addresses.
    </div>
  );
}

export function WorkshopApp() {
  const { isConnected, address } = useAccount();
  const chainId = useChainId();

  return (
    <div className="relative flex min-h-full flex-1 flex-col">
      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(ellipse_at_top,_rgba(200,245,66,0.08),_transparent_55%)]" />
      <div className="pointer-events-none absolute inset-0 opacity-[0.35] [background-image:linear-gradient(var(--line)_1px,transparent_1px),linear-gradient(90deg,var(--line)_1px,transparent_1px)] [background-size:48px_48px]" />

      <div className="relative z-10 flex flex-1 flex-col">
        <Header />

        <main className="mx-auto flex w-full max-w-6xl flex-1 flex-col gap-6 px-5 py-8 md:px-8">
          <section className="max-w-2xl">
            <p className="font-mono text-[11px] uppercase tracking-[0.22em] text-[var(--accent)]">
              Connect · Register · Claim
            </p>
            <h2 className="mt-3 font-[family-name:var(--font-display)] text-3xl font-bold leading-tight tracking-tight text-[var(--ink)] md:text-4xl">
              PDSC Workshop dApp
            </h2>
            <p className="mt-3 max-w-xl text-sm leading-relaxed text-[var(--muted)] md:text-base">
              Connect a wallet, join the on-chain workshop, then claim your ERC-20 reward,
              ERC-721 badge, and ERC-1155 starter pack.
            </p>
            <div className="mt-4 flex flex-wrap gap-3 font-mono text-[11px] text-[var(--muted)]">
              <span className="border border-[var(--line)] px-2 py-1">
                chain {chainId || "—"}
              </span>
              <span className="border border-[var(--line)] px-2 py-1">
                {isConnected ? shortAddress(address) : "wallet disconnected"}
              </span>
            </div>
          </section>

          <ConfigBanner />

          <div className="grid gap-4 md:grid-cols-2">
            <RegisterPanel />
            <TokenPanel />
            <BadgePanel />
            <ItemsPanel />
          </div>
        </main>

        <footer className="border-t border-[var(--line)] px-5 py-4 font-mono text-[11px] text-[var(--muted)] md:px-8">
          Local Anvil default · set{" "}
          <span className="text-[var(--ink)]">NEXT_PUBLIC_*_ADDRESS</span> after deploy
        </footer>
      </div>
    </div>
  );
}
