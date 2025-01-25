// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

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