// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../contracts/Vulnerable.sol";
import "../exploit/Attacker.sol";

contract AccessControlTest is Test {
    AdminVault vault;
    Attacker attacker;
    address user = address(0xBEEF);
    address payable attackerEOA = payable(address(0xA11CE)); // target for sweep()

    function setUp() public {
        // Deploy vault and initially fund it
        vault = new AdminVault{value: 5 ether}();

        // Honest user sends an additional 3 ETH
        vm.deal(user, 3 ether);
        vm.prank(user);
        (bool ok, ) = address(vault).call{value: 3 ether}("");
        require(ok, "funding fail");

        // Deploy attacker contract; Owner = attackerEOA (receives later payout)
        vm.prank(attackerEOA);
        attacker = new Attacker(vault);
    }

    function testExploitDrainsVault() public {
        uint256 beforeBal = address(vault).balance;

        attacker.pwn(); // grantAdmin -> sweep to attackerEOA

        uint256 afterBal = address(vault).balance;

        assertEq(afterBal, 0, "vault should be empty");
        assertGt(attackerEOA.balance, 0, "attacker EOA should receive funds");
        assertGt(beforeBal, afterBal, "balance must decrease");
    }
}
