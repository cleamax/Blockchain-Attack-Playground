// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Vulnerable proxy-like contract misusing delegatecall
/// @notice Intentionally insecure: lets the caller choose the logic contract
contract Vulnerable {
    // ⚠️ Kritisch: 'owner' liegt im Slot 0 und kann via delegatecall überschrieben werden
    address public owner;
    uint256 public num;
    address public sender;
    uint256 public value;

    constructor() payable {
        owner = msg.sender; // Deployer ist zunächst Owner
    }

    /// @notice supposed to call trusted logic, but allows any target
    function setVars(address _logic, uint256 _num) public payable {
        // ⚠️ UNSAFE: delegatecall in fremden Code mit dem Storage dieses Contracts
        (bool ok, ) = _logic.delegatecall(abi.encodeWithSignature("setVars(uint256)", _num));
        require(ok, "delegatecall failed");
    }

    function _onlyOwner() internal view {
        require(msg.sender == owner, "not owner");
    }

    /// @notice Demo-Funktion, die zeigt, wie fatal Owner-Übernahme ist
    function sweep(address payable to) external {
        _onlyOwner();
        to.transfer(address(this).balance);
    }

    receive() external payable {}
}

/// @title Example "legit" logic contract (würde korrekt funktionieren)
contract LogicContract {
    uint256 public num;
    address public sender;
    uint256 public value;

    function setVars(uint256 _num) public payable {
        num = _num;
        sender = msg.sender;
        value = msg.value;
    }
}
