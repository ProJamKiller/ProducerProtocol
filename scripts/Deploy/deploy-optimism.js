async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
  
    // Get the contract factory for your NFT bridging contract.
    const ProducerProtocolOptimism = await ethers.getContractFactory("ProducerProtocolOptimism");
  
    // Load messenger and L1 contract addresses from your environment.
    const crossDomainMessenger = process.env.CROSS_DOMAIN_MESSENGER;
    const l1Contract = process.env.L1_CONTRACT;
  
    // Deploy the NFT bridging contract with the proper constructor parameters.
    const contract = await ProducerProtocolOptimism.deploy(crossDomainMessenger, l1Contract);
    await contract.deployed();
  
    console.log("ProducerProtocolOptimism deployed to:", contract.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error("Deployment error:", error);
      process.exit(1);
    });