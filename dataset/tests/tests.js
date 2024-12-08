const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PrivateBank Reentrancy Test", function() {
  let privateBank;
  let maliciousContract;
  let owner;
  let attacker;
  let addr1;
  
  beforeEach(async function() {
    // Get signers
    [owner, attacker, addr1] = await ethers.getSigners();
    
    // Deploy Log contract
    const Log = await ethers.getContractFactory("Log");
    const log = await Log.deploy();
    await log.deployed();
    
    // Deploy PrivateBank contract
    const PrivateBank = await ethers.getContractFactory("PrivateBank");
    privateBank = await PrivateBank.deploy(log.address);
    await privateBank.deployed();
    
    // Deploy Malicious contract
    const MaliciousContract = await ethers.getContractFactory("ReentrancyExploit");
    maliciousContract = await MaliciousContract.deploy(privateBank.address);
    await maliciousContract.deployed();
  });

  describe("Initial Setup", function() {
    it("Should allow legitimate deposits", async function() {
      const depositAmount = ethers.utils.parseEther("1.0");
      
      await privateBank.connect(addr1).Deposit({
        value: depositAmount
      });
      
      const balance = await privateBank.balances(addr1.address);
      expect(balance).to.equal(depositAmount);
    });

    it("Should allow legitimate withdrawals", async function() {
      const depositAmount = ethers.utils.parseEther("1.0");
      
      await privateBank.connect(addr1).Deposit({
        value: depositAmount
      });
      
      await privateBank.connect(addr1).CashOut(depositAmount);
      
      const balance = await privateBank.balances(addr1.address);
      expect(balance).to.equal(0);
    });
  });

  describe("Reentrancy Attack", function() {
    it("Should be vulnerable to reentrancy attack", async function() {
      // Initial setup - deposit some ETH to the bank
      const initialDeposit = ethers.utils.parseEther("5.0");
      await privateBank.Deposit({ value: initialDeposit });
      
      // Fund malicious contract
      const attackFunds = ethers.utils.parseEther("1.0");
      await maliciousContract.connect(attacker).Deposit({ 
        value: attackFunds 
      });

      // Get initial balances
      const initialBankBalance = await ethers.provider.getBalance(privateBank.address);
      const initialAttackerBalance = await ethers.provider.getBalance(maliciousContract.address);

      // Execute attack
      await maliciousContract.connect(attacker).attack();

      // Get final balances
      const finalBankBalance = await ethers.provider.getBalance(privateBank.address);
      const finalAttackerBalance = await ethers.provider.getBalance(maliciousContract.address);

      // Verify attack was successful
      expect(finalBankBalance).to.be.lt(initialBankBalance);
      expect(finalAttackerBalance).to.be.gt(initialAttackerBalance);
    });

    it("Should drain most of the bank's funds", async function() {
      // Setup initial bank balance
      const bankFunds = ethers.utils.parseEther("10.0");
      await privateBank.Deposit({ value: bankFunds });
      
      // Setup attacker
      const attackFunds = ethers.utils.parseEther("1.0");
      await maliciousContract.connect(attacker).Deposit({ 
        value: attackFunds 
      });

      // Execute attack
      await maliciousContract.connect(attacker).attack();

      // Check bank is mostly drained
      const finalBankBalance = await ethers.provider.getBalance(privateBank.address);
      expect(finalBankBalance).to.be.lt(ethers.utils.parseEther("0.1"));
    });
  });

  describe("Post-Attack State", function() {
    it("Should fail legitimate withdrawals after attack", async function() {
      // Initial setup
      const depositAmount = ethers.utils.parseEther("1.0");
      await privateBank.connect(addr1).Deposit({
        value: depositAmount
      });
      
      // Execute attack that drains the contract
      const attackFunds = ethers.utils.parseEther("1.0");
      await maliciousContract.connect(attacker).Deposit({ 
        value: attackFunds 
      });
      await maliciousContract.connect(attacker).attack();

      // Try legitimate withdrawal
      await expect(
        privateBank.connect(addr1).CashOut(depositAmount)
      ).to.be.reverted;
    });

    it("Should show incorrect balances after attack", async function() {
      const depositAmount = ethers.utils.parseEther("1.0");
      
      // Legitimate user deposits
      await privateBank.connect(addr1).Deposit({
        value: depositAmount
      });
      
      // Attack drains the contract
      await maliciousContract.connect(attacker).Deposit({ 
        value: depositAmount 
      });
      await maliciousContract.connect(attacker).attack();

      // Check balances
      const userBalance = await privateBank.balances(addr1.address);
      const contractBalance = await ethers.provider.getBalance(privateBank.address);
      
      // User balance in mapping should still show deposit amount
      expect(userBalance).to.equal(depositAmount);
      // But actual contract balance should be near zero
      expect(contractBalance).to.be.lt(depositAmount);
    });
  });
});