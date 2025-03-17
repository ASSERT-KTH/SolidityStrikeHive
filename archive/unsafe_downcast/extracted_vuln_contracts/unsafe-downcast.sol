// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Import the SafeCast library
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

/*
Name: Unsafe downcasting

Description:
Downcasting from a larger integer type to a smaller one without checks can lead to unexpected behavior 
if the value of the larger integer is outside the range of the smaller one.

Mitigation:  
Make sure consistent uint256, or use openzepplin safeCasting.

REF:
https://twitter.com/1nf0s3cpt/status/1673511868839886849
https://github.com/code-423n4/2022-12-escher-findings/issues/369
https://github.com/sherlock-audit/2022-10-union-finance-judging/issues/96
*/

contract SimpleBank {
    mapping(address => uint) private balances;

    function deposit(uint256 amount) public {
        // Here's the unsafe downcast. If the `amount` is greater than type(uint8).max
        // (which is 255), then only the least significant 8 bits are stored in balance.
        // This could lead to unexpected results due to overflow.
        uint8 balance = uint8(amount);

        // store the balance
        balances[msg.sender] = balance;
    }

    function getBalance() public view returns (uint) {
        return balances[msg.sender];
    }
}
