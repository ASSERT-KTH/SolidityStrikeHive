const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("HashCollisionBug", function () {
  let HashCollisionBug, contract, owner, addr1, addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    HashCollisionBug = await ethers.getContractFactory("HashCollisionBug");
    contract = await HashCollisionBug.deploy();
    await contract.deployed();
  });

  it("Should allow deposit overwriting due to hash collision", async function () {
    // Deposit with inputs that produce the same hash causing collision
    await contract.connect(addr1).deposit("AAA", "BBB", { value: ethers.utils.parseEther("0.01") });
    await expect(contract.connect(addr2).deposit("AA", "ABBB", { value: ethers.utils.parseEther("1") })).to.be.revertedWith("Hash collision detected");

    // Expect overwriting will not occur because the contract should detect the collision
    const balance1 = await contract.balances(await contract.createHash("AAA", "BBB"));
    expect(balance1).to.equal(ethers.utils.parseEther("0.01"));
  });

  it("Should not allow deposit overwriting when no hash collision", async function () {
    // Deposit with inputs that do not produce a hash collision
    await contract.connect(addr1).deposit("AAA", "BBB", { value: ethers.utils.parseEther("0.5") });
    await contract.connect(addr2).deposit("AA", "CCCC", { value: ethers.utils.parseEther("0.5") });

    // Check that both deposits are preserved
    const balance2 = await ethers.provider.getBalance(contract.address);
    expect(balance2).to.equal(ethers.utils.parseEther("1"));
  });
});