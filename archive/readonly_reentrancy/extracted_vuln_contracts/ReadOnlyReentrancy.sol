// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "./interface.sol";
/*
Name: Read-Only Reentrancy Vulnerability

Description:
The Read-Only Reentrancy Vulnerability is a flaw in smart contract design that allows attackers 
to exploit the "read-only" nature of a function to make unintended changes to the contract's state. 
Specifically, the vulnerability arises when an attacker uses the remove_liquidity function of the ICurve contract 
to trigger the receive function in the ExploitContract. This is achieved by an external call 
from a secure smart contract "A" invoking the fallback() function in the attacker's contract.

Through this exploit, the attacker gains the ability to execute code within the fallback() function
against a target contract "B," which is indirectly related to contract "A." Contract "B" derives
the price of the LP token from Contract "A," making it susceptible to manipulation and unintended price changes
through the reentrancy attack.

Mitigation:
Avoid any state-changing operations within functions that are intended to be read-only.
Makerdao example:
        // This will revert if called during execution of a state-modifying pool function.
        if (nonreentrant) {
            uint256[2] calldata amounts;
            CurvePoolLike(pool).remove_liquidity(0, amounts);
        }

REF
https://twitter.com/1nf0s3cpt/status/1590622114834706432
https://chainsecurity.com/heartbreaks-curve-lp-oracles/
https://medium.com/@zokyo.io/read-only-reentrancy-attacks-understanding-the-threat-to-your-smart-contracts-99444c0a7334
https://www.youtube.com/watch?v=0fgGTRlsDxI

*/

interface ICurve {
    function get_virtual_price() external view returns (uint);

    function add_liquidity(
        uint[2] calldata amounts,
        uint min_mint_amount
    ) external payable returns (uint);

    function remove_liquidity(
        uint lp,
        uint[2] calldata min_amounts
    ) external returns (uint[2] memory);

    function remove_liquidity_one_coin(
        uint lp,
        int128 i,
        uint min_amount
    ) external returns (uint);
}

address constant STETH_POOL = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022;
address constant LP_TOKEN = 0x06325440D014e39736583c165C2963BA99fAf14E; //steCRV Token

// VulnContract
// users stake LP_TOKEN
// getReward rewards the users based on the current price of the pool LP token
contract VulnContract {
    IERC20 public constant token = IERC20(LP_TOKEN);
    ICurve private constant pool = ICurve(STETH_POOL);

    mapping(address => uint) public balanceOf;

    function stake(uint amount) external {
        token.transferFrom(msg.sender, address(this), amount);
        balanceOf[msg.sender] += amount;
    }

    function unstake(uint amount) external {
        balanceOf[msg.sender] -= amount;
        token.transfer(msg.sender, amount);
    }

    function getReward() external view returns (uint) {
        //rewarding tokens based on the current virtual price of the pool LP token
        uint reward = (balanceOf[msg.sender] * pool.get_virtual_price()) /
            1 ether;
        // Omitting code to transfer reward tokens
        return reward;
    }
}