require("@nomicfoundation/hardhat-verify");
require("dotenv").config();

module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: false  // ← CRITICAL
      },
      evmVersion: "london",
      viaIR: false
    }
  },
  networks: {
    polygon: {
      url: "https://polygon-rpc.com",
      accounts: []
    }
  },
  etherscan: {
    apiKey: {
      polygon: process.env.POLYGONSCAN_API_KEY
    }
  }
};