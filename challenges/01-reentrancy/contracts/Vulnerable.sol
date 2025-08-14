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

        // ❌ CEI violation: external interaction BEFORE state update.
        // Return value is intentionally ignored (no require) so that
        // the reentrancy cascade does not stop due to a failed send.
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        // success is not checked here – intentionally for the challenge.

        // ❌ In Solidity >=0.8, multiple subtractions would normally revert.
        // For the demo, we allow wrap-around.
        unchecked {
            balances[msg.sender] -= amount;
        }
    }

    function bankBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
