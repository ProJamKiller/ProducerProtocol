require("@nomiclabs/hardhat-ethers");
require("dotenv").config();

module.exports = {
  solidity: "0.8.17",
  networks: {
    hardhat: {
      // local dev
    },
    mumbai: {
      url: process.env.POLYGON_MUMBAI_URL,
      accounts: [process.env.PRIVATE_KEY]
    },
    optimismGoerli: {
      url: process.env.OPTIMISM_GOERLI_URL,
      accounts: [process.env.PRIVATE_KEY]
    },
    // Add more networks if needed
  }
};