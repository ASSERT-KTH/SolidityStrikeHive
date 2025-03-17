// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Import the SafeCast library
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

contract SimpleBank {
    mapping(address => uint) private balances;

    function deposit(uint256 amount) public {
        uint8 balance = uint8(amount);

        // store the balance
        balances[msg.sender] = balance;
    }

    function getBalance() public view returns (uint) {
        return balances[msg.sender];
    }
}
