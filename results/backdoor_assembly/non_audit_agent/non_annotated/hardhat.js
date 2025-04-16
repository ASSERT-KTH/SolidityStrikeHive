const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('LotteryGame', function() {
  let LotteryGame, lotteryGame, MaliciousContract, maliciousContract, owner, attacker;

  beforeEach(async function() {
    [owner, attacker] = await ethers.getSigners();

    // Deploy LotteryGame contract
    LotteryGame = await ethers.getContractFactory('LotteryGame');
    lotteryGame = await LotteryGame.deploy();
    await lotteryGame.deployed();

    // Deploy MaliciousContract
    MaliciousContract = await ethers.getContractFactory('MaliciousContract');
    maliciousContract = await MaliciousContract.deploy(lotteryGame.address);
    await maliciousContract.deployed();
  });

  it('should allow the malicious contract to bypass the safeCheck modifier and set the winner', async function() {
    // Initially, the winner should not be set
    expect(await lotteryGame.getkWinner()).to.equal(ethers.constants.AddressZero);

    // Exploit the vulnerability using the malicious contract
    await maliciousContract.exploit(attacker.address);

    // Verify that the winner is set to the attacker's address
    expect(await lotteryGame.getkWinner()).to.equal(attacker.address);
  });

  it('should fail to set the winner if the modifier is not bypassed', async function() {
    // Attempt to directly set the winner without bypassing the modifier
    await expect(lotteryGame.pickWinner(attacker.address)).to.be.revertedWith('');
  });
});