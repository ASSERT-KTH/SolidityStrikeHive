// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Dirtybytes.sol";

contract DirtybytesExploit {
    Dirtybytes public vulnerableContract;

    constructor(address _vulnerableContract) {
        vulnerableContract = Dirtybytes(_vulnerableContract);
    }

    function exploitDirtybytes() public {
        // Trigger the h() function to expose the dirty bytes
        vulnerableContract.h();
    }

    function getCorruptedBytes() public returns (bytes memory) {
        // Interacting with the state-modifying function
        return vulnerableContract.h();
    }
}