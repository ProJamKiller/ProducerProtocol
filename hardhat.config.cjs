require("dotenv").config();

module.exports = {
  solidity: "0.8.15",
  networks: {
    optimismGoerli: {
      url: process.env.OPTIMISM_GOERLI_RPC_URL || "https://rpc.thirdweb.com/optimism-goerli",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
    // other network configs if needed...
  },
};