const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log(
    "Deploying ProducerProtocolToken with account:",
    deployer.address,
  );

  const ProducerProtocolToken =
    await hre.ethers.getContractFactory(
      "ProducerProtocolToken",
    );
  const producerProtocolToken =
    await ProducerProtocolToken.deploy(
      "Producer Protocol Token",
      "PPT",
      deployer.address,
    );

  await producerProtocolToken.deployed();

  console.log(
    "ProducerProtocolToken deployed to:",
    producerProtocolToken.address,
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
