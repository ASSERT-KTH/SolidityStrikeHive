const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("EtherStore - Reentrancy Vulnerability Test Suite", function () {
  let etherStore, reentrantAttack, owner, attacker;

  beforeEach(async function () {
    [owner, attacker] = await ethers.getSigners();

    // Deploy EtherStore contract
    const EtherStore = await ethers.getContractFactory("EtherStore");
    etherStore = await EtherStore.deploy();
    await etherStore.deployed();

    // Deploy ReentrancyAttack contract
    const ReentrancyAttack = await ethers.getContractFactory("ReentrancyAttack");
    reentrantAttack = await ReentrancyAttack.deploy(etherStore.address);
    await reentrantAttack.deployed();
  });

  it("should allow reentrancy to drain EtherStore", async function () {
    // Owner deposits 1 ETH to EtherStore
    await etherStore.connect(owner).deposit({ value: ethers.utils.parseEther("1") });
    expect(await ethers.provider.getBalance(etherStore.address)).to.equal(ethers.utils.parseEther("1"));

    // Execute attack from reentrant contract
    await reentrantAttack.connect(attacker).attack({ value: ethers.utils.parseEther("1") });

    // EtherStore balance should be less than 1 ETH
    const finalBalance = await ethers.provider.getBalance(etherStore.address);
    expect(finalBalance).to.be.lt(ethers.utils.parseEther("1"));
  });
});