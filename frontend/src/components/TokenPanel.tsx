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

export function TokenPanel() {
  const { address: userAddress, isConnected } = useAccount();
  const token = contracts.token;

  console.log("tokenAddress", token.address);
  console.log("userAddress", userAddress);

  const { data: balance, refetch: refetchBalance } = useReadContract({
    address: token.address,
    abi: token.abi,
    functionName: "balanceOf",
    args: userAddress ? [userAddress] : undefined,
    query: { enabled: Boolean(token.address && userAddress) },
  });

  const { data: hasClaimed, refetch: refetchClaimed } = useReadContract({
    address: token.address,
    abi: token.abi,
    functionName: "hasClaimed",
    args: userAddress ? [userAddress] : undefined,
    query: { enabled: Boolean(token.address && userAddress) },
  });

  const { data: claimAmount } = useReadContract({
    address: token.address,
    abi: token.abi,
    functionName: "claimAmount",
    query: { enabled: Boolean(token.address) },
  });

  const { writeContract, data: hash, isPending, error, reset } = useWriteContract();
  const { isLoading: confirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  useEffect(() => {
    if (!isSuccess) return;
    void refetchBalance();
    void refetchClaimed();
  }, [isSuccess, refetchBalance, refetchClaimed]);

  const claimed = Boolean(hasClaimed);

  return (
    <ActionCard
      step="02 · ERC-20"
      title="Claim PDSC tokens"
      description="One-time fungible reward for registered attendees."
      status={<StatusPill ok={claimed} label={claimed ? "Claimed" : "Unclaimed"} />}
    >
      <div className="w-full space-y-1 font-mono text-xs text-[var(--muted)]">
        <p>
          Balance:{" "}
          <span className="text-[var(--ink)]">
            {typeof balance === "bigint" ? `${formatEther(balance)} PDSC` : "—"}
          </span>
        </p>
        <p>
          Claim size:{" "}
          <span className="text-[var(--ink)]">
            {typeof claimAmount === "bigint"
              ? `${formatEther(claimAmount)} PDSC`
              : "—"}
          </span>
        </p>
      </div>

      <PrimaryButton
        disabled={!isConnected || !token.address || claimed}
        loading={isPending || confirming}
        onClick={() => {
          reset();
          if (!token.address) return;
          writeContract({
            address: token.address,
            abi: token.abi,
            functionName: "claimReward",
          });
        }}
      >
        {claimed ? "Already claimed" : "Claim reward"}
      </PrimaryButton>

      <TxHint hash={hash} error={error?.message} />
    </ActionCard>
  );
}
