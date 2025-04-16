const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("FixedArrayDeletion", function () {
  let fixedArrayDeletion, maliciousArrayDeletion;

  beforeEach(async function () {
    const FixedArrayDeletion = await ethers.getContractFactory("FixedArrayDeletion");
    fixedArrayDeletion = await FixedArrayDeletion.deploy();
    await fixedArrayDeletion.deployed();

    const MaliciousArrayDeletion = await ethers.getContractFactory("MaliciousArrayDeletion");
    maliciousArrayDeletion = await MaliciousArrayDeletion.deploy(fixedArrayDeletion.address);
    await maliciousArrayDeletion.deployed();
  });

  it("should delete elements from the array correctly", async function () {
    expect(await fixedArrayDeletion.getLength()).to.equal(5);

    await fixedArrayDeletion.deleteElement(0);

    expect(await fixedArrayDeletion.getLength()).to.equal(4);
  });

  it("should revert when trying to delete from an empty array", async function () {
    // Deleting all elements
    for (let i = 0; i < 5; i++) {
      await fixedArrayDeletion.deleteElement(0);
    }
    
    await expect(fixedArrayDeletion.deleteElement(0)).to.be.revertedWith("Invalid index");
  });

  it("should revert when trying to delete an element at an out-of-bounds index", async function () {
    await expect(fixedArrayDeletion.deleteElement(10)).to.be.revertedWith("Invalid index");
  });

  it("should allow full exploitation by malicious contract", async function () {
    await maliciousArrayDeletion.exploit();
    expect(await fixedArrayDeletion.getLength()).to.equal(0);
  });
});