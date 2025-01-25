// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "./interface.sol";

// this excersise is about direct token manipulation

interface ISpace {
    function onSwap(
        SwapRequest memory request,
        uint256 reservesTokenIn,
        uint256 reservesTokenOut
    ) external returns (uint256);

    struct SwapRequest {
        IVault.SwapKind kind;
        IERC20 tokenIn;
        IERC20 tokenOut;
        uint256 amount;
        // Misc data
        bytes32 poolId;
        uint256 lastChangeBlock;
        address from;
        address to;
        bytes userData;
    }
}

interface IVault {
    enum SwapKind {
        GIVEN_IN,
        GIVEN_OUT
    }
}
