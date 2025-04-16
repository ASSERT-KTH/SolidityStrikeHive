const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("LotteryGame", function () {
  let lotteryGame;
  let maliciousAttacker;
  let deployer, attacker;

  beforeEach(async function () {
    [deployer, attacker] = await ethers.getSigners();

    // Deploy the LotteryGame contract
    const LotteryGame = await ethers.getContractFactory("LotteryGame");
    lotteryGame = await LotteryGame.connect(deployer).deploy();
    await lotteryGame.deployed();

    // Deploy the MaliciousAttacker contract, passing the LotteryGame address
    const MaliciousAttacker = await ethers.getContractFactory("MaliciousLotteryExploit");
    maliciousAttacker = await MaliciousAttacker.connect(attacker).deploy(lotteryGame.address);
    await maliciousAttacker.deployed();
  });

  it("Should allow the malicious attacker to overwrite the winner", async function () {
    // Simulate a player winning the lottery
    await lotteryGame.connect(deployer).pickWinner(ethers.utils.getAddress("0x1234567890123456789012345678901234567890"));
    expect(await lotteryGame.getkWinner()).to.equal(ethers.utils.getAddress("0x1234567890123456789012345678901234567890"));

    // Malicious attacker overwrites the winner
    await maliciousAttacker.exploit();
    expect(await lotteryGame.getkWinner()).to.equal(maliciousAttacker.address);
  });

  it("Should bypass the pickWinner checks", async function () {
    // Malicious attacker bypasses the pickWinner checks
    await maliciousAttacker.exploit();
    expect(await lotteryGame.getkWinner()).to.equal(maliciousAttacker.address);
  });
});