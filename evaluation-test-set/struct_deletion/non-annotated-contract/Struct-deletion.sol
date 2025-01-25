// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract StructDeletionBug {
    struct MyStruct {
        uint256 id;
        mapping(uint256 => bool) flags;
    }

    mapping(uint256 => MyStruct) public myStructs;

    function addStruct(uint256 structId, uint256 flagKeys) public {
        MyStruct storage newStruct = myStructs[structId];
        newStruct.id = structId;
        newStruct.flags[flagKeys] = true;
    }

    function getStruct(
        uint256 structId,
        uint256 flagKeys
    ) public view returns (uint256, bool) {
        MyStruct storage myStruct = myStructs[structId];
        bool keys = myStruct.flags[flagKeys];
        return (myStruct.id, keys);
    }

    function deleteStruct(uint256 structId) public {
        MyStruct storage myStruct = myStructs[structId];
        delete myStructs[structId];
    }
}
