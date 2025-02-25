const { ThirdwebSDK } = require("@thirdweb-dev/sdk");
require("dotenv").config();

async function main() {
  // Initialize SDK with Polygon mainnet
  const sdk = ThirdwebSDK.fromPrivateKey(process.env.PRIVATE_KEY, "polygon", {
    secretKey: "YOUR_THIRDWEB_SECRET_KEY", // Optional, get from Thirdweb dashboard
  });

  console.log("Deploying PJKBurner to Polygon...");
  const contract = await sdk.deployer.deployContract({
    name: "PJKBurner",
    type: "custom", // Since it's not a Thirdweb prebuilt contract
    contractUri: "ipfs://QmYourMetadataHere", // Optional, use your own or skip
  });

  console.log("PJKBurner deployed to:", contract);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });