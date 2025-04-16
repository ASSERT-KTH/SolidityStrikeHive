const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("VulnVault", function () {
  let vulnVault, sta, maliciousAttacker, deployer, user1, user2;

  beforeEach(async function () {
    [deployer, user1, user2] = await ethers.getSigners();

    // Deploy STA token
    const STA = await ethers.getContractFactory("STA");
    sta = await STA.deploy();
    await sta.deployed();

    // Mint STA tokens for the users
    await sta.transfer(user1.address, ethers.utils.parseEther("1000"));
    await sta.transfer(user2.address, ethers.utils.parseEther("1000"));

    // Deploy VulnVault
    const VulnVault = await ethers.getContractFactory("VulnVault");
    vulnVault = await VulnVault.deploy(sta.address);
    await vulnVault.deployed();

    // Deploy MaliciousAttacker
    const MaliciousAttacker = await ethers.getContractFactory("MaliciousAttacker");
    maliciousAttacker = await MaliciousAttacker.deploy(vulnVault.address, sta.address);
    await maliciousAttacker.deployed();
  });

  it("Should allow the malicious attacker to drain the VulnVault contract", async function () {
    // Approve the VulnVault contract to spend STA tokens on behalf of user1
    await sta.connect(user1).approve(vulnVault.address, ethers.utils.parseEther("1000"));

    // Deposit STA tokens into the VulnVault
    await vulnVault.connect(user1).deposit(ethers.utils.parseEther("100"));

    // Simulate the malicious attacker's actions
    await maliciousAttacker.connect(user1).attack();

    // Verify that the malicious attacker has drained the VulnVault contract
    expect(await sta.balanceOf(vulnVault.address)).to.equal(0);
    expect(await sta.balanceOf(user1.address)).to.be.greaterThan(ethers.utils.parseEther("100"));
  });

  it("Should correctly handle fee-on-transfer token deposits", async function () {
    // Approve the VulnVault contract to spend STA tokens on behalf of user2
    await sta.connect(user2).approve(vulnVault.address, ethers.utils.parseEther("1000"));

    // Deposit STA tokens into the VulnVault
    await vulnVault.connect(user2).deposit(ethers.utils.parseEther("100"));

    // Verify that the user's balance in the VulnVault is reduced by the fee
    const depositedBalance = await vulnVault.getBalance(user2.address);
    const fee = ethers.utils.parseEther("1"); // 1% of 100
    expect(depositedBalance).to.equal(ethers.utils.parseEther("100").sub(fee));
  });
});