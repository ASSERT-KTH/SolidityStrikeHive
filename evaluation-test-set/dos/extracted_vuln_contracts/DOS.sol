// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/*
Name: Denial of Service

Description:
The KingOfEther contract holds a game where a user can claim the throne by sending more Ether than the current balance.
The contract attempts to return the previous balance to the last "king" when a new user sends more Ether. However,
this mechanism can be exploited. An attacker's contract (here, the Attack contract) can become the king
and then make the fallback function revert or consume more than the stipulated gas limit,
causing the claimThrone function to fail whenever the KingOfEther contract tries to return Ether to the last king.

Mitigation:
Use a Pull payment pattern, A way to prevent this is to enable users to withdraw their Ether, instead of sending it to them.

REF:
https://slowmist.medium.com/intro-to-smart-contract-security-audit-dos-e23e9e901e26
*/

contract KingOfEther {
    address public king;
    uint public balance;

    function claimThrone() external payable {
        require(msg.value > balance, "Need to pay more to become the king");

        (bool sent, ) = king.call{value: balance}("");
        require(sent, "Failed to send Ether");

        balance = msg.value;
        king = msg.sender;
    }
}
