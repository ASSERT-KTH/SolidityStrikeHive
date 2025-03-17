// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/StorageSlot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

interface imp {
    function initialize(address) external;
}

contract Proxy {
    bytes32 internal _IMPLEMENTATION_SLOT = keccak256("where.bug.ser"); // wrong

    constructor(address implementation) {
        _setImplementation(address(0));
        Address.functionDelegateCall(
            implementation,
            abi.encodeWithSignature("initialize(address)", msg.sender)
        );
    }

    fallback() external payable {
        address implementation = _getImplementation();
        Address.functionDelegateCall(implementation, msg.data);
    }

    function _setImplementation(address newImplementation) private {
        StorageSlot
            .getAddressSlot(_IMPLEMENTATION_SLOT)
            .value = newImplementation;
    }

    function _getImplementation() public view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }
}

contract Implementation is Ownable, Initializable {
    // function initialize(address owner) external {    //test purpose
    function initialize(address owner) external initializer {
        _transferOwnership(owner);
    }
}