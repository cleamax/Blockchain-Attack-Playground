# Challenge 02 – Access Control Flaw

**Severity:** High  
**Category:** Missing Authorization / Insecure Role Management

This challenge shows how **missing access control** lets an attacker grant themselves admin privileges and **drain all funds**.

---

## 🎯 Goal
Exploit `AdminVault` by making yourself admin and sweeping the contract’s Ether.

---

## 🧩 Contracts in this challenge
- `contracts/Vulnerable.sol` — **AdminVault** (intentionally vulnerable)
- `exploit/Attacker.sol` — attacker that escalates privileges and drains funds
- `test/AccessControl.t.sol` — Foundry test proving the exploit

---

## 🔍 Vulnerability
`grantAdmin(address)` is callable by **anyone** — there is **no** `onlyOwner` / role check.  
An attacker simply calls `grantAdmin(attacker)` and then `sweep(attacker)`.

**Anti-pattern (excerpt):**
```solidity
function grantAdmin(address who) external {
    isAdmin[who] = true; // ❌ no authorization check
}
```

---

## 🧨 Proof of Concept (high level)
1. Vault is deployed and funded with several ETH.  
2. Attacker calls `grantAdmin(attacker)` to self-assign admin.  
3. Attacker calls `sweep(attacker)` and transfers the entire balance out.

---

## ▶️ How to run locally

From the repository root:

```bash
# run only this challenge's exploit test
forge test -vv -m testExploitDrainsVault
```

If you want to run all tests:
```bash
forge test -vv
```

**Expected result:** the test passes, vault balance becomes `0`, attacker gains funds.

---

## ✅ Expected Output (example)
```
[PASS] testExploitDrainsVault() (gas: …)
```

---

## 🛡️ How to fix
- Enforce **authorization** (`onlyOwner` or roles) on `grantAdmin`.
- Prefer **role-based access control** (e.g., OpenZeppelin `AccessControl`).

**Patched example (minimal):**
```solidity
modifier onlyOwner() {
    require(msg.sender == owner, "not owner");
    _;
}

function grantAdmin(address who) external onlyOwner {
    isAdmin[who] = true; // ✅ guarded
}
```

---

## 📂 File Map
```text
challenges/02-access-control/
├─ README.md
├─ contracts/
│  └─ Vulnerable.sol
├─ exploit/
│  └─ Attacker.sol
└─ test/
   └─ AccessControl.t.sol
```

---

## 📚 References
- OpenZeppelin AccessControl — https://docs.openzeppelin.com/contracts/4.x/access-control  
- Smart Contract Security Best Practices — https://consensys.github.io/smart-contract-best-practices/
