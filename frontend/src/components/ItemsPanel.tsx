"use client";

import { useEffect } from "react";
import {
  useAccount,
  useReadContracts,
  useWaitForTransactionReceipt,
  useWriteContract,
} from "wagmi";
import { contracts, ITEM_IDS } from "@/lib/contracts";
import { ActionCard, PrimaryButton, StatusPill, TxHint } from "./ui";

const itemMeta = [
  { id: ITEM_IDS.ATTENDEE_PASS, label: "Attendee Pass" },
  { id: ITEM_IDS.SWAG_VOUCHER, label: "Swag Voucher" },
  { id: ITEM_IDS.CERTIFICATE, label: "Certificate" },
] as const;

export function ItemsPanel() {
  const { address, isConnected } = useAccount();
  const items = contracts.items;

  const { data, refetch } = useReadContracts({
    contracts: [
      {
        address: items.address,
        abi: items.abi,
        functionName: "hasClaimedPack",
        args: address ? [address] : undefined,
      },
      ...itemMeta.map((item) => ({
        address: items.address,
        abi: items.abi,
        functionName: "balanceOf" as const,
        args: address ? [address, item.id] : undefined,
      })),
    ],
    query: { enabled: Boolean(items.address && address) },
  });

  const { writeContract, data: hash, isPending, error, reset } = useWriteContract();
  const { isLoading: confirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  useEffect(() => {
    if (!isSuccess) return;
    void refetch();
  }, [isSuccess, refetch]);

  const claimed = Boolean(data?.[0]?.result);

  return (
    <ActionCard
      step="04 · ERC-1155"
      title="Claim starter pack"
      description="Receive pass, swag voucher, and certificate in one mint."
      status={<StatusPill ok={claimed} label={claimed ? "Claimed" : "Unclaimed"} />}
    >
      <ul className="w-full space-y-1 font-mono text-xs text-[var(--muted)]">
        {itemMeta.map((item, index) => {
          const bal = data?.[index + 1]?.result;
          return (
            <li key={item.label} className="flex justify-between gap-3">
              <span>{item.label}</span>
              <span className="text-[var(--ink)]">
                {typeof bal === "bigint" ? bal.toString() : "—"}
              </span>
            </li>
          );
        })}
      </ul>

      <PrimaryButton
        disabled={!isConnected || !items.address || claimed}
        loading={isPending || confirming}
        onClick={() => {
          reset();
          if (!items.address) return;
          writeContract({
            address: items.address,
            abi: items.abi,
            functionName: "claimStarterPack",
          });
        }}
      >
        {claimed ? "Already claimed" : "Claim starter pack"}
      </PrimaryButton>

      <TxHint hash={hash} error={error?.message} />
    </ActionCard>
  );
}
