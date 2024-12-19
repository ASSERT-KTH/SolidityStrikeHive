// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./MaliciousProposal.sol";
import "./MaliciousProposal2.sol";

contract Factory {
    uint256 public number = 256;

    event printAddress(address index);
    function createProposal() public returns (address) {
        MaliciousProposal a = new MaliciousProposal();
        emit printAddress(address(a));
        return address(a);
    }


    function createProposal2() public returns (address) {
        MaliciousProposal2 b = new MaliciousProposal2();
        emit printAddress(address(b));
        return address(b);
    }

    function emergencyStop() public  {
        selfdestruct(payable(address(msg.sender)));
    }
}