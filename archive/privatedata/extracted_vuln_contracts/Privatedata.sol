// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/*
Name: Private Data Exposure

Description:
Solidity stores the variables defined in the contract in slots. Each slot can accommodate up to 32 bytes or 256 bits. Given that all data stored on-chain, whether public or private, can be read, it is possible to read private data from the Vault contract by predicting the memory slot where the private data resides.

If the Vault contract is utilized in a production environment, malicious actors could employ similar techniques to access sensitive information such as user passwords.
Mitigation:
Avoid storing sensitive data on-chain

REF
https://quillaudits.medium.com/accessing-private-data-in-smart-contracts-quillaudits-fe847581ce6d

*/

contract Vault {
    // slot 0
    uint256 private password;

    constructor(uint256 _password) {
        password = _password;
        User memory user = User({id: 0, password: bytes32(_password)});
        users.push(user);
        idToUser[0] = user;
    }

    struct User {
        uint id;
        bytes32 password;
    }

    // slot 1
    User[] public users;
    // slot 2
    mapping(uint => User) public idToUser;

    function getArrayLocation(
        uint slot,
        uint index,
        uint elementSize
    ) public pure returns (bytes32) {
        uint256 a = uint(keccak256(abi.encodePacked(slot))) +
            (index * elementSize);
        return bytes32(a);
    }
}