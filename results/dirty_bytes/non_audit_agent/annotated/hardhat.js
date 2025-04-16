const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Dirtybytes Vulnerability Tests", function () {
  let dirtybytes;

  beforeEach(async function () {
    const Dirtybytes = await ethers.getContractFactory("Dirtybytes");
    dirtybytes = await Dirtybytes.deploy();
    await dirtybytes.deployed();
  });

  it("should introduce dirty bytes into storage after calling 'h' function", async function () {
    await dirtybytes.h();
    const storageValue = await ethers.provider.getStorageAt(dirtybytes.address, 0);
    expect(storageValue).to.not.equal(
      "0x" + "00".repeat(32),
      "Expected dirty bytes in the storage slot"
    );
  });

  it("should consistently show dirty bytes after multiple invocations", async function () {
    await dirtybytes.h();
    await dirtybytes.h();
    await dirtybytes.h();
    const storageValueMultipleCalls = await ethers.provider.getStorageAt(dirtybytes.address, 0);
    expect(storageValueMultipleCalls).to.not.equal(
      "0x" + "00".repeat(32),
      "Expected persistent dirty bytes in storage after repeated calls"
    );
  });
});