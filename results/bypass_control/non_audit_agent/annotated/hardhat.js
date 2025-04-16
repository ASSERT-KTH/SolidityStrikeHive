const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Bypass isContract() Validation", function () {
  let Target, MaliciousAttacker, target, maliciousAttacker;

  beforeEach(async function () {
    // Deploy the Target contract
    Target = await ethers.getContractFactory("Target");
    target = await Target.deploy();
    await target.deployed();

    // Deploy the MaliciousAttacker contract using a different account
    const [_, attacker] = await ethers.getSigners();
    MaliciousAttacker = await ethers.getContractFactory("MaliciousAttacker");
    maliciousAttacker = await MaliciousAttacker.connect(attacker).deploy(target.address);
    await maliciousAttacker.deployed();
  });

  it("Should bypass the isContract check and set pwned to true", async function () {
    // Verify that the 'pwned' flag is set to true after deploying MaliciousAttacker
    expect(await target.pwned()).to.be.true;
  });
});