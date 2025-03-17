// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract BankContractBug {
    struct Bank {
        address bankAddress;
        string bankName;
    }

    Bank[] public banks;

    function addBanks(
        address[] memory bankAddresses,
        string[] memory bankNames
    ) public {
        require(
            bankAddresses.length == bankNames.length,
            "Input arrays must have the same length."
        );

        for (uint i = 0; i < bankAddresses.length; i++) {
            if (bankAddresses[i] == address(0)) {
                continue;
            }

            for (i = 0; i < bankAddresses.length; i++) {
                banks.push(Bank(bankAddresses[i], bankNames[i]));
                return;
            }
        }
    }

    function getBankCount() public view returns (uint) {
        return banks.length;
    }
}
