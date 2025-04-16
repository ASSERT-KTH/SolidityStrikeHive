const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Target Contract Vulnerability", function () {
  let targetContract;

  beforeEach(async function () {
    // Deploy the Target contract
    const Target = await ethers.getContractFactory("Target");
    targetContract = await Target.deploy();
    await targetContract.deployed();
  });

  it("should set the `pwned` variable to true when exploited", async function () {
    // This test should deploy a malicious contract to exploit the vulnerability
    const MaliciousContract = await ethers.getContractFactory("MaliciousContract");
    const maliciousContract = await MaliciousContract.deploy(targetContract.address);
    await maliciousContract.deployed();

    expect(await targetContract.pwned()).to.be.true;
  });

  it("should not set `pwned` variable to true by default", async function () {
    // Verify that the `pwned` variable is false before any exploitation
    expect(await targetContract.pwned()).to.be.false;
  });
});