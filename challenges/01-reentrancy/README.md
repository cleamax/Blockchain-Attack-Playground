# Challenge 01 – Reentrancy

**Severity:** Critical  
**Vulnerability ID:** SWC-107 (Reentrancy)

This challenge demonstrates how a naïve withdrawal function allows an attacker to **re-enter** the contract and **drain funds** before the victim’s balance is updated.

---

## 🎯 Goal
Exploit the vulnerable `withdraw()` in `SimpleBank` so the attacker contract steals the bank’s Ether.

---

## 🧩 Contracts in this challenge
- `contracts/Vulnerable.sol` — **SimpleBank** (intentionally vulnerable)
- `exploit/Attacker.sol` — attacker contract that performs the reentrant calls
- `test/Reentrancy.t.sol` — Foundry test proving the exploit

---

## 🔍 Vulnerability
In `withdraw(uint256 amount)` the contract:
1) sends Ether to the caller  
2) **then** decreases the caller’s balance

Because the recipient can be a smart contract, their `receive()`/`fallback()` can **call back into `withdraw()`** before the balance is reduced.

**Anti-pattern (excerpt):**
```solidity
(bool ok, ) = msg.sender.call{value: amount}("");
require(ok, "send fail");
balances[msg.sender] -= amount; // ⚠️ too late – state updated after external call
```

---

## 🧨 Proof of Concept (high level)
1. Honest user deposits **5 ETH** to the bank.  
2. Attacker deposits **1 ETH** (so `balances[attacker] >= 1 ether`).  
3. Attacker calls `attack(1 ether)` → triggers `withdraw(1 ether)`.  
4. During the transfer, attacker’s `receive()` re-enters `withdraw()` **again and again**, draining the bank.

---

## ▶️ How to run locally

From the repository root:

```bash
# run only this challenge's exploit test
forge test -vv -m testExploitDrainsBank
```

If you want to run all tests:
```bash
forge test -vv
```

**Expected result:** the Foundry test passes and shows that the bank’s balance decreases significantly while the attacker gains funds.

---

## ✅ Expected Output (example)
```
[PASS] testExploitDrainsBank() (gas: …)
Logs:
  before: 6.0 ETH
  after :  0.0 ETH
```

---

## 🛡️ How to fix
- Apply **Checks-Effects-Interactions**: update balances **before** the external call.
- Consider **pull-payments** (let users withdraw themselves) instead of pushing Ether.
- Optionally use `ReentrancyGuard` from OpenZeppelin for common patterns.

**Patched example:**
```solidity
function withdraw(uint256 amount) external {
    require(balances[msg.sender] >= amount, "insufficient");
    balances[msg.sender] -= amount;            // ✅ effects first
    (bool ok, ) = msg.sender.call{value: amount}("");
    require(ok, "send fail");
}
```

---

## 📂 File Map
```text
challenges/01-reentrancy/
├─ README.md
├─ contracts/
│  └─ Vulnerable.sol
├─ exploit/
│  └─ Attacker.sol
└─ test/
   └─ Reentrancy.t.sol
```

---

## 📚 References
- SWC-107 Reentrancy — https://swcregistry.io/docs/SWC-107  
- ConsenSys Best Practices (Reentrancy) — https://consensys.github.io/smart-contract-best-practices/known_attacks/#reentrancy  
- Checks-Effects-Interactions — https://fravoll.github.io/solidity-patterns/checks_effects_interactions.html
