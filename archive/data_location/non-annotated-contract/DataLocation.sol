// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Array {
    mapping(address => UserInfo) public userInfo; // storage

    struct UserInfo {
        uint256 amount; // How many tokens got staked by user.
        uint256 rewardDebt; // Reward debt. See Explanation below.
    }

    function updaterewardDebt(uint amount) public {
        UserInfo memory user = userInfo[msg.sender];
        user.rewardDebt = amount;
    }
}