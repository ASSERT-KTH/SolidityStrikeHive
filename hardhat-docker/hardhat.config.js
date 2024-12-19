/** @type import('hardhat/config').HardhatUserConfig */
require("@nomiclabs/hardhat-waffle");

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.20", // Latest modern contracts
      },
      {
        version: "0.8.18", // Modern contracts
      },
      {
        version: "0.8.0", // Modern contracts
      },
      {
        version: "0.7.6", // Contracts requiring Solidity 0.7
      },
      {
        version: "0.7.4", // Contracts requiring Solidity 0.7
      },
      {
        version: "0.7.0", // Contracts requiring Solidity 0.7
      },
      {
        version: "0.6.12", // Contracts requiring Solidity 0.6
      },
      {
        version: "0.6.0", // Early Solidity 0.6
      },
      {
        version: "0.5.17", // Contracts requiring Solidity 0.5
      },
      {
        version: "0.5.0", // Early Solidity 0.5
      },
      {
        version: "0.4.25", // Legacy contracts
      },
      {
        version: "0.4.19", // Legacy contracts
      },
      {
        version: "0.4.11", // Legacy contracts
      }
    ]
  },
  networks: {
    hardhat: {
      // ... other configurations
      ensAddress: null,
      mining: {
        auto: true,
        interval: 0
      },
    },
  },
};
