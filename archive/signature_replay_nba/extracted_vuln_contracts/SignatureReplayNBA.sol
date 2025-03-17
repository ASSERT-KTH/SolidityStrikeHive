// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/*
We use NBA NFT incident as an example.

‘Association NFT’ collection by the NBA, which triggers the ‘Allow list’ to sell out permanently. 

This vulnerability could’ve allowed any malicious entity to mint several NFTs without paying any tokens. 

This contract fails to verify that a signature can be used only once.
*/
interface INBA {
    struct vData {
        bool mint_free;
        uint256 max_mint;
        address from;
        uint256 start;
        uint256 end;
        uint256 eth_price;
        uint256 dust_price;
        bytes signature;
    }

    function mint_approved(
        vData memory info,
        uint256 number_of_items_requested,
        uint16 _batchNumber
    ) external;
}


contract NBA {
    uint16 public batchNumber;

    address signer = 0x669F499e7BA51836BB76F7dD2bc3C1A37a5342D7;
    struct vData {
        bool mint_free;
        uint256 max_mint;
        address from;
        uint256 start;
        uint256 end;
        uint256 eth_price;
        uint256 dust_price;
        bytes signature;
    }

    function mint_approved(
        vData memory info,
        uint256 number_of_items_requested,
        uint16 _batchNumber
    ) external view {
        require(batchNumber == _batchNumber, "!batch");
        // address from = msg.sender;
        require(verify(info), "Unauthorised access secret"); // check whitelist
        console.log(
            "Verified, you are in whitelist! You can mint:",
            number_of_items_requested
        );
        //_mintCards(number_of_items_requested, from);
    }

    function verify(vData memory info) public view returns (bool) {
        require(info.from != address(0), "INVALID_SIGNER");
        bytes memory cat = abi.encode(
            info.from,
            info.start,
            info.end,
            info.eth_price,
            info.dust_price,
            info.max_mint,
            info.mint_free
        );
        // console.log("data-->");
        // console.logBytes(cat);
        bytes32 hash = keccak256(cat);
        // console.log("hash ->");
        //    console.logBytes32(hash);
        require(info.signature.length == 65, "Invalid signature length");
        bytes32 sigR;
        bytes32 sigS;
        uint8 sigV;
        bytes memory signature = info.signature;
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        assembly {
            sigR := mload(add(signature, 0x20))
            sigS := mload(add(signature, 0x40))
            sigV := byte(0, mload(add(signature, 0x60)))
        }

        bytes32 data = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );
        address recovered = ecrecover(data, sigV, sigR, sigS);
        return signer == recovered;
    }
}