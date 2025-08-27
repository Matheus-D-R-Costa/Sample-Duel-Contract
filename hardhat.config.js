require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    solidity: "0.8.28",
    networks: {
        amoy: {
            url: "https://rpc-amoy.polygon.technology",
            accounts: [process.env.PRIVATE_KEY],
            gas: 6000000
        }
    }
};
