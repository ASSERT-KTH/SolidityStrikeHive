// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/*
Name: Incorrect implementation of the recoverERC20() function in the StakingRewards

Description:
The recoverERC20() function in StakingRewards.sol can potentially serve as a backdoor for the owner to retrieve rewardsToken.
There is no corresponding check against the rewardsToken. This creates an administrative privilege where the owner can sweep the rewards tokens, potentially using it as a means to exploit depositors.
It's similar to a forked issue if you forked vulnerable code.
 
Mitigation:  
disallowing recovery of the rewardToken within the recoverErc20 function

REF:
https://twitter.com/1nf0s3cpt/status/1680806251482189824
https://github.com/code-423n4/2022-02-concur-findings/issues/210
https://github.com/code-423n4/2022-09-y2k-finance-findings/issues/49
https://github.com/code-423n4/2022-10-paladin-findings/issues/40
https://blog.openzeppelin.com/across-token-and-token-distributor-audit#anyone-can-prevent-stakers-from-getting-their-rewards
*/

contract VulnStakingRewards {
    using SafeERC20 for IERC20;

    IERC20 public rewardsToken;
    address public owner;

    event Recovered(address token, uint256 amount);

    constructor(address _rewardsToken) {
        rewardsToken = IERC20(_rewardsToken);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function recoverERC20(
        address tokenAddress,
        uint256 tokenAmount
    ) public onlyOwner {
        IERC20(tokenAddress).safeTransfer(owner, tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }
}

contract RewardToken is ERC20, Ownable {
    constructor() ERC20("Rewardoken", "Reward") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }
}