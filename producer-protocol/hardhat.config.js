require("@nomiclabs/hardhat-ethers");
require("dotenv").config();

module.exports = {
  solidity: "0.8.17",
  networks: {
    hardhat: {
      // local dev
    },
    mumbai: {
      url: process.env.POLYGON_MUMBAI_URL, // INPUT_REQUIRED {Provide your Polygon Mumbai URL}
      accounts: [process.env.PRIVATE_KEY] // INPUT_REQUIRED {Provide your private key}
    },
    optimismGoerli: {
      url: process.env.OPTIMISM_GOERLI_URL, // INPUT_REQUIRED {Provide your Optimism Goerli URL}
      accounts: [process.env.PRIVATE_KEY] // INPUT_REQUIRED {Provide your private key}
    },
    // Add more networks if needed
  }
};