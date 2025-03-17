// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/*
Name: Use of return in inner loop iteration leads to unintended termination. 

Description:
BankContractBug's addBanks function exhibits an incorrect usage of the return statement within a loop iteration, 
resulting in unintended termination of the loop. The return statement is placed inside the inner loop, 
causing premature exit from the function before completing the iteration over all bank addresses. 

Mitigation:  
Use break instead of return

REF:
https://twitter.com/1nf0s3cpt/status/1678596730865221632
https://github.com/code-423n4/2022-03-lifinance-findings/issues/34
https://solidity-by-example.org/loop/

*/

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

            // i++ is not executed when return is executed
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
