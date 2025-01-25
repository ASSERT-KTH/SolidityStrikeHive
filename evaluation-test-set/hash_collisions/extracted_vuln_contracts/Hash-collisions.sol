// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/*
Name: abi.encodePacked() Hash Collisions

Description:
Using abi.encodePacked() with multiple variable length arguments can, 
in certain situations, lead to a hash collision.

Hash functions are designed to be unique for each input, 
but collisions can still occur due to limitations in the hash function's size or the sheer number of possible inputs. 
This is a known issue mentioned:
https://docs.soliditylang.org/en/v0.8.17/abi-spec.html?highlight=collisions#non-standard-packed-mode

In deposit function allows users to deposit Ether into the contract based on two string inputs: _string1 and _string2. 
The contract uses the keccak256 function to generate a unique hash by concatenating these two strings.

If two different combinations of _string1 and _string2 produce the same hash value, a hash collision will occur. 
The code does not handle this scenario properly and allows the second depositor to overwrite the previous deposit.

Mitigation: 
use of abi.encode() instead of abi.encodePacked()

REF:
https://twitter.com/1nf0s3cpt/status/1676476475191750656
https://docs.soliditylang.org/en/v0.8.17/abi-spec.html?highlight=collisions#non-standard-packed-mode
https://swcregistry.io/docs/SWC-133
https://github.com/sherlock-audit/2022-10-nftport-judging/issues/118
*/

contract HashCollisionBug {
    mapping(bytes32 => uint256) public balances;

    function createHash(
        string memory _string1,
        string memory _string2
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_string1, _string2));
    }

    function deposit(
        string memory _string1,
        string memory _string2
    ) external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");

        bytes32 hash = createHash(_string1, _string2);
        // createHash(AAA, BBB) -> AAABBB
        // createHash(AA, ABBB) -> AAABBB
        // Check if the hash already exists in the balances mapping
        require(balances[hash] == 0, "Hash collision detected");

        balances[hash] = msg.value;
    }
}