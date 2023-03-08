require('dotenv').config();

require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  paths: {
    sources: './contracts',
  },
  etherscan: {
    apiKey: {
      opera: process.env.FTMSCAN_API_KEY,
    }
  },
  defaultNetwork: 'localhost',
  networks: {
    hardhat: {
      forking: {
        enabled: true,
        url: 'https://rpc.fantom.network',
        // blockNumber: 24243078,
        accounts: [
          process.env.PRIVATE_KEY_OWNER,
          process.env.PRIVATE_KEY_USER_1,
          process.env.PRIVATE_KEY_USER_2,
          process.env.PRIVATE_KEY_FEE,
        ],
      },
    },
    localhost: {
      url: 'http://127.0.0.1:8545',
      // accounts: [
      //   process.env.PRIVATE_KEY_OWNER,
      //   process.env.PRIVATE_KEY_USER_1,
      //   process.env.PRIVATE_KEY_USER_2,
      //   process.env.PRIVATE_KEY_FEE,
      // ],
    },
    fantom: {
      url: 'https://rpc.ankr.com/fantom',
      accounts: [
        process.env.PRIVATE_KEY_OWNER,
        process.env.PRIVATE_KEY_USER_1,
        process.env.PRIVATE_KEY_USER_2,
        process.env.PRIVATE_KEY_FEE,
      ]
    },
  },
};
