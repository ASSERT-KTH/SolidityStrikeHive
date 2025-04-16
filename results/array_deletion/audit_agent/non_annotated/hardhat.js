const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ArrayDeletionBug Test Suite", function () {
  let arrayDeletionBug;
  let owner;

  beforeEach(async function () {
    [owner] = await ethers.getSigners();
    const ArrayDeletionBug = await ethers.getContractFactory("ArrayDeletionBug");
    arrayDeletionBug = await ArrayDeletionBug.deploy();
    await arrayDeletionBug.deployed();
  });

  it("Should not reduce array length when deleting elements", async function () {
    const initialLength = await arrayDeletionBug.getLength();
    expect(initialLength).to.equal(5);

    await arrayDeletionBug.deleteElement(0);
    await arrayDeletionBug.deleteElement(1);

    expect(await arrayDeletionBug.myArray(0)).to.equal(0);
    expect(await arrayDeletionBug.myArray(1)).to.equal(0);

    const newLength = await arrayDeletionBug.getLength();
    expect(newLength).to.equal(5);

    await expect(arrayDeletionBug.myArray(0, 1)).to.be.reverted;
  });

  it("Should not allow deleting an element at an invalid index", async function () {
    const invalidIndex = 5;

    await expect(arrayDeletionBug.deleteElement(invalidIndex)).to.be.revertedWith("Invalid index");
  });
});