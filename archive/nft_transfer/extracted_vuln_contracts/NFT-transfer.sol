// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/*
Name: Unauthorized NFT Transfer in custom ERC721 implementation.

Description:
Custom transferFrom function in contract VulnerableERC721, 
does not properly check if msg.sender is the current owner of the token or an approved address.
As a result, any address can call the transferFrom function to transfer any token, 
regardless of who the current owner is. 
This allows unauthorized users to transfer tokens they do not own, leading to potential theft of assets.

 
Mitigation:  
To ensure that msg.sender is the current owner of the token or an approved address.

REF:
https://twitter.com/1nf0s3cpt/status/1679120390281412609
https://blog.decurity.io/scanning-for-vulnerable-erc721-implementations-fe19200b91b5
https://ventral.digital/posts/2022/8/18/sznsdaos-bountyboard-unauthorized-transferfrom-vulnerability
https://github.com/pessimistic-io/slitherin/blob/master/docs/nft_approve_warning.md
*/


contract VulnerableERC721 is ERC721, Ownable {
    constructor() ERC721("MyNFT", "MNFT") {}

    //custom transferFrom function which missing NFT owner check.
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        // direct transfer
        _transfer(from, to, tokenId);
    }

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }
}
