import { http } from "wagmi";
import { anvil, sepolia } from "wagmi/chains";
import { getDefaultConfig } from "@rainbow-me/rainbowkit";

const projectId =
  process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID || "pdsc-workshop-local-dev";

export const chains = [anvil, sepolia] as const;

export const config = getDefaultConfig({
  appName: "PDSC Workshop 2026",
  projectId,
  chains,
  transports: {
    [anvil.id]: http(process.env.NEXT_PUBLIC_RPC_URL || "http://127.0.0.1:8545"),
    [sepolia.id]: http(
      process.env.NEXT_PUBLIC_SEPOLIA_RPC_URL || "https://ethereum-sepolia-rpc.publicnode.com",
    ),
  },
  ssr: true,
});
