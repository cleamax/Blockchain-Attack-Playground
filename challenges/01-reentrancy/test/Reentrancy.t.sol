// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../contracts/Vulnerable.sol";
import "../exploit/Attacker.sol";

contract ReentrancyTest is Test {
    SimpleBank bank;
    Attacker attacker;
    address user = address(0xBEEF);

    function setUp() public {
        bank = new SimpleBank();

        // Honest user deposits 5 ETH
        vm.deal(user, 5 ether);
        vm.prank(user);
        bank.deposit{value: 5 ether}();

        // Prepare attacker: ensure attacker contract has a balance inside the bank
        attacker = new Attacker(bank);
        vm.deal(address(attacker), 1 ether);
        (bool ok, ) = address(bank).call{value: 1 ether}(abi.encodeWithSignature("deposit()"));
        require(ok, "deposit failed");
    }

    function testExploitDrainsBank() public {
        uint256 beforeBal = address(bank).balance;
        attacker.attack(1 ether);
        uint256 afterBal = address(bank).balance;

        assertLt(afterBal, beforeBal, "bank should be drained");
        assertGt(address(attacker).balance, 0, "attacker should profit");
    }
}
