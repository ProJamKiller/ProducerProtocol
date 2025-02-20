import { ThirdwebSDK } from "@thirdweb-dev/sdk";

async function main() {
  const sdk = new ThirdwebSDK("optimism");
  const contract = await sdk.deployer.deployToken({
    name: "Wrapped PJK",
    symbol: "WPJK",
    // Additional configuration
  });
  console.log("WPJK deployed to:", contract.getAddress());
}

main().catch(console.error);

