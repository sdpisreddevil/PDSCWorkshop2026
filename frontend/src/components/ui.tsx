"use client";

import { type ReactNode } from "react";

export function ActionCard({
  step,
  title,
  description,
  status,
  children,
}: {
  step: string;
  title: string;
  description: string;
  status?: ReactNode;
  children: ReactNode;
}) {
  return (
    <section className="flex flex-col gap-4 border border-[var(--line)] bg-[var(--panel)] p-5 transition-[border-color] hover:border-[var(--line-strong)]">
      <div className="flex items-start justify-between gap-3">
        <div>
          <p className="font-mono text-[11px] uppercase tracking-[0.18em] text-[var(--accent)]">
            {step}
          </p>
          <h2 className="mt-1 font-[family-name:var(--font-display)] text-lg font-semibold text-[var(--ink)]">
            {title}
          </h2>
          <p className="mt-1 text-sm leading-relaxed text-[var(--muted)]">{description}</p>
        </div>
        {status}
      </div>
      <div className="mt-auto flex flex-wrap items-center gap-3">{children}</div>
    </section>
  );
}

export function StatusPill({
  ok,
  label,
}: {
  ok: boolean;
  label: string;
}) {
  return (
    <span
      className={`shrink-0 rounded-sm px-2 py-1 font-mono text-[10px] uppercase tracking-wider ${
        ok
          ? "bg-[var(--accent-soft)] text-[var(--accent)]"
          : "bg-[var(--warn-soft)] text-[var(--warn)]"
      }`}
    >
      {label}
    </span>
  );
}

export function PrimaryButton({
  children,
  disabled,
  onClick,
  loading,
}: {
  children: ReactNode;
  disabled?: boolean;
  onClick?: () => void;
  loading?: boolean;
}) {
  return (
    <button
      type="button"
      disabled={disabled || loading}
      onClick={onClick}
      className="rounded-sm bg-[var(--accent)] px-4 py-2.5 font-mono text-xs font-semibold uppercase tracking-wider text-[var(--bg)] transition enabled:hover:brightness-110 disabled:cursor-not-allowed disabled:opacity-40"
    >
      {loading ? "Confirm in wallet…" : children}
    </button>
  );
}

export function TxHint({ hash, error }: { hash?: string; error?: string | null }) {
  if (!hash && !error) return null;
  return (
    <div className="w-full font-mono text-[11px]">
      {hash ? (
        <p className="truncate text-[var(--muted)]">tx {hash}</p>
      ) : null}
      {error ? <p className="mt-1 text-[var(--warn)]">{error}</p> : null}
    </div>
  );
}
