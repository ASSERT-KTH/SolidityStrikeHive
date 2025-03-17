// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

/*
Name: Unprotected callback - ERC721 SafeMint reentrancy

Description:
The contract ContractTest is exploiting a callback feature to bypass the maximum mint limit 
set by the MaxMint721 contract. This is achieved by triggering the onERC721Received function,
which internally calls the mint function again. Therefore, although MaxMint721 attempts 
to limit the number of tokens that a user can mint to MAX_PER_USER, the ContractTest contract 
successfully mints more tokens than this limit. 

Scenario:
This excersise is about a contract that via callback function to mint more NFTs

Mitigation:
Follow check-effect-interaction and use OpenZeppelin Reentrancy Guard.

REF
https://blocksecteam.medium.com/when-safemint-becomes-unsafe-lessons-from-the-hypebears-security-incident-2965209bda2a
https://www.paradigm.xyz/2021/08/the-dangers-of-surprising-code

*/

contract MaxMint721 is ERC721Enumerable {
    uint256 public MAX_PER_USER = 10;

    constructor() ERC721("ERC721", "ERC721") {}

    function mint(uint256 amount) external {
        require(
            balanceOf(msg.sender) + amount <= MAX_PER_USER,
            "exceed max per user"
        );
        for (uint256 i = 0; i < amount; i++) {
            uint256 mintIndex = totalSupply();
            _safeMint(msg.sender, mintIndex);
        }
    }
}