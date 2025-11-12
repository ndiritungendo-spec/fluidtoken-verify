require("@nomicfoundation/hardhat-verify");

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
      accounts: ["YOUR_PRIVATE_KEY"] // optional, only needed for deployment
    }
  },
  etherscan: {
    apiKey: {
      polygon: "YOUR_POLYGONSCAN_API_KEY" // Get free: https://polygonscan.com/myapikey
    }
  }
};
