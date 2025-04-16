const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("HashCollisionBug", function () {
  let hashCollisionBugContract;
  let maliciousContract;
  let owner, attacker;

  beforeEach(async function () {
    [owner, attacker] = await ethers.getSigners();

    const HashCollisionBug = await ethers.getContractFactory("HashCollisionBug");
    hashCollisionBugContract = await HashCollisionBug.deploy();
    await hashCollisionBugContract.deployed();

    const MaliciousHashCollisionExploit = await ethers.getContractFactory("MaliciousHashCollisionExploit");
    maliciousContract = await MaliciousHashCollisionExploit.deploy(hashCollisionBugContract.address);
    await maliciousContract.deployed();
  });

  it("should detect hash collision vulnerability", async function () {
    const initialHash = await hashCollisionBugContract.createHash("AAA", "BBB");
    const collisionHash = await hashCollisionBugContract.createHash("AA", "ABBB");

    expect(initialHash).to.equal(collisionHash);

    await hashCollisionBugContract.connect(owner).deposit("AAA", "BBB", { value: ethers.utils.parseEther("1") });
    await expect(
      hashCollisionBugContract.connect(attacker).deposit("AA", "ABBB", { value: ethers.utils.parseEther("1") })
    ).to.be.revertedWith("Hash collision detected");
  });

  it("should confirm unauthorized access due to hash collision", async function () {
    await owner.sendTransaction({
      to: maliciousContract.address,
      value: ethers.utils.parseEther("2")
    });

    const attackerBalanceBefore = await ethers.provider.getBalance(attacker.address);

    // Attempting to exploit the hash collision
    await maliciousContract.connect(attacker).exploitHashCollision();

    const attackerBalanceAfter = await ethers.provider.getBalance(attacker.address);

    expect(attackerBalanceAfter).to.be.gt(attackerBalanceBefore);
  });
});