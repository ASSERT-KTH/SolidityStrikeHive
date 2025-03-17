// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/*
Name: Oracle data feed is insufficiently validated

Description:
Chainlink price feed latestRoundData is used to retrieve price feed from chainlink. 
We need to makes sure that the answer is not negative and  price is not stale.

Mitigation:
latestAnswer function is deprecated. Instead, use the latestRoundData function 
to retrieve the price and make sure to add checks for stale data.

REF:
https://twitter.com/1nf0s3cpt/status/1674611468975878144
https://github.com/sherlock-audit/2023-02-blueberry-judging/issues/94
https://code4rena.com/reports/2022-10-inverse#m-17-chainlink-oracle-data-feed-is-not-sufficiently-validated-and-can-return-stale-price
https://docs.chain.link/data-feeds/historical-data#getrounddata-return-values
*/

interface AggregatorV3Interface {
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}