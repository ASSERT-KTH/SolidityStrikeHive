const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Dirtybytes", function () {
  let dirtybytes;

  beforeEach(async function () {
    const Dirtybytes = await ethers.getContractFactory("Dirtybytes");
    dirtybytes = await Dirtybytes.deploy();
    await dirtybytes.deployed();
  });

  it("should expose dirty bytes after calling h()", async function () {
    await dirtybytes.h();
    const storageSlotZero = await ethers.provider.getStorageAt(dirtybytes.address, 0);
    const byteArray = ethers.utils.arrayify(storageSlotZero);
    expect(byteArray[byteArray.length - 1]).to.not.equal(0);
  });
});