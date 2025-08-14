// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../contracts/Vulnerable.sol";
import "../exploit/Attacker.sol";

contract ReentrancyTest is Test {
    SimpleBank bank;
    Attacker attacker;
    address user = address(0xBEEF);
    address payable attackerEOA = payable(address(0xA11CE)); // empfängt Profit

    function setUp() public {
        bank = new SimpleBank();

        // Honest user deposit: 5 ETH
        vm.deal(user, 5 ether);
        vm.prank(user);
        bank.deposit{value: 5 ether}();

        // Attacker-Contract deployen; Owner = attackerEOA
        vm.prank(attackerEOA);
        attacker = new Attacker(bank);

        // Dem Attacker-Contract 1 ETH gutschreiben UND als Attacker einzahlen,
        // damit balances[attacker] >= 1 ether ist (für den initialen Withdraw-Check)
        vm.deal(address(attacker), 1 ether);
        vm.prank(address(attacker)); // msg.sender = attacker
        bank.deposit{value: 1 ether}();
    }

    function testExploitDrainsBank() public {
        uint256 beforeBal = address(bank).balance;

        // Start des Angriffs
        attacker.attack(1 ether);

        uint256 afterBal = address(bank).balance;

        assertLt(afterBal, beforeBal, "bank should be drained");
        assertGt(attackerEOA.balance, 0, "attacker EOA should profit");
    }
}
