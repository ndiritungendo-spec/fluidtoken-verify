require("@nomicfoundation/hardhat-verify");
require("dotenv").config();   // <-- optional but recommended

module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    polygon: {
      url: "https://polygon-rpc.com",
      // Remove the private key if you only want to **verify** (not deploy)
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : []
    }
  },
  etherscan: {
    apiKey: {
      polygon: process.env.POLYGONSCAN_API_KEY || "R45T4FW6FEAE8VKVH1CI64RMIPGFKBEWG2"
    }
  }
};
