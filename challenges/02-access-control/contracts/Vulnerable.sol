// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title AdminVault (intentionally vulnerable: missing access control)
/// @notice Anyone can grant themselves admin and sweep funds.
contract AdminVault {
    address public owner;
    mapping(address => bool) public isAdmin;

    constructor() payable {
        owner = msg.sender;
        isAdmin[msg.sender] = true;
    }

    // ❌ BUG: no onlyOwner — anyone can become admin
    function grantAdmin(address who) external {
        isAdmin[who] = true;
    }

    function sweep(address payable to) external {
        require(isAdmin[msg.sender], "not admin");
        to.transfer(address(this).balance);
    }

    receive() external payable {}
}
