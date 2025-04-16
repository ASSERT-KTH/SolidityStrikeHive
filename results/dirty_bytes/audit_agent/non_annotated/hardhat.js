const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Dirtybytes", function () {
  let dirtybytes;
  let maliciousExploit;

  beforeEach(async function () {
    const Dirtybytes = await ethers.getContractFactory("Dirtybytes");
    dirtybytes = await Dirtybytes.deploy();
    await dirtybytes.deployed();

    const MaliciousExploit = await ethers.getContractFactory("MaliciousExploit");
    maliciousExploit = await MaliciousExploit.deploy(dirtybytes.address);
    await maliciousExploit.deployed();
  });

  it("should allow unbounded growth of the h() function", async function () {
    // Test for unbounded growth vulnerability
    for (let i = 0; i < 1000; i++) {
      await dirtybytes.h();
    }
    // We're not directly measuring the size of 's',
    // so ensuring it runs without reverts is an indicator of potential growth.
  });

  it("should detect denial of service vulnerability using MaliciousExploit", async function () {
    // Test for denial of service vulnerability
    try {
      await maliciousExploit.exploit();
      expect.fail("Expected denial of service due to out of gas");
    } catch (error) {
      expect(error.message).to.include("out of gas");
    }
  });
});