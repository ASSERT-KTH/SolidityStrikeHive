const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("HashCollisionBug", function () {
  let hashCollisionBug, owner;

  beforeEach(async () => {
    [owner] = await ethers.getSigners();

    // Deploy the vulnerable HashCollisionBug contract with specified artifact
    const HashCollisionBugFactory = await ethers.getContractFactory("HashCollisionBug", {
      sourceName: 'contracts/Hash-collisions.sol' // Specify exact artifact
    });
    hashCollisionBug = await HashCollisionBugFactory.deploy();
    await hashCollisionBug.deployed();
  });

  it("Should detect hash collision and revert transaction", async function () {
    // Craft inputs that will cause a hash collision
    const string1A = "AAA";
    const string2A = "BBB";
    const string1B = "AA";
    const string2B = "ABBB";

    // Deposit with the first combination, should succeed
    await hashCollisionBug.connect(owner).deposit(string1A, string2A, {
      value: ethers.utils.parseEther("1"),
    });

    // Attempt deposit with the second combination that should cause a hash collision
    await expect(
      hashCollisionBug.connect(owner).deposit(string1B, string2B, {
        value: ethers.utils.parseEther("0.5"),
      })
    ).to.be.revertedWith("Hash collision detected");
  });

  it("Explore another potential vulnerability", async function () {
    // This space can be used to explore logical flaws if the collision protection was bypassed
    // Often checking surrounding logic for flaws beyond simple hash checks
    // Current call expected to fail by default due to existing collision check

    const string1 = "Known";
    const string2 = "Flaw";

    // Try to capture any unusual behavior aside from main known flaw
    await hashCollisionBug.connect(owner).deposit(string1, string2, {
      value: ethers.utils.parseEther("1"),
    });

    const hash = await hashCollisionBug.createHash(string1, string2);
    const balance = await hashCollisionBug.balances(hash);

    // Expect the balance to reflect the deposit correctly without manipulation
    expect(balance).to.equal(ethers.utils.parseEther("1"));
  });
});