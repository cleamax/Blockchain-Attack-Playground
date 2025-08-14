# 🛡️ Blockchain Attack Playground

**An open-source collection of vulnerable smart contracts, exploits, and professional-style security write-ups — built for learning, practicing, and showcasing blockchain security skills.**

![CI](https://img.shields.io/github/actions/workflow/status/YOUR_GITHUB_USERNAME/blockchain-attack-playground/ci.yml?label=tests&style=flat-square)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)
![Solidity](https://img.shields.io/badge/solidity-%5E0.8.x-blue?style=flat-square)

---

## 📖 About
The **Blockchain Attack Playground** demonstrates real-world vulnerabilities found in Ethereum smart contracts.

Each challenge includes:
- A **vulnerable contract** (`Vulnerable.sol`)
- An **exploit contract or script** that demonstrates the attack
- A **detailed audit-style write-up** (impact, PoC, fix)
- Automated **Foundry tests** proving the exploit works

**Who is this for?**
- Security researchers sharpening their smart contract security skills
- Developers learning secure smart contract patterns
- Recruiters & companies reviewing practical blockchain security work

---

## 🎯 Features
- Covers a wide range of **real-world blockchain vulnerabilities**: Reentrancy, Access Control flaws, Price Oracle manipulation, `delegatecall` misuse, arithmetic errors, front-running/MEV, and more
- **Professional-style security write-ups** for each challenge, including vulnerability explanation, impact assessment, proof of concept, and mitigation
- Fully reproducible **local testing environment** using [Foundry](https://book.getfoundry.sh/) — easy for anyone to run and verify
- **Continuous Integration** setup with GitHub Actions to ensure all tests pass on every commit
- Clear, modular folder structure that makes it easy to navigate, extend, or adapt for new attack vectors
- Designed to serve as a **learning resource, practice lab, and portfolio project** for blockchain security roles

---

## 📂 Project Structure
```text
blockchain-attack-playground/
├─ README.md
├─ challenges/
│  ├─ 01-reentrancy/
│  │  ├─ README.md                 # Challenge-specific description, PoC, and fix
│  │  ├─ contracts/
│  │  │  └─ Vulnerable.sol         # Vulnerable contract
│  │  ├─ exploit/
│  │  │  └─ Attacker.sol           # Exploit contract (or script)
│  │  └─ test/
│  │     └─ Reentrancy.t.sol       # Foundry test proving the exploit
│  ├─ 02-access-control/
│  ├─ 03-price-oracle/
│  ├─ 04-delegatecall/
│  └─ 05-arithmetic/
├─ foundry.toml
└─ .github/
   └─ workflows/
      └─ ci.yml                    # CI: forge test
🚀 Getting Started
1) Install Foundry
bash
Copy
Edit
curl -L https://foundry.paradigm.xyz | bash
foundryup
2) Clone the repository
bash
Copy
Edit
git clone https://github.com/YOUR_GITHUB_USERNAME/blockchain-attack-playground.git
cd blockchain-attack-playground
3) Run all tests
bash
Copy
Edit
forge test -vv
🧪 Current Challenges
ID	Name	Severity	Status
01	Reentrancy Attack	Critical	✅ Done
02	Access Control Flaw	High	🔄 WIP
03	Price Oracle Manipulation	High	🔄 WIP
04	delegatecall Misuse	High	🔄 WIP
05	Arithmetic / Under/Overflow	Medium	🔄 WIP

Each challenge folder contains: Vulnerable Code → Exploit → Tests → Fix Recommendations.

🧱 Tech Stack
Solidity 0.8.x

Foundry (forge, cast)

Optional: Node.js for helper scripts

Linting/Formatting: solhint, prettier

🛡️ Security Best Practices Highlighted
Checks-Effects-Interactions pattern

ReentrancyGuard & Pull-Payments

Proper Role-Based Access Control (onlyOwner / roles)

Secure oracle design

Safe use of delegatecall & storage layouts

Safe arithmetic and edge case handling

➕ Adding a New Challenge (Quick Guide)
Create a new folder under challenges/NN-name/

Add contracts/Vulnerable.sol, exploit/…, test/…

Write a README.md with: Story → Goal → Vulnerability → PoC Steps → Fix → References

Run local tests with forge test -vv

Commit and open a Pull Request

🧰 Continuous Integration
This repository uses GitHub Actions to run all Foundry tests on every push or pull request.
The CI workflow is defined in .github/workflows/ci.yml.

📜 License
MIT — free to use, modify, and share.

## 💬 Contact
Created by **Maximilian Richter** — aspiring Smart Contract Security Engineer.

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Profile-blue?style=flat-square&logo=linkedin)](https://www.linkedin.com/in/maximilian-richter-40697a298)

