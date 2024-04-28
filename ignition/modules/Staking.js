const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

// sepoila used address
const erc20Address = "0xE08c9023743368D227b158a682827C2F3cd403EE"

module.exports = buildModule("StakingModule", (m) => {
  const stake = m.contract("Staking");

  // setup active token
  m.call(stake, "setupActiveToken", [erc20Address])

  return { stake };
});
