// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/*
Name: Predictable Randomness Vulnerability

Description:
Use of global variables like block hash, block number, 
block timestamp and other fields is insecure, miner and attacker can control it.

Scenario:
GuessTheRandomNumber is a game where you win 1 Ether if you can guess the
pseudo random number generated from block hash and timestamp.

At first glance, it seems impossible to guess the correct number.
But let's see how easy it is win.

1. Alice deploys GuessTheRandomNumber with 1 Ether
2. Eve deploys Attack
3. Eve calls Attack.attack() and wins 1 Ether

What happened?
Attack computed the correct answer by simply copying the code that computes the random number.

Mitigation:
Don't use blockhash and block.timestamp as source of randomness

REF:
https://solidity-by-example.org/hacks/randomness/
 
*/

contract GuessTheRandomNumber {
    constructor() payable {}

    function guess(uint _guess) public {
        uint answer = uint(
            keccak256(
                abi.encodePacked(blockhash(block.number - 1), block.timestamp)
            )
        );

        if (_guess == answer) {
            (bool sent, ) = msg.sender.call{value: 1 ether}("");
            require(sent, "Failed to send Ether");
        }
    }
}
