const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("Overflow Exploit Test", function () {
    let Overflow, overflow, Malicious, malicious;

    beforeEach(async function () {
        Overflow = await ethers.getContractFactory("Overflow");
        overflow = await Overflow.deploy();
        await overflow.deployed();

        Malicious = await ethers.getContractFactory("Malicious");
        malicious = await Malicious.deploy(overflow.address);
        await malicious.deployed();
    });

    it("Should exploit overflow vulnerability", async function () {
        const initialBalance = await overflow.sellerBalance();

        // Execute the exploit
        await malicious.exploit(ethers.constants.MaxUint256); // using large value for overflow

        const finalBalance = await overflow.sellerBalance();

        // Check if overflow effect occurred
        expect(finalBalance).to.be.lt(initialBalance);
    });
});