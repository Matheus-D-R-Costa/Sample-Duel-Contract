const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("P2PDuelModule", (m) => {
    const P2PDuel = m.contract("P2PDuel", []);
    return { P2PDuel };
});
