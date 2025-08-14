# Challenge 04 – delegatecall Misuse

**Severity:** High  
**Category:** Logic / Storage Hijack via `delegatecall`

This challenge demonstrates how unsafe it is to let users choose an arbitrary **delegatecall target**. Because `delegatecall` executes the callee’s code **in the caller’s storage context**, a malicious target can **overwrite critical variables** (e.g., `owner`) and drain funds.

---

## 🎯 Goal
Use a malicious logic contract to **overwrite `owner`** in `Vulnerable` and then **sweep** the contract’s Ether.

---

## 🧩 Components
- `contracts/Vulnerable.sol` – proxy-like contract that misuses `delegatecall` and stores `owner` in storage slot 0  
- `contracts/Attack.sol` – malicious logic; its `setVars(uint256)` writes to storage slot 0 (`owner`)  
- `test/DelegatecallTest.t.sol` – Foundry test that escalates privileges and drains funds

---

## 🔍 Vulnerability
`Vulnerable.setVars(address _logic, uint256 _num)` performs:

```solidity
(bool ok, ) = _logic.delegatecall(
    abi.encodeWithSignature("setVars(uint256)", _num)
);
require(ok, "delegatecall failed");
```

Because the **caller chooses** `_logic`, an attacker can point it to a contract whose `setVars` **writes to storage slot 0**, thereby changing `owner` in `Vulnerable`. Once `owner` is hijacked, privileged functions like `sweep()` can be called to steal funds.

---

## 🧨 Proof of Concept (high level)
1. Deploy `Vulnerable` and fund it with Ether.  
2. Deploy `Attack` (malicious logic).  
3. Call `Vulnerable.setVars(Attack, 123)` → due to `delegatecall`, `Attack.setVars` runs **in `Vulnerable`’s storage**, setting `owner = msg.sender`.  
4. As the new owner, call `sweep(to)` and drain the contract.

---

## ▶️ Run locally
From the repository root:

```bash
forge test -vv -m testExploitDelegatecallOwnerHijack
```

**Expected:** the test passes, `owner` becomes the attacker, and the funds are swept.

---

## 🛡️ How to fix
- **Do not** allow arbitrary delegatecall targets.  
  - Hard-code a trusted implementation address or use a vetted upgrade pattern (UUPS/Transparent) with strict governance.
- Ensure **storage layout compatibility** between proxy and logic.  
- Prefer **`call`** over `delegatecall` unless mutating the caller’s storage is intended.
- Gate sensitive functions with strong access control (`onlyOwner` / roles), and ensure ownership cannot be arbitrarily overwritten.

**Safer sketch:**
```solidity
address public immutable implementation; // set once in constructor
address public owner;

modifier onlyOwner() { require(msg.sender == owner, "not owner"); _; }

function setVars(uint256 _num) public payable onlyOwner {
    (bool ok, ) = implementation.delegatecall(
        abi.encodeWithSignature("setVars(uint256)", _num)
    );
    require(ok, "delegatecall failed");
}
```

---

## 📂 Files
```text
challenges/04-delegatecall/
├─ README.md
├─ contracts/
│  ├─ Vulnerable.sol
│  └─ Attack.sol
└─ test/
   └─ DelegatecallTest.t.sol
```
