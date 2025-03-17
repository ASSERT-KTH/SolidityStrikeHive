// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/*
Name: Unchecked return value

Description:
EIP20 standard:
Returns a boolean value indicating whether the operation succeeded.
function transfer(address to, uint256 amount) external returns (bool);

USDT doesn't correctly implement the EIP20 standard,
so calling these functions with the correct EIP20 function signatures will always revert.
function transfer(address to, uint256 value) external;

ERC20 transfer:
    function transfer(address to, uint256 amount) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

USDT transfer without a return value:
    function transfer(address _to, uint _value) public onlyPayloadSize(2 * 32) {
        ...
        }
        Transfer(msg.sender, _to, sendAmount);
    }

Mitigation:
Use OpenZeppelin’s SafeERC20 library and change transfer to safeTransfer.

REF:
https://twitter.com/1nf0s3cpt/status/1600868995007410176

*/
interface USDT {
    function transfer(address to, uint256 value) external;

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 value) external;
}
