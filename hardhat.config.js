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
      polygon: "R45T4FW6FEAE8VKVH1CI64RMIPGFKBEWG2" // Get free: https://polygonscan.com/myapikey
    }
  }
};
