const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("KingOfEther", function () {
  let king;
  let maliciousContract;
  let attacker;
  
  beforeEach(async function () {
    [king, attacker] = await ethers.getSigners();

    const KingOfEther = await ethers.getContractFactory("KingOfEther");
    king = await KingOfEther.deploy();
    await king.deployed();

    const MaliciousKing = await ethers.getContractFactory("MaliciousKing");
    maliciousContract = await MaliciousKing.deploy(king.address);
    await maliciousContract.deployed();
  });

  it("Should prevent a new king from being crowned if the current king cannot receive Ether", async function () {
    // Malicious contract becomes the king
    await maliciousContract.connect(attacker).attack({ value: ethers.utils.parseEther("1.0") });

    // Attempt to claim the throne by another user
    await expect(
      king.connect(attacker).claimThrone({ value: ethers.utils.parseEther("2.0") })
    ).to.be.revertedWith("Failed to send Ether");

    // Ensure the king and balance remain with the malicious contract
    expect(await king.king()).to.equal(maliciousContract.address);
    expect(await king.balance()).to.equal(ethers.utils.parseEther("1.0"));
  });
});