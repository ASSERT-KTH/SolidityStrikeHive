// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/*
Name: Data Location Confusion Vulnerability

Description:
Misuse of storage and memory references of the user in the updaterewardDebt function.

The function updaterewardDebt is updating the rewardDebt value of a UserInfo struct 
that is stored in memory. The issue is that this won't persist between function calls. 
As soon as the function finishes executing, the memory is cleared and the changes are lost.

Mitigation:
Ensure the correct usage of memory and storage in the function parameters. Make all the locations explicit.

REF:
https://mudit.blog/cover-protocol-hack-analysis-tokens-minted-exploit/
https://www.educative.io/answers/storage-vs-memory-in-solidity

*/

contract Array {
    mapping(address => UserInfo) public userInfo; // storage

    struct UserInfo {
        uint256 amount; // How many tokens got staked by user.
        uint256 rewardDebt; // Reward debt. See Explanation below.
    }

    function updaterewardDebt(uint amount) public {
        UserInfo memory user = userInfo[msg.sender]; // memory, vulnerable point
        user.rewardDebt = amount;
    }
}