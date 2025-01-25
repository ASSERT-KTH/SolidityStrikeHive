// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./interface.sol";

/*
Name: NFT Mint via Exposed Metadata Vulnerability

Description:
The contract is vulnerable to CVE-2022-38217, this could lead to the early disclosure of metadata of all NFTs in the project. 
As a result, attacker can find out valuable NFTs and then target mint of specific NFTs by monitoring mempool 
and sell the NFTs for a profit in secondary market.

The issue is the metadata should be visible after the minting is completed

REF:
https://twitter.com/Supremacy_CA/status/1596176732729769985
https://medium.com/@Supremacy_Official/evilreveal-cve-2022-38217-a-nuclear-weapon-level-generic-vulnerability-buried-under-the-nft-5112724dabb
*/
 