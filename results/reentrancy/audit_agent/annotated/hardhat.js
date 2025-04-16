const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("EtherStore", function () {
  let etherStore, attack;
  let owner, attacker, user;

  beforeEach(async function () {
    [owner, attacker, user] = await ethers.getSigners();

    // Deploy EtherStore contract
    const EtherStore = await ethers.getContractFactory("EtherStore");
    etherStore = await EtherStore.deploy();
    await etherStore.deployed();

    // Deploy Attack contract
    const Attack = await ethers.getContractFactory("Attack");
    attack = await Attack.deploy(etherStore.address);
    await attack.deployed();
  });

  it("Should allow users to deposit and withdraw funds", async function () {
    // User deposits 1 ETH
    await etherStore.connect(user).deposit({ value: ethers.utils.parseEther("1") });
    expect(await etherStore.balances(user.address)).to.equal(ethers.utils.parseEther("1"));

    // User withdraws 1 ETH
    await etherStore.connect(user).withdrawFunds(ethers.utils.parseEther("1"));
    expect(await etherStore.balances(user.address)).to.equal(0);
  });

  it("Should allow the attacker to drain the contract's funds using a reentrancy attack", async function () {
    // User deposits 10 ETH
    await etherStore.connect(user).deposit({ value: ethers.utils.parseEther("10") });
    expect(await etherStore.balances(user.address)).to.equal(ethers.utils.parseEther("10"));

    // Attacker deposits 1 ETH and then initiates the attack
    await attack.connect(attacker).attack({ value: ethers.utils.parseEther("1") });

    // Verify contract's balance is drained
    const balance = await ethers.provider.getBalance(etherStore.address);
    expect(balance).to.equal(0);

    // Verify attacker's balance increase
    const attackerBalance = await ethers.provider.getBalance(attacker.address);
    expect(attackerBalance).to.be.gt(ethers.utils.parseEther("11")); // Initial 1 + stolen 10
  });
});