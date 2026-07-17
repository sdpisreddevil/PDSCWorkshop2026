import { type Address, type Abi } from "viem";
import workshopAbi from "./abis/PDSCWorkshop2026.json";
import tokenAbi from "./abis/PDSCWorkshopToken.json";
import badgeAbi from "./abis/PDSCWorkshopBadge.json";
import itemsAbi from "./abis/PDSCWorkshopItems.json";

function addr(value: string | undefined): Address | undefined {
  if (!value || value === "0x" || value.length < 42) return undefined;
  return value as Address;
}

/** Set these after deploying with ./script/deploy.sh all */
export const contracts = {
  workshop: {
    address: addr(process.env.NEXT_PUBLIC_WORKSHOP_ADDRESS),
    abi: workshopAbi as Abi,
  },
  token: {
    address: addr(process.env.NEXT_PUBLIC_TOKEN_ADDRESS),
    abi: tokenAbi as Abi,
  },
  badge: {
    address: addr(process.env.NEXT_PUBLIC_BADGE_ADDRESS),
    abi: badgeAbi as Abi,
  },
  items: {
    address: addr(process.env.NEXT_PUBLIC_ITEMS_ADDRESS),
    abi: itemsAbi as Abi,
  },
} as const;

export const ITEM_IDS = {
  ATTENDEE_PASS: 1n,
  SWAG_VOUCHER: 2n,
  CERTIFICATE: 3n,
} as const;

export function shortAddress(value?: string | null) {
  if (!value) return "";
  return `${value.slice(0, 6)}…${value.slice(-4)}`;
}
