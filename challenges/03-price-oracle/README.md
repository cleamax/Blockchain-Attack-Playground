# Challenge 03 – Price Oracle Manipulation

**Severity:** High  
**Category:** Economic Attack / Oracle Manipulation

This challenge shows how relying on a **spot price from a thin-liquidity AMM** allows attackers to inflate the collateral value and **borrow more than they should**.

---

## 🎯 Goal
Manipulate the AMM price so that a small amount of `TokenA` (collateral) is valued extremely high in `TokenB`, then **borrow** `TokenB` from the lending pool and drain its treasury.

---

## 🧩 Components
- `Token.sol` – minimal ERC20 with `mint` for local testing  
- `AMM.sol` – constant product AMM (`x*y=k`), **no fees**, **no TWAP**, spot price only  
- `LendingPool.sol` – values collateral using `amm.getPriceAToB()` (**spot**), LTV = 100% (demo)  
- `exploit/Attacker.sol` – manipulates price and borrows against the manipulated oracle  
- `test/OracleManipulation.t.sol` – Foundry test proving the attack

---

## 🔍 Vulnerability
- The lending pool trusts a **single on-chain spot price** from the AMM:  
  `priceAToB = reserveB / reserveA`.  
- With **low liquidity**, an attacker can swap a large `TokenB` amount to buy `TokenA`, shifting reserves so that **A's price pumps**, then deposit a tiny amount of A as collateral and borrow excessive B.

---

## ▶️ Run locally
```bash
forge test -vv -m testExploitOracleManipulation
```

---

## 🛡️ How to fix (ideas)
- Use a **TWAP** oracle (time-weighted) or external oracle (e.g., Chainlink)  
- Apply **collateral factors / LTV < 100%** and **caps**  
- Add **cooldown** or **separate price observation window**  
- Use **multiple sources** (median/mean of oracles)

---

## 📂 Files
```text
challenges/03-price-oracle/
├─ README.md
├─ contracts/
│  ├─ AMM.sol
│  ├─ LendingPool.sol
│  └─ Token.sol
├─ exploit/
│  └─ Attacker.sol
└─ test/
   └─ OracleManipulation.t.sol
```
