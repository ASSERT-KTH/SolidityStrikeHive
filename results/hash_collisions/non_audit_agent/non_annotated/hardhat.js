const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("HashCollisionBug", () => {
  let hashCollisionBugContract;

  beforeEach(async () => {
    const HashCollisionBug = await ethers.getContractFactory("HashCollisionBug");
    hashCollisionBugContract = await HashCollisionBug.deploy();
    await hashCollisionBugContract.deployed();
  });

  it("should expose hash collision vulnerability using different input strings", async () => {
    const string1a = "AAA";
    const string2a = "BBB";
    const string1b = "AA";
    const string2b = "ABBB";
    const depositAmount = ethers.utils.parseEther("1.0");

    const hash1 = await hashCollisionBugContract.createHash(string1a, string2a);
    const hash2 = await hashCollisionBugContract.createHash(string1b, string2b);

    expect(hash1).to.equal(hash2);

    await hashCollisionBugContract.deposit(string1a, string2a, { value: depositAmount });

    await expect(
      hashCollisionBugContract.deposit(string1b, string2b, { value: depositAmount })
    ).to.be.revertedWith("Hash collision detected");
  });

  it("should allow successful deposit when no collision occurs", async () => {
    const string1 = "unique1";
    const string2 = "unique2";
    const depositAmount = ethers.utils.parseEther("1.0");

    await hashCollisionBugContract.deposit(string1, string2, { value: depositAmount });

    const balance = await hashCollisionBugContract.balances(
      await hashCollisionBugContract.createHash(string1, string2)
    );
    expect(balance).to.equal(depositAmount);
  });
});