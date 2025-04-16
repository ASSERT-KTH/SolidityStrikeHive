const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("EtherStore", function () {
  let etherStore, reentrancyAttack, deployer, attacker;

  beforeEach(async function () {
    [deployer, attacker] = await ethers.getSigners();

    // Deploy EtherStore contract
    const EtherStore = await ethers.getContractFactory("EtherStore");
    etherStore = await EtherStore.deploy();
    await etherStore.deployed();

    // Deploy ReentrancyAttack contract
    const ReentrancyAttack = await ethers.getContractFactory("ReentrancyAttack");
    reentrancyAttack = await ReentrancyAttack.deploy(etherStore.address);
    await reentrancyAttack.deployed();
  });

  it("should allow reentrancy attack and drain the contract's balance", async function () {
    // Deposit Ether into the EtherStore contract
    await etherStore.connect(deployer).deposit({ value: ethers.utils.parseEther("1") });
    expect(await ethers.provider.getBalance(etherStore.address)).to.equal(ethers.utils.parseEther("1"));

    // Attempt reentrancy attack from the ReentrancyAttack contract
    await reentrancyAttack.connect(attacker).attack({ value: ethers.utils.parseEther("1") });

    // Verify that the EtherStore contract balance is drained
    expect(await ethers.provider.getBalance(etherStore.address)).to.equal(0);
  });
});