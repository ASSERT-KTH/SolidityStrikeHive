// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Dirtybytes.sol";

contract MaliciousDirtybytes {
    Dirtybytes public dirtybytes;

    constructor(address dirtybytesAddress) {
        dirtybytes = Dirtybytes(dirtybytesAddress);
    }

    function attack() public {
        while (true) {
            dirtybytes.h();
        }
    }
}