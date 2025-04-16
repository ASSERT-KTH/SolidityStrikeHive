const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MaliciousBank", function () {
  let simpleBank, maliciousBank, owner, attacker;

  beforeEach(async function () {
    [owner, attacker] = await ethers.getSigners();

    // Deploy SimpleBank contract
    const SimpleBankFactory = await ethers.getContractFactory("SimpleBank");
    simpleBank = await SimpleBankFactory.deploy();
    await simpleBank.deployed();

    // Deploy MaliciousBank contract
    const MaliciousBankFactory = await ethers.getContractFactory("MaliciousBank");
    maliciousBank = await MaliciousBankFactory.deploy(simpleBank.address);
    await maliciousBank.deployed();
  });

  it("Should execute unauthorized transfer through fakeTransfer", async function () {
    // Attacker calls fakeTransfer in MaliciousBank
    const transferAmount = ethers.utils.parseEther("1");
    const recipient = ethers.Wallet.createRandom().address;
    await maliciousBank.connect(attacker).fakeTransfer(recipient, transferAmount);

    // Verify the unauthorized transfer was successful
    expect(await simpleBank.getBalance(recipient)).to.equal(transferAmount);
  });
});