const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("VulnVault and STA Token Vulnerabilities", function () {
  let vulnVault, staToken, maliciousContract;
  let owner, user, attacker;

  beforeEach(async function () {
    [owner, user, attacker] = await ethers.getSigners();

    // Deploy the STA contract
    const STA = await ethers.getContractFactory("STA");
    staToken = await STA.deploy();
    await staToken.deployed();

    // Deploy the VulnVault contract
    const VulnVault = await ethers.getContractFactory("VulnVault");
    vulnVault = await VulnVault.deploy(staToken.address);
    await vulnVault.deployed();

    // Deploy the MaliciousContract with different logic
    const MaliciousContract = await ethers.getContractFactory("MaliciousDifferent");
    maliciousContract = await MaliciousContract.deploy(staToken.address, vulnVault.address);
    await maliciousContract.deployed();
  });

  describe("Reentrancy Attack", function () {
    it("Should allow reentrancy attack on withdraw function", async function () {
      // Approve VulnVault to transfer tokens
      await staToken.connect(attacker).approve(vulnVault.address, 500);

      // Attacker deposits tokens into VulnVault
      await vulnVault.connect(attacker).deposit(500);

      // Attacker starts reentrancy attack
      if (await vulnVault.getBalance(attacker.address) > 0) {
        await expect(maliciousContract.connect(attacker).attack(500)).to.changeTokenBalances(
          staToken,
          [vulnVault, attacker],
          [-500, 500]
        );
      }
    });
  });

  describe("Approve/TransferFrom Race Condition", function () {
    it("Should allow approve/transferFrom race condition attack", async function () {
      // User approves MaliciousContract to spend STA tokens
      await staToken.connect(user).approve(maliciousContract.address, 100);

      // Allow malicious contract to exploit race condition
      await maliciousContract.connect(attacker).attack(100);

      // Validate balance change after attack
      await expect(() => maliciousContract.connect(attacker).attack(100)).to.changeTokenBalances(
        staToken,
        [user, attacker],
        [-100, 100]
      );
    });
  });
});