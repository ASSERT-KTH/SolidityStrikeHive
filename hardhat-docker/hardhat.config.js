/** @type import('hardhat/config').HardhatUserConfig */
require("@nomiclabs/hardhat-waffle");

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.0", // Modern contracts
      },
      {
        version: "0.7.0", // Contracts requiring Solidity 0.7
      },
      {
        version: "0.4.25", // Legacy contracts
      },
      {
        version: "0.4.19", // Legacy contracts
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
