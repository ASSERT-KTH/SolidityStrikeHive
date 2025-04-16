const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("LotteryGame", function () {
  let owner, player1, player2;
  let lotteryGame;

  beforeEach(async function () {
    [owner, player1, player2] = await ethers.getSigners();
    const LotteryGame = await ethers.getContractFactory("LotteryGame");
    lotteryGame = await LotteryGame.deploy();
    await lotteryGame.deployed();
  });

  it("Admin can set the winner's address", async function () {
    await lotteryGame.connect(owner).pickWinner(player1.address);
    expect(await lotteryGame.winner()).to.equal(player1.address);
  });

  it("Non-admin cannot set the winner's address", async function () {
    await expect(lotteryGame.connect(player1).pickWinner(player2.address)).to.be.reverted;
    expect(await lotteryGame.winner()).to.not.equal(player2.address);
  });
});