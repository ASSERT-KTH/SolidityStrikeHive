// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract SimpleBank {
    mapping(address => uint256) private balances;
    address Admin; //default is address(0)

    function getBalance(address _account) public view returns (uint256) {
        return balances[_account];
    }

    function recoverSignerAddress(
        bytes32 _hash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) private pure returns (address) {
        address recoveredAddress = ecrecover(_hash, _v, _r, _s);
        return recoveredAddress;
    }

    function transfer(
        address _to,
        uint256 _amount,
        bytes32 _hash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public {
        require(_to != address(0), "Invalid recipient address");

        address signer = recoverSignerAddress(_hash, _v, _r, _s);
        console.log("signer", signer);
        require(signer == Admin, "Invalid signature");

        balances[_to] += _amount;
    }
}