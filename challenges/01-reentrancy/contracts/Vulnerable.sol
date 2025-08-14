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

        // ❌ CEI-Verstoß: externe Interaktion VOR dem State-Update
        // Ignoriere den Rückgabewert, damit keine Reverts die Kaskade abbrechen.
        (bool /*ok*/, ) = msg.sender.call{value: amount}("");

        // ❌ In Solidity >=0.8 würde die mehrfache Subtraktion sonst revertieren.
        // Für die Challenge erlauben wir Wrap-around (Demozweck).
        unchecked {
            balances[msg.sender] -= amount;
        }
    }

    function bankBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
