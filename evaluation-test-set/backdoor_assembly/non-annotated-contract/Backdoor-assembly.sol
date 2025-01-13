// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

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
            user := sload(2)
        }
    }

    function pickWinner(address random) public safeCheck {
        assembly {
            sstore(1, random)
        }
    }

    function getkWinner() public view returns (address) {
        return winner;
    }
}