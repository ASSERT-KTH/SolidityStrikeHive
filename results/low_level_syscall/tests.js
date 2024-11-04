const { expect } = require("chai");

describe("Malicious Contract Exploit Tests", function () {
    let sendBack;
    let malicious;

    beforeEach(async function () {
        const SendBack = await ethers.getContractFactory("SendBack");
        sendBack = await SendBack.deploy();

        const Malicious = await ethers.getContractFactory("Malicious");
        malicious = await Malicious.deploy(sendBack.address);
    });

    it("Should exploit the unchecked send vulnerability", async function () {
        // First deposit funds into SendBack contract
        await sendBack.deposit({ value: ethers.utils.parseEther("1.0") });

        // Trigger the exploit
        await malicious.exploit();

        // Assert that the balance of the malicious contract has increased
        const balance = await ethers.provider.getBalance(malicious.address);
        expect(balance).to.be.gt(0);
    });
});