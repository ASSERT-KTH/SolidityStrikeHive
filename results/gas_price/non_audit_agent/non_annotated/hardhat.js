const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("GasReimbursement", function () {
  let GasReimbursement, gasReimbursement, owner, nonOwner;

  beforeEach(async function () {
    [owner, nonOwner] = await ethers.getSigners();
    GasReimbursement = await ethers.getContractFactory("GasReimbursement");
    gasReimbursement = await GasReimbursement.deploy();
    await gasReimbursement.deployed();
  });

  describe("Gas Price Vulnerability", function () {
    it("Should detect gas price manipulation vulnerability", async function () {
      const manipulatedGasPrice = ethers.utils.parseUnits("1000", "gwei");
      await ethers.provider.send("hardhat_setNextBlockBaseFeePerGas", [
        manipulatedGasPrice.toHexString(),
      ]);

      await expect(
        gasReimbursement
          .connect(nonOwner)
          .executeTransfer(nonOwner.address, { gasPrice: manipulatedGasPrice })
      ).to.be.reverted; 
    });
  });

  describe("Unauthorized Access", function () {
    it("should revert when a non-owner calls executeTransfer", async function () {
      await expect(
        gasReimbursement.connect(nonOwner).executeTransfer(nonOwner.address)
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("should allow the owner to call executeTransfer", async function () {
      await expect(
        gasReimbursement.connect(owner).executeTransfer(nonOwner.address)
      ).to.not.be.reverted;
    });
  });
});