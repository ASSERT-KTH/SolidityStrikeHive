const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('KingOfEther', () => {
  let KingOfEther, Attacker, owner, player1, player2;

  beforeEach(async () => {
    [owner, player1, player2] = await ethers.getSigners();

    // Deploy the 'KingOfEther' contract
    const KingOfEtherFactory = await ethers.getContractFactory('KingOfEther');
    KingOfEther = await KingOfEtherFactory.deploy();
    await KingOfEther.deployed();

    // Deploy the 'Attacker' contract
    const AttackerFactory = await ethers.getContractFactory('Attacker');
    Attacker = await AttackerFactory.deploy(KingOfEther.address);
    await Attacker.deployed();
  });

  it('Attacker contract should be able to prevent others from becoming the king', async () => {
    // Player 1 tries to become the king
    await KingOfEther.connect(player1).claimThrone({ value: ethers.utils.parseEther('1.0') });
    expect(await KingOfEther.king()).to.equal(player1.address);

    // Attacker contract becomes the king
    await Attacker.connect(owner).attack({ value: ethers.utils.parseEther('2.0') });
    expect(await KingOfEther.king()).to.equal(Attacker.address);

    // Player 2 tries to become the king, but fails due to DOS
    await expect(KingOfEther.connect(player2).claimThrone({ value: ethers.utils.parseEther('3.0') })).to.be.revertedWith('Failed to send Ether');
  });
});