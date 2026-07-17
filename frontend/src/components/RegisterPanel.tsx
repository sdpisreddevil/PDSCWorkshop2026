"use client";

import { useEffect } from "react";
import { formatEther } from "viem";
import {
  useAccount,
  useReadContract,
  useWaitForTransactionReceipt,
  useWriteContract,
} from "wagmi";
import { contracts } from "@/lib/contracts";
import { ActionCard, PrimaryButton, StatusPill, TxHint } from "./ui";

export function RegisterPanel() {
  const { address, isConnected } = useAccount();
  const workshop = contracts.workshop;

  const { data: joiningFee, refetch: refetchFee } = useReadContract({
    address: workshop.address,
    abi: workshop.abi,
    functionName: "joiningFee",
    query: { enabled: Boolean(workshop.address) },
  });

  const { data: usersCount, refetch: refetchCount } = useReadContract({
    address: workshop.address,
    abi: workshop.abi,
    functionName: "usersCount",
    query: { enabled: Boolean(workshop.address) },
  });

  const { data: isRegistered, refetch: refetchRegistered } = useReadContract({
    address: workshop.address,
    abi: workshop.abi,
    functionName: "isRegistered",
    args: address ? [address] : undefined,
    query: { enabled: Boolean(workshop.address && address) },
  });

  const { writeContract, data: hash, isPending, error, reset } = useWriteContract();
  const { isLoading: confirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  useEffect(() => {
    if (!isSuccess) return;
    void refetchRegistered();
    void refetchCount();
    void refetchFee();
  }, [isSuccess, refetchRegistered, refetchCount, refetchFee]);

  const fee = typeof joiningFee === "bigint" ? joiningFee : undefined;
  const registered = Boolean(isRegistered);

  return (
    <ActionCard
      step="01 · Registration"
      title="Join the workshop"
      description="Pay the joining fee to unlock token, badge, and item claims."
      status={
        <StatusPill ok={registered} label={registered ? "Registered" : "Not joined"} />
      }
    >
      <div className="w-full space-y-1 font-mono text-xs text-[var(--muted)]">
        <p>
          Fee:{" "}
          <span className="text-[var(--ink)]">
            {fee !== undefined ? `${formatEther(fee)} ETH` : "—"}
          </span>
        </p>
        <p>
          Attendees:{" "}
          <span className="text-[var(--ink)]">
            {typeof usersCount === "bigint" ? usersCount.toString() : "—"}
          </span>
        </p>
      </div>

      <PrimaryButton
        disabled={!isConnected || !workshop.address || registered || fee === undefined}
        loading={isPending || confirming}
        onClick={() => {
          reset();
          if (!workshop.address || fee === undefined) return;
          writeContract({
            address: workshop.address,
            abi: workshop.abi,
            functionName: "join",
            value: fee,
          });
        }}
      >
        {registered ? "Already joined" : "Join workshop"}
      </PrimaryButton>

      <TxHint hash={hash} error={error?.message} />
    </ActionCard>
  );
}
