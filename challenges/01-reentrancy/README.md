# Challenge 01 – Reentrancy

**Goal:** Drain the bank by exploiting a reentrancy bug in `withdraw`.

## How it works
- `withdraw()` sends ETH before updating `balances[msg.sender]`.
- The attacker’s `receive()` re-enters `withdraw()` repeatedly.

## Run locally
```bash
forge test -vv -m testExploitDrainsBank
