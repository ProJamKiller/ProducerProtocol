const { ThirdwebSDK } = require("@thirdweb-dev/sdk");
require("dotenv").config();

async function main() {
  // Initialize SDK with Optimism mainnet
  const sdk = ThirdwebSDK.fromPrivateKey(process.env.PRIVATE_KEY, "optimism", {
    secretKey: "YOUR_THIRDWEB_SECRET_KEY", // Optional
  });

  console.log("Deploying Mojo to Optimism...");
  const initialOwner = "0x2af17552f27021666BcD3E5Ba65f68CB5Ec217fc";
  const contract = await sdk.deployer.deployContract({
    name: "Mojo",
    type: "custom",
    contractUri: "ipfs://QmbKnUmjdTrdBgRqofVKzgtwHaQBno93AQfg7mtQijtZbw/0", // From your config
    args: [initialOwner],
  });

  console.log("Mojo deployed to:", contract);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });