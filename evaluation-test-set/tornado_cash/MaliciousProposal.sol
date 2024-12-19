// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract MaliciousProposal {
    uint256 public number = 1;
    function executeProposal() external {
        //ignore the logic
    }
    function emergencyStop() public virtual {
        selfdestruct(payable(address(0)));
    }
}