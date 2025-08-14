// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title SimpleBank (intentionally vulnerable to reentrancy)
contract SimpleBank {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    // VULNERABLE: external call before state update + unchecked subtraction
    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "insufficient");

        // ❌ CEI-Verstoß: externe Interaktion VOR dem State-Update.
        // Rückgabewert wird absichtlich ignoriert (kein require), damit die
        // Reentrancy-Kaskade nicht an einem fehlgeschlagenen send abbricht.
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        // success wird hier nicht ausgewertet – absichtlich für die Challenge.

        // ❌ In Solidity >=0.8 würde mehrfache Subtraktion sonst revertieren.
        // Für die Demo erlauben wir Wrap-around.
        unchecked {
            balances[msg.sender] -= amount;
        }
    }

    function bankBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
