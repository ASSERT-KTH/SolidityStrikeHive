// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract MaliciousProposal2 {
    uint256 public number = 2;
    function executeProposal() external {
        //ignore the logic
    }
    function emergencyStop() public virtual {
        selfdestruct(payable(address(0)));
    }
}