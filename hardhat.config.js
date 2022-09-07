require("@nomicfoundation/hardhat-toolbox");
const { config: dotenvConfig } = require("dotenv");
const { resolve } = require("path");

const dotenvConfigPath = process.env.DOTENV_CONFIG_PATH || "./.env";
dotenvConfig({ path: resolve(__dirname, dotenvConfigPath) });

// Ensure that we have all the environment variables we need.
const mnemonic = process.env.MNEMONIC;
if (!mnemonic) {
  throw new Error("Please set your MNEMONIC in a .env file");
}

const config = {
  solidity: "0.8.9",
  networks: {
    hardhat: {
      chainId: 31337,
    },
    ganache: {
      accounts: {
        mnemonic,
        path: "m/44'/60'/0'/0",
        count: 20,
      },
      url: "http://localhost:8545",
      chainId: 1337,
      gasPrice: 20000000000,
    },
  },
};

module.exports = config;
