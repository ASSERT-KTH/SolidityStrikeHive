// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Proxy {
    address public owner = address(0xdeadbeef);
    Delegate delegate;

    constructor(address _delegateAddress) public {
        delegate = Delegate(_delegateAddress);
    }

    fallback() external {
        (bool suc, ) = address(delegate).delegatecall(msg.data);
        require(suc, "Delegatecall failed");
    }
}

contract Delegate {
    address public owner;

    function pwn() public {
        owner = msg.sender;
    }
}
