"use client";

import { ConnectButton } from "@rainbow-me/rainbowkit";

export function Header() {
  return (
    <header className="flex items-center justify-between gap-4 border-b border-[var(--line)] px-5 py-4 md:px-8">
      <div className="min-w-0">
        <p className="font-mono text-[11px] uppercase tracking-[0.22em] text-[var(--muted)]">
          PDSC · Foundry workshop
        </p>
        <h1 className="truncate font-[family-name:var(--font-display)] text-xl font-bold tracking-tight text-[var(--ink)] md:text-2xl">
          Workshop 2026
        </h1>
      </div>
      <ConnectButton showBalance={false} chainStatus="icon" accountStatus="address" />
    </header>
  );
}
