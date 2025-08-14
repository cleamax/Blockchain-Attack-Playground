// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../contracts/Vulnerable.sol";
import "../exploit/Attacker.sol";

contract AccessControlTest is Test {
    AdminVault vault;
    Attacker attacker;
    address user = address(0xBEEF);

    function setUp() public {
        // deploy vault and fund it
        vault = new AdminVault{value: 5 ether}();

        // honest user also sends some ETH to the vault
        vm.deal(user, 3 ether);
        vm.prank(user);
        (bool ok, ) = address(vault).call{value: 3 ether}("");
        require(ok, "funding fail");

        // deploy attacker
        attacker = new Attacker(vault);
    }

    function testExploitDrainsVault() public {
        uint256 beforeBal = address(vault).balance;
        attacker.pwn();
        uint256 afterBal = address(vault).balance;

        assertEq(afterBal, 0, "vault should be empty");
        assertGt(address(attacker.owner()).balance, 0, "attacker should receive funds");
        assertGt(beforeBal, afterBal, "balance must decrease");
    }
}
