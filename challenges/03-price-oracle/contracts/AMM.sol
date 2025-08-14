// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Token.sol";

/// @title Ultra-simple x*y=k AMM pair (A <-> B), no fees, unsafe on purpose
contract SimpleAMM {
    ERC20Mintable public immutable tokenA;
    ERC20Mintable public immutable tokenB;

    uint256 public reserveA;
    uint256 public reserveB;

    constructor(ERC20Mintable _a, ERC20Mintable _b) {
        tokenA = _a;
        tokenB = _b;
    }

    function _update(uint256 a, uint256 b) internal {
        reserveA = a;
        reserveB = b;
    }

    /// @notice add initial liquidity (no LP tokens, demo only)
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        require(reserveA == 0 && reserveB == 0, "already seeded");
        require(tokenA.transferFrom(msg.sender, address(this), amountA), "transfer A");
        require(tokenB.transferFrom(msg.sender, address(this), amountB), "transfer B");
        _update(amountA, amountB);
    }

    /// @notice price = how many B for 1 A (spot)
    function getPriceAToB() external view returns (uint256 price1e18) {
        require(reserveA > 0 && reserveB > 0, "no reserves");
        //  price = reserveB / reserveA (scaled by 1e18)
        return (reserveB * 1e18) / reserveA;
    }

    /// @notice swap exact B in for A out (no fee)
    function swapBForA(uint256 amountBIn) external returns (uint256 amountAOut) {
        require(amountBIn > 0, "amountIn=0");
        require(tokenB.transferFrom(msg.sender, address(this), amountBIn), "xferB in");
        uint256 newReserveB = reserveB + amountBIn;
        // constant product: (reserveA - out) * (reserveB + in) = reserveA * reserveB
        amountAOut = (reserveA * amountBIn) / newReserveB;
        require(amountAOut < reserveA, "insufficient A");
        reserveA -= amountAOut;
        reserveB = newReserveB;
        require(tokenA.transfer(msg.sender, amountAOut), "xferA out");
    }

    /// @notice swap exact A in for B out (no fee)
    function swapAForB(uint256 amountAIn) external returns (uint256 amountBOut) {
        require(amountAIn > 0, "amountIn=0");
        require(tokenA.transferFrom(msg.sender, address(this), amountAIn), "xferA in");
        uint256 newReserveA = reserveA + amountAIn;
        amountBOut = (reserveB * amountAIn) / newReserveA;
        require(amountBOut < reserveB, "insufficient B");
        reserveB -= amountBOut;
        reserveA = newReserveA;
        require(tokenB.transfer(msg.sender, amountBOut), "xferB out");
    }
}
