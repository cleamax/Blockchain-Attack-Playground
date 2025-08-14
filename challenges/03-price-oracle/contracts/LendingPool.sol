// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Token.sol";
import "./AMM.sol";

/// @title Vulnerable lending pool using spot price from AMM (manipulable oracle)
contract LendingPool {
    ERC20Mintable public immutable tokenA; // collateral
    ERC20Mintable public immutable tokenB; // borrow asset
    SimpleAMM public immutable amm;

    mapping(address => uint256) public collateralA;
    mapping(address => uint256) public debtB;

    constructor(ERC20Mintable _a, ERC20Mintable _b, SimpleAMM _amm) {
        tokenA = _a;
        tokenB = _b;
        amm = _amm;
    }

    /// @notice deposit A as collateral
    function depositCollateral(uint256 amountA) external {
        require(tokenA.transferFrom(msg.sender, address(this), amountA), "xfer A in");
        collateralA[msg.sender] += amountA;
    }

    /// @notice borrow B valuing collateral with *spot price* from AMM (⚠️ manipulable)
    /// LTV = 100% for simplicity (demo!)
    function borrow(uint256 amountB) external {
        uint256 priceAToB = amm.getPriceAToB(); // ⚠️ spot oracle
        // value of collateral in B
        uint256 valueB = (collateralA[msg.sender] * priceAToB) / 1e18;
        require(valueB >= debtB[msg.sender] + amountB, "insufficient collateral");
        debtB[msg.sender] += amountB;
        require(tokenB.transfer(msg.sender, amountB), "xfer B out");
    }
}
