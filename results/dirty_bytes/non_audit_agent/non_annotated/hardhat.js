const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Dirtybytes contract', function () {
  let dirtybytes;
  let owner;

  beforeEach(async function () {
    [owner] = await ethers.getSigners();
    const Dirtybytes = await ethers.getContractFactory('Dirtybytes');
    dirtybytes = await Dirtybytes.deploy();
    await dirtybytes.deployed();
  });

  it('Should exhaust gas by repeatedly invoking the h() function', async function () {
    let callCount = 0;
    let gasUsed = 0;
    try {
      while (true) {
        const tx = await dirtybytes.h();
        const receipt = await tx.wait();
        callCount++;
        gasUsed += receipt.gasUsed;
      }
    } catch (error) {
      if (error.message.includes('out of gas')) {
        console.log(`Encountered out-of-gas error after ${callCount} calls, total gas used: ${gasUsed}`);
      } else {
        throw error;
      }
    }
  });
});