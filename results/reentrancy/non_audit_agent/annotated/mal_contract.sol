const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Reentrancy Vulnerability Test", function () {
  let etherStore, attackContract, owner, attacker;

  beforeEach(async () => {
    [owner, attacker] = await ethers.getSigners();

    // Deploy EtherStore contract
    const EtherStore = await ethers.getContractFactory("EtherStore");
    etherStore = await EtherStore.deploy();
    await etherStore.deployed();

    // Deploy Attacker contract
    const ReentrancyAttack = await ethers.getContractFactory("ReentrancyAttack");
    attackContract = await ReentrancyAttack.deploy(etherStore.address);
    await attackContract.deployed();

    // Deposit 2 ether to EtherStore from owner
    await etherStore.connect(owner).deposit({ value: ethers.utils.parseEther("2") });
  });

  it("Ensures the EtherStore balance is zero after the attack", async () => {
    // Attack by sending 1 ether from attacker account
    await attackContract.connect(attacker).attack({ value: ethers.utils.parseEther("1") });

    // Verify that EtherStore contract balance is 0
    const balance = await ethers.provider.getBalance(etherStore.address);
    expect(balance).to.equal(0);
  });
});