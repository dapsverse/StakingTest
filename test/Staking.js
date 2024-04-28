const { expect } = require("chai");
const { ethers } = require('hardhat');

describe("Staking", function () {
  let staking;
  let stakingAddress;
  let dummyERC20Address;
  let dummyERC20
  let owner;
  let addr1;
  let addr2;
  let addrs;

  beforeEach(async function () {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    dummyERC20 = await ethers.deployContract('MyToken', owner);
    dummyERC20Address = await dummyERC20.getAddress();
    await dummyERC20.mint(owner.address, ethers.parseUnits('10000000', 'ether'))

    staking = await ethers.deployContract('Staking', owner);
    stakingAddress = await staking.getAddress();

    await dummyERC20.approve(stakingAddress, ethers.parseUnits('10000000', 'ether'))
    await staking.connect(owner).setupActiveToken(dummyERC20Address);
  });

  it("Should deploy Staking contract", async function () {
    // Check if the Staking contract is deployed
    expect(stakingAddress).to.not.equal(0);
  });

  it("Should set initial values correctly", async function () {
    expect(await staking.rewardLimit()).to.equal(ethers.parseUnits('10000000', 'ether'));
    expect(await staking.claimedToken()).to.equal(0);
    expect(await staking.rewardPerDay()).to.equal(ethers.parseUnits('1000', 'ether'));
    expect(await staking.rewardAmountRemaining()).to.equal(ethers.parseUnits('10000000', 'ether'));
  });

  it("Should stake tokens correctly", async function () {
    const amount = ethers.parseEther("100");
    await dummyERC20.mint(addr1.address, amount)
    await dummyERC20.connect(addr1).approve(stakingAddress, amount)

    await staking.connect(addr1).staking(amount);
    expect(await staking.userStaked(addr1.address)).to.equal(amount);
  });

  it("Should claim rewards correctly", async function () {
    const amount = ethers.parseEther("100");
    await dummyERC20.mint(addr1.address, amount)
    await dummyERC20.connect(addr1).approve(stakingAddress, amount)

    await staking.connect(addr1).staking(amount);
    await staking.connect(addr1).claim();
    expect(await staking.userRewards(addr1.address)).to.equal(0);
  });

  it("Should unstake tokens correctly", async function () {
    const amount = ethers.parseEther("100");
    await dummyERC20.mint(addr1.address, amount)
    await dummyERC20.connect(addr1).approve(stakingAddress, amount)

    await staking.connect(addr1).staking(amount);
    await staking.connect(addr1).unstaking(amount);
    expect(await staking.userStaked(addr1.address)).to.equal(0);
  });
});
