const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ArrayDeletionBug", function () {
  let arrayDeletionBug, maliciousContract;

  beforeEach(async function () {
    const ArrayDeletionBug = await ethers.getContractFactory("ArrayDeletionBug");
    arrayDeletionBug = await ArrayDeletionBug.deploy();
    await arrayDeletionBug.deployed();

    const MaliciousContract = await ethers.getContractFactory("MaliciousContract");
    maliciousContract = await MaliciousContract.deploy(arrayDeletionBug.address);
    await maliciousContract.deployed();
  });

  it("should not change the array length after deleting an element", async function () {
    expect(await arrayDeletionBug.getLength()).to.equal(5);
    await arrayDeletionBug.deleteElement(0);
    expect(await arrayDeletionBug.getLength()).to.equal(5);
  });

  it("should allow access to the zeroed-out element through a malicious contract", async function () {
    await arrayDeletionBug.deleteElement(0);
    await maliciousContract.exploitArrayDeletion();
  });

  it("should handle valid and invalid indices in deleteElement", async function () {
    await arrayDeletionBug.deleteElement(0);
    expect(await arrayDeletionBug.getLength()).to.equal(5);

    await expect(arrayDeletionBug.deleteElement(5)).to.be.revertedWith(
      "Invalid index"
    );
  });
});