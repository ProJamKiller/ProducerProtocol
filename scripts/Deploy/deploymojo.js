// scripts/deployMojo.js
const hre = require("hardhat");

async function main() {
  // Get the deployer's account (the initial owner of the contract)
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying Mojo contract with the account:", deployer.address);

  // Check the deployer's balance
  const balance = await deployer.getBalance();
  console.log("Account balance:", hre.ethers.utils.formatEther(balance), "ETH");

  // Get the contract factory for Mojo
  const Mojo = await hre.ethers.getContractFactory("Mojo");

  // Deploy the contract, passing the initial owner (deployer) to the constructor
  const initialOwner = deployer.address; // You can change this to another address if desired
  const mojoContract = await Mojo.deploy(initialOwner);

  // Wait for the contract to be deployed
  await mojoContract.deployed();

  // Log the deployed contract address
  console.log("Mojo contract deployed to:", mojoContract.address);

  // Optional: Verify the total supply (1,000,000 MOJO tokens with 18 decimals)
  const totalSupply = await mojoContract.TOTAL_SUPPLY();
  console.log("Total Supply:", hre.ethers.utils.formatEther(totalSupply), "MOJO");
}

// Run the deployment and handle errors
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error deploying Mojo contract:", error);
    process.exit(1);
  });