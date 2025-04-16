const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Target Contract Vulnerability Test", function () {
  let targetContract, maliciousAttackerContract, owner;

  beforeEach(async function () {
    [owner] = await ethers.getSigners();

    // Deploy the Target contract
    const TargetContract = await ethers.getContractFactory("Target");
    targetContract = await TargetContract.deploy();
    await targetContract.deployed();

    // Deploy the MaliciousAttacker contract
    const MaliciousAttackerContract = await ethers.getContractFactory("MaliciousAttacker");
    maliciousAttackerContract = await MaliciousAttackerContract.deploy(targetContract.address);
    await maliciousAttackerContract.deployed();
  });

  it("should set the pwned state to true in the Target contract", async function () {
    // Assert that the pwned state is flipped to true
    expect(await targetContract.pwned()).to.be.true;
  });
});