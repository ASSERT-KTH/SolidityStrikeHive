// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/*
Name: Bypass isContract() validation

Description:
The attacker only needs to write the code in the constructor of the smart contract
to bypass the detection mechanism of whether it is a smart contract.

REF:
https://www.infuy.com/blog/bypass-contract-size-limitations-in-solidity-risks-and-prevention/
*/

contract Target {
    function isContract(address account) public view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.
        uint size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    bool public pwned = false;

    function protected() external {
        require(!isContract(msg.sender), "no contract allowed");
        pwned = true;
    }
}
