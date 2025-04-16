const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Bypasscontrol Contract", function () {
  let target, maliciousContract;

  beforeEach(async function () {
    const Target = await ethers.getContractFactory("Target");
    target = await Target.deploy();
    await target.deployed();

    const MaliciousContract = await ethers.getContractFactory("MaliciousContract");
    maliciousContract = await MaliciousContract.deploy(target.address);
    await maliciousContract.deployed();
  });

  it("should allow MaliciousContract to bypass isContract() check and set pwned to true", async function () {
    // Since the protected function is called in the constructor of the MaliciousContract
    // we do not need an explicit call to protected after deployment in the test
    expect(await target.pwned()).to.be.true;
  });
});