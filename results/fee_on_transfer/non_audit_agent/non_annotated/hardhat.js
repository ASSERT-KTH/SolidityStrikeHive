// Test suite for detecting reentrancy vulnerabilities in the 'STA' and 'VulnVault' contracts
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("STA and VulnVault Contracts", () => {
  let owner, attacker, victim;
  let staToken, vulnVault, reentrancyAttack;

  beforeEach(async () => {
    [owner, attacker, victim] = await ethers.getSigners();

    // Deploy STA Token
    const STATokenFactory = await ethers.getContractFactory("STA");
    staToken = await STATokenFactory.connect(owner).deploy();
    await staToken.deployed();

    // Deploy VulnVault
    const VulnVaultFactory = await ethers.getContractFactory("VulnVault");
    vulnVault = await VulnVaultFactory.connect(owner).deploy(staToken.address);
    await vulnVault.deployed();

    // Deploy ReentrancyAttack
    const ReentrancyAttackFactory = await ethers.getContractFactory("ReentrancyAttack");
    reentrancyAttack = await ReentrancyAttackFactory.connect(attacker).deploy(vulnVault.address, staToken.address);
    await reentrancyAttack.deployed();

    // Transfer some STA tokens to attacker and victim
    await staToken.connect(owner).transfer(attacker.address, ethers.utils.parseEther("1000"));
    await staToken.connect(owner).transfer(victim.address, ethers.utils.parseEther("1000"));

    // Approve VulnVault to spend attacker's and victim's tokens
    await staToken.connect(attacker).approve(vulnVault.address, ethers.utils.parseEther("1000"));
    await staToken.connect(victim).approve(vulnVault.address, ethers.utils.parseEther("1000"));
  });

  it("Should allow successful reentrancy attack by the attacker", async function () {
    // Deposit tokens into the VulnVault
    await vulnVault.connect(attacker).deposit(ethers.utils.parseEther("500"));

    // Exploit reentrancy vulnerability
    await reentrancyAttack.connect(attacker).attack(ethers.utils.parseEther("500"));

    // Verify attacker's balance has increased
    const attackerFinalBalance = await staToken.balanceOf(attacker.address);
    expect(attackerFinalBalance).to.be.gt(ethers.utils.parseEther("1000"));

    // Verify the vault's balance has decreased incorrectly
    const vaultFinalBalance = await staToken.balanceOf(vulnVault.address);
    expect(vaultFinalBalance).to.be.lt(ethers.utils.parseEther("500"));
  });

  it("Should not allow non-attackers to exploit reentrancy vulnerabilities", async function () {
    // Deposit tokens into the VulnVault
    await vulnVault.connect(victim).deposit(ethers.utils.parseEther("500"));

    // Attempt to exploit reentrancy with non-attacker
    await expect(
      reentrancyAttack.connect(attacker).attack(ethers.utils.parseEther("500"))
    ).to.be.revertedWith("Insufficient balance");

    // Verify victim's balance remains proper
    const victimBalance = await staToken.balanceOf(victim.address);
    expect(victimBalance).to.equal(ethers.utils.parseEther("500"));

    // Verify the vault's balance remains proper
    const vaultBalance = await staToken.balanceOf(vulnVault.address);
    expect(vaultBalance).to.equal(ethers.utils.parseEther("500"));
  });
});