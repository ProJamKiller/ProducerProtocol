const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log(
    "Deploying WPJK contract with account:",
    deployer.address,
  );

  const WPJK = await hre.ethers.getContractFactory("WPJK");
  const wpjk = await WPJK.deploy();

  await wpjk.deployed();

  console.log("WPJK deployed to:", wpjk.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
