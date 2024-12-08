// test/Reentrance.test.js

const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Reentrance", function () {

  let deployer, attacker, user;
  let reentrance, malicious;

  beforeEach(async function () {
    [deployer, attacker, user] = await ethers.getSigners();

    // Deploy the Reentrance contract
    const Reentrance = await ethers.getContractFactory("Reentrance", deployer);
    reentrance = await Reentrance.deploy();
    await reentrance.deployed();

    // Deploy the Malicious contract
    const Malicious = await ethers.getContractFactory("Malicious", attacker);
    malicious = await Malicious.deploy(reentrance.address);
    await malicious.deployed();

    // Deployer funds the Reentrance contract
    await reentrance.connect(deployer).donate(user.address, { value: ethers.utils.parseEther("10") });
  });

  it("Should demonstrate reentrancy vulnerability", async function () {
    // Attacker initially donates to the Reentrance contract
    await malicious.connect(attacker).attack({ value: ethers.utils.parseEther("1") });

    // Attacker executes the attack
    await malicious.connect(attacker).attack();

    // Checking the final balance of Reentrance and Malicious contracts
    const finalReentranceBalance = await ethers.provider.getBalance(reentrance.address);
    const finalMaliciousBalance = await ethers.provider.getBalance(malicious.address);

    // Reentrance contract should be drained to 0
    expect(finalReentranceBalance).to.equal(0);

    // Malicious contract should have drained funds equivalent to initial deposit plus its own attack transfer
    expect(finalMaliciousBalance).to.be.above(ethers.utils.parseEther("10"));
  });
});