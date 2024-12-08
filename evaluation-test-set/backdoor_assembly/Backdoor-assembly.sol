// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

/*
Name: Hidden Backdoor in Contract:

Description:
In this contract, an apparently fair 'LotteryGame' contract is subtly designed to allow
a hidden privilege to the contract deployer/administrator.
This is achieved through the use of assembly level access to storage variables,
where a referee function is designed to provide an administrative backdoor.
The 'pickWinner' function appears to randomly pick a winner, but in reality,
it allows the administrator to set the winner.
This bypasses the usual access controls and can be used to drain the prize pool
by an unauthorized user, acting as a type of rug pull.

An attacker can manipulate smart contracts as a backdoor by writing inline assembly.
Any sensitive parameters can be changed at any time.

Scenario:
Lottery game: anyone can call pickWinner to get prize if you are lucky.
Refers to JST contract backdoor. many rugged style's contract has similar pattern.
Looks like theres is no setwinner function in contract, how admin can rug?
*/

contract LotteryGame {
    uint256 public prize = 1000;
    address public winner;
    address public admin = msg.sender;

    modifier safeCheck() {
        if (msg.sender == referee()) {
            _;
        } else {
            getkWinner();
        }
    }

    function referee() internal view returns (address user) {
        assembly {
            // load admin value at slot 2 of storage
            user := sload(2)
        }
    }

    function pickWinner(address random) public safeCheck {
        assembly {
            // admin backddoor which can set winner address
            sstore(1, random)
        }
    }

    function getkWinner() public view returns (address) {
        console.log("Current winner: ", winner);
        return winner;
    }
}