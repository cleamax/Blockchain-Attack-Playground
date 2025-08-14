// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title SimpleBank (intentionally vulnerable to reentrancy)
contract SimpleBank {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    // VULNERABLE: external call before state update
    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "insufficient");
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "send fail");
        balances[msg.sender] -= amount; // too late -> reentrancy possible
    }

    function bankBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
