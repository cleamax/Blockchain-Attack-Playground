// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title BuggyBank (Arithmetic Underflow)
// Intentionally vulnerable: incorrect require + unchecked subtraction with fee.
contract BuggyBank {
    mapping(address => uint256) public balances;
    uint256 public immutable feeBps; // e.g., 500 = 5%

    constructor(uint256 _feeBps) payable {
        feeBps = _feeBps;
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    /// @notice Withdraw 'amount' Ether; charges a fee in addition to amount.
    /// BUG:
    ///  - The require only checks balances >= amount (fee ignored).
    ///  - The subtraction is inside unchecked, so (balance - (amount + fee)) can underflow.
    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "insufficient"); // ❌ fee not considered

        uint256 fee = (amount * feeBps) / 10_000;
        unchecked {
            // ❌ Underflow if balances[msg.sender] == amount and fee > 0
            balances[msg.sender] -= (amount + fee);
        }

        (bool ok, ) = payable(msg.sender).call{value: amount}("");
        require(ok, "send fail");
    }

    function bankBalance() external view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}
}
