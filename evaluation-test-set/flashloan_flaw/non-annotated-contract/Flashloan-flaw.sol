// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract SimpleBankBug {
    using SafeERC20 for IERC20;
    IERC20 public USDa;
    LendingPool public lendingPool;

    constructor(address _lendingPoolAddress, address _asset) {
        lendingPool = LendingPool(_lendingPoolAddress);
        USDa = IERC20(_asset);
    }

    function flashLoan(
        uint256 amounts,
        address receiverAddress,
        bytes calldata data
    ) external {
        receiverAddress = address(this);

        lendingPool.flashLoan(amounts, receiverAddress, data);
    }

    function executeOperation(
        uint256 amounts,
        address receiverAddress,
        address _initiator,
        bytes calldata data
    ) external {
        /* Perform your desired logic here
        Open opsition, close opsition, drain funds, etc.
        _closetrade(...) or _opentrade(...)
        */

        // transfer all borrowed assets back to the lending pool
        IERC20(USDa).safeTransfer(address(lendingPool), amounts);
    }
}

contract USDa is ERC20, Ownable {
    constructor() ERC20("USDA", "USDA") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}

interface IFlashLoanReceiver {
    function executeOperation(
        uint256 amounts,
        address receiverAddress,
        address _initiator,
        bytes calldata data
    ) external;
}

contract LendingPool {
    IERC20 public USDa;

    constructor(address _USDA) {
        USDa = IERC20(_USDA);
    }

    function flashLoan(
        uint256 amount,
        address borrower,
        bytes calldata data
    ) public {
        uint256 balanceBefore = USDa.balanceOf(address(this));
        require(balanceBefore >= amount, "Not enough liquidity");
        require(USDa.transfer(borrower, amount), "Flashloan transfer failed");
        IFlashLoanReceiver(borrower).executeOperation(
            amount,
            borrower,
            msg.sender,
            data
        );

        uint256 balanceAfter = USDa.balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "Flashloan not repaid");
    }
}