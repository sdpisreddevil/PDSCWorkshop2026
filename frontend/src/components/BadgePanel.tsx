"use client";

import { useEffect } from "react";
import {
  useAccount,
  useReadContract,
  useWaitForTransactionReceipt,
  useWriteContract,
} from "wagmi";
import { contracts } from "@/lib/contracts";
import { ActionCard, PrimaryButton, StatusPill, TxHint } from "./ui";

export function BadgePanel() {
  const { address, isConnected } = useAccount();
  const badge = contracts.badge;

  const { data: hasClaimed, refetch: refetchClaimed } = useReadContract({
    address: badge.address,
    abi: badge.abi,
    functionName: "hasClaimed",
    args: address ? [address] : undefined,
    query: { enabled: Boolean(badge.address && address) },
  });

  const { data: badgeId, refetch: refetchBadge } = useReadContract({
    address: badge.address,
    abi: badge.abi,
    functionName: "badgeOf",
    args: address ? [address] : undefined,
    query: { enabled: Boolean(badge.address && address && hasClaimed) },
  });

  const { writeContract, data: hash, isPending, error, reset } = useWriteContract();
  const { isLoading: confirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  useEffect(() => {
    if (!isSuccess) return;
    void refetchClaimed();
    void refetchBadge();
  }, [isSuccess, refetchClaimed, refetchBadge]);

  const claimed = Boolean(hasClaimed);

  return (
    <ActionCard
      step="03 · ERC-721"
      title="Claim attendance badge"
      description="Mint a unique NFT badge after you register."
      status={<StatusPill ok={claimed} label={claimed ? "Minted" : "No badge"} />}
    >
      <div className="w-full font-mono text-xs text-[var(--muted)]">
        <p>
          Token ID:{" "}
          <span className="text-[var(--ink)]">
            {claimed && typeof badgeId === "bigint" ? badgeId.toString() : "—"}
          </span>
        </p>
      </div>

      

      <PrimaryButton
        disabled={!isConnected || !badge.address || claimed}
        loading={isPending || confirming}
        onClick={() => {
          reset();
          if (!badge.address) return;
          writeContract({
            address: badge.address,
            abi: badge.abi,
            functionName: "claimBadge",
          });
        }}
      >
        {claimed ? "Already claimed" : "Claim badge"}
      </PrimaryButton>

      <TxHint hash={hash} error={error?.message} />
    </ActionCard>
  );
}
