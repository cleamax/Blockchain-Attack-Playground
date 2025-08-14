// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// In Foundry reicht ein Contract mit Funktionen, die mit "test" anfangen.
// Kein forge-std nötig.
contract DummyTest {
    function test_ok() public pure {
        assert(true);
    }
}
