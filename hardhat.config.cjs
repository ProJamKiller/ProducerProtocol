require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.17", // Changed from 0.8.15 to 0.8.17
  networks: {
    optimismGoerli: {
      url: process.env.OPTIMISM_GOERLI_RPC_URL || "https://rpc.thirdweb.com/optimism-goerli",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
    // other network configs if needed...
  },
};