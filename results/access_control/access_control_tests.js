const { expect } = require("chai");

describe("Wallet Vulnerability Tests", function () {
  let wallet, maliciousContract, owner, otherAccount;

  beforeEach(async function () {
    // Get signers
    [owner, otherAccount] = await ethers.getSigners();

    // Deploy the Wallet contract
    const Wallet = await ethers.getContractFactory("Wallet");
    wallet = await Wallet.deploy();
    await wallet.waitForDeployment();
    const walletAddress = await wallet.getAddress();
    console.log("Wallet deployed to:", walletAddress);
    // Deploy the MaliciousContract targeting the Wallet
    const MaliciousContract = await ethers.getContractFactory("MaliciousContract");
    maliciousContract = await MaliciousContract.deploy(walletAddress);
    await maliciousContract.waitForDeployment();
  });

  it("should allow excessive growth of bonusCodes via PushBonusCode", async function () {
    // Attempt to exploit by pushing too many bonusCodes
    await expect(maliciousContract.exploitPushBonusCode(5000))
      .to.not.be.reverted;
  });

  it("should underflow bonusCodes length via PopBonusCode", async function () {
    // Fill array with some bonus codes first
    await wallet.PushBonusCode(1);
    await wallet.PushBonusCode(2);

    // Attempt to exploit by calling PopBonusCode excessively
    await expect(maliciousContract.exploitPopBonusCode(3))
      .to.not.be.reverted;
  });

  it("should prevent unauthorized Destroy function calls", async function () {
    // Attempt to self-destruct the Wallet from a non-owner account
    await expect(wallet.connect(otherAccount).Destroy())
      .to.be.reverted;
  });

  it("should allow authorized Destroy function calls", async function () {
    // Destroy by the owner should succeed
    await expect(wallet.Destroy())
      .to.be.fulfilled;
  });

});