require("@nomiclabs/hardhat-ethers");
require("dotenv").config();

module.exports = {
  solidity: "0.8.17",
  networks: {
    hardhat: {
      // local dev
    },
    mumbai: {
      url: process.env.POLYGON_MUMBAI_URL, // https://polygon.mumbai.rpc.thirdweb.com}
      accounts: [process.env.PRIVATE_KEY] // INPUT_REQUIRED {Provide your private key}
    },
    optimismGoerli: {
      url: process.env.OPTIMISM_GOERLI_URL, // https://optimism.goerli.rpc.thirdweb.com
    }
      accounts: [process.env.PRIVATE_KEY] // INPUT_REQUIRED {Provide your private key}
    },
    // Add more networks if needed
  }
};