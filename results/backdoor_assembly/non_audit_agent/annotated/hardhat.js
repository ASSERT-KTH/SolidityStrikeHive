const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("LotteryGame", function () {
  let lotteryGame;
  let owner, attacker;

  beforeEach(async function () {
    [owner, attacker] = await ethers.getSigners();
    const LotteryGame = await ethers.getContractFactory("LotteryGame");
    lotteryGame = await LotteryGame.deploy();
    await lotteryGame.deployed();
  });

  it("Should allow the admin to set the winner through the backdoor", async function () {
    await lotteryGame.connect(owner).pickWinner(attacker.address);
    expect(await lotteryGame.winner()).to.equal(attacker.address);
  });

  it("Should revert when a non-admin tries to set the winner", async function () {
    await expect(lotteryGame.connect(attacker).pickWinner(attacker.address)).to.be.revertedWith("Ownable: caller is not the owner");
    expect(await lotteryGame.winner()).to.not.equal(attacker.address);
  });
});