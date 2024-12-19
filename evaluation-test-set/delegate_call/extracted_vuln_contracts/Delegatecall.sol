// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/*
Name: Unsafe Delegatecall Vulnerability

Description:
The Proxy Contract Owner Manipulation Vulnerability is a flaw in the smart contract design that
allows an attacker to manipulate the owner of the Proxy contract, which is hardcoded as 0xdeadbeef.
The vulnerability arises due to the use of delegatecall in the fallback function of the Proxy contract.
delegatecall allows an attacker to invoke the pwn() function from the Delegate contract within the context
of the Proxy contract, thereby changing the value of the owner state variable of the Proxy contract.
This allows a smart contract to dynamically load code from a different address at runtime.

Scenario:
Proxy Contract is designed for helping users call logic contract
Proxy Contract's owner is hardcoded as 0xdeadbeef
Can you manipulate Proxy Contract's owner ?

Mitigation:
To mitigate the Proxy Contract Owner Manipulation Vulnerability,
avoid using delegatecall unless it is explicitly required, and ensure that the delegatecall is used securely.
If the delegatecall is necessary for the contract's functionality, make sure to validate and
sanitize inputs to avoid unexpected behaviors.
*/

contract Proxy {
    address public owner = address(0xdeadbeef); // slot0
    Delegate delegate;

    constructor(address _delegateAddress) public {
        delegate = Delegate(_delegateAddress);
    }

    fallback() external {
        (bool suc, ) = address(delegate).delegatecall(msg.data); // vulnerable
        require(suc, "Delegatecall failed");
    }
}

contract Delegate {
    address public owner; // slot0

    function pwn() public {
        owner = msg.sender;
    }
}
