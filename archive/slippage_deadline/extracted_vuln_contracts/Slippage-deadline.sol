// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/*
Name: Slippage - Incorrect deadline & slippage amount

Description:
Slippage: Slippage is the difference between the expected price of a trade 
and the price at which the trade is executed. 
If hardcoded to 0, user will accept a minimum amount of 0 output tokens from the swap.

Deadline: The function sets the deadline to the maximum uint256 value, 
which means the transaction can be executed at any time.

If slippage is set to 0 and there is no deadline, 
users might potentially lose all their tokens.

Mitigation:
Allow the user to specify the slippage & deadline value themselves.

REF:
https://twitter.com/1nf0s3cpt/status/1676118132992405505
*/

interface IUniswapV2Router02 {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

interface IWETH {
    function deposit() external payable;

    function approve(address guy, uint256 wad) external returns (bool);

    function withdraw(uint256 wad) external;
}
