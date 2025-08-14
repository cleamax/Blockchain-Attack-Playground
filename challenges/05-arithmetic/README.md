# Challenge 05 – Arithmetic Underflow

**Severity:** Medium  
**Category:** Arithmetic / Underflow

This challenge shows how combining a **wrong precondition** with an `unchecked` subtraction can still create a classic **underflow** in Solidity ≥0.8 — even though overflow checks are enabled by default.

---

## 🎯 Goal
Exploit an **underflow** in `BuggyBank.withdraw()` to inflate your recorded balance and **drain** the bank via repeated withdrawals.

---

## 🧩 Components
- `contracts/Vulnerable.sol` — `BuggyBank` with:
  - `require(balances[msg.sender] >= amount)` (**fee ignored**)
  - `unchecked { balances[msg.sender] -= (amount + fee); }` (**can underflow**)
- `exploit/Attacker.sol` — triggers the underflow once, then loops withdrawals
- `test/Arithmetic.t.sol` — Foundry test proving the drain

---

## 🔍 Vulnerability
`withdraw(amount)` validates **only** that `balance >= amount`, but then subtracts **`amount + fee`** inside `unchecked`.  
If a user’s balance is exactly `amount` and the fee is `> 0`, the subtraction wraps to ~`2^256 - fee`, making the recorded balance practically unlimited.

**Buggy excerpt (concept):**
```solidity
require(balances[msg.sender] >= amount, "insufficient"); // ❌ fee ignored
uint256 fee = (amount * feeBps) / 10_000;
unchecked {
    balances[msg.sender] -= (amount + fee); // ❌ underflow if balance == amount
}
```

---

## ▶️ How to run locally
From the repository root:
```bash
forge test -vv -m testExploitArithmeticUnderflow
```

**Expected:** the test passes, the bank’s ETH balance decreases significantly, and the attacker gains ETH.

---

## 🛡️ How to fix
- Validate the **full debit**:
  ```solidity
  require(balances[msg.sender] >= amount + fee, "insufficient");
  ```
- Avoid `unchecked` unless you can prove it cannot wrap.
- Consider safe math patterns/libraries and explicit fee accounting.

---

## 📂 File map
```text
challenges/05-arithmetic/
├─ README.md
├─ contracts/
│  └─ Vulnerable.sol
├─ exploit/
│  └─ Attacker.sol
└─ test/
   └─ Arithmetic.t.sol
```
