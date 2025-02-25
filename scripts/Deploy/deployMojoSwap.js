const { ThirdwebSDK } = require("@thirdweb-dev/sdk");
require("dotenv").config();

async function main() {
  // Initialize SDK with Optimism mainnet
  const sdk = ThirdwebSDK.fromPrivateKey(process.env.PRIVATE_KEY, "optimism", {
    secretKey: "YOUR_THIRDWEB_SECRET_KEY", // Optional
  });

  // Replace with your deployed Mojo address after running deployMojo.js
  const mojoAddress = "INSERT_MOJO_ADDRESS_HERE";

  console.log("Deploying MojoSwap to Optimism...");
  const swapContract = await sdk.deployer.deployContract({
    name: "MojoSwap",
    type: "custom",
    contractUri: "ipfs://QmYourMetadataHere", // Optional, customize if needed
    args: [mojoAddress],
  });

  console.log("MojoSwap deployed to:", swapContract);

  // Connect to Mojo and set swap contract
  const mojo = await sdk.getContract(mojoAddress);
  await mojo.call("setSwapContract", [swapContract]);
  console.log("MojoSwap set as swap contract in Mojo");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });