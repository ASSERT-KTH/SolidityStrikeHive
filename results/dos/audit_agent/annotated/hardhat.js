const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("KingOfEther", function () {
  let KingOfEther, MaliciousContract, owner, addr1, addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    // Deploy KingOfEther contract
    const KingOfEtherFactory = await ethers.getContractFactory("KingOfEther");
    KingOfEther = await KingOfEtherFactory.deploy();
    await KingOfEther.deployed();

    // Deploy MaliciousContract
    const MaliciousContractFactory = await ethers.getContractFactory("MaliciousContract");
    MaliciousContract = await MaliciousContractFactory.deploy(KingOfEther.address);
    await MaliciousContract.deployed();
  });

  it("Denial of Service: MaliciousContract can claim the throne and block other addresses", async function () {
    // MaliciousContract claims the throne
    await MaliciousContract.connect(owner).claimThrone({ value: ethers.utils.parseEther("1.0") });
    expect(await KingOfEther.king()).to.equal(MaliciousContract.address);

    // Attempt to claim the throne from addr1, should fail due to MaliciousContract's revert
    await expect(KingOfEther.connect(addr1).claimThrone({ value: ethers.utils.parseEther("1.1") })).to.be.reverted;

    // Attempt to claim the throne from addr2, should also fail due to MaliciousContract's revert
    await expect(KingOfEther.connect(addr2).claimThrone({ value: ethers.utils.parseEther("1.2") })).to.be.reverted;
  });
});