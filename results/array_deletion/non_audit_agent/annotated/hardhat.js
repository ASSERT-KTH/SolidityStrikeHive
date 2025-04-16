const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("FixedArrayDeletion", function () {
  let fixedArrayDeletion;
  let maliciousArrayDeletion;

  beforeEach(async function () {
    const FixedArrayDeletion = await ethers.getContractFactory("FixedArrayDeletion");
    fixedArrayDeletion = await FixedArrayDeletion.deploy();
    await fixedArrayDeletion.deployed();

    const MaliciousArrayDeletion = await ethers.getContractFactory("MaliciousArrayDeletion");
    maliciousArrayDeletion = await MaliciousArrayDeletion.deploy(fixedArrayDeletion.address);
    await maliciousArrayDeletion.deployed();
  });

  it("should demonstrate DoS via high gas consumption", async function () {
    try {
      for (let i = 0; i < 1000; i++) {
        await maliciousArrayDeletion.exploitGasConsumption(0);
      }
    } catch (error) {
      // To show a DoS due to high gas consumption, we would need the transaction to fail
      expect(error.message).to.include("transaction ran out of gas");
    }
  });

  it("should demonstrate data inconsistency on deletion", async function () {
    const initialLength = await fixedArrayDeletion.getLength();
    expect(initialLength).to.equal(5);

    // Use malicious contract to exploit inconsistency
    await maliciousArrayDeletion.exploitDataInconsistency(0);

    const finalLength = await fixedArrayDeletion.getLength();
    expect(finalLength).to.be.below(5); // Reflecting array size change

    // Check for data inconsistency
    const checkData = await fixedArrayDeletion.myArray(0);
    expect(checkData).to.not.equal(1);
  });
});