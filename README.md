# 🛡️ Blockchain Attack Playground

**Eine kuratierte Sammlung verwundbarer Smart Contracts, Exploits und Security-Writeups – zum Lernen, Üben und als Portfolio-Showcase für Smart-Contract-Security.**

![CI](https://img.shields.io/github/actions/workflow/status/YOUR_GITHUB_USERNAME/blockchain-attack-playground/ci.yml?label=tests&style=flat-square)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)
![Solidity](https://img.shields.io/badge/solidity-%5E0.8.x-blue?style=flat-square)

---

## 📖 About
Der **Blockchain Attack Playground** zeigt reale Schwachstellen aus der Ethereum-Welt – jeweils mit:
- einem **verwundbaren Contract** (`Vulnerable.sol`)
- einem **Exploit** (Contract oder Script)
- einem **Audit-artigen Writeup** (Impact, PoC, Fix)
- automatisierten **Foundry-Tests** als Exploit-Beweis

Zielgruppe:
- Lernende & Forschende in Smart-Contract-Security
- Devs, die sichere Patterns verstehen wollen
- Recruiter:innen, die **praktische Security-Arbeit** sehen wollen

---

## 🎯 Features
- Mehrere Angriffsvektoren: **Reentrancy**, **Access Control**, **Oracle Manipulation**, **delegatecall-Missbrauch**, **arithmetische Fehler**, **Front-Running/MEV** u. a.
- **CertiK-Style Writeups** pro Challenge
- Voll reproduzierbare **Local-Tests** mit [Foundry](https://book.getfoundry.sh/)
- **CI** (GitHub Actions): Tests laufen bei jedem Commit
- Klarer Aufbau – ideal als **Portfolio-Projekt**

---

## 📂 Project Structure

```text
blockchain-attack-playground/
├─ README.md
├─ challenges/
│  ├─ 01-reentrancy/
│  │  ├─ README.md                 # Beschreibung, PoC, Fix
│  │  ├─ contracts/
│  │  │  └─ Vulnerable.sol         # Verwundbarer Contract
│  │  ├─ exploit/
│  │  │  └─ Attacker.sol           # Exploit-Contract (oder Script)
│  │  └─ test/
│  │     └─ Reentrancy.t.sol       # Foundry-Test als Exploit-Beweis
│  ├─ 02-access-control/
│  ├─ 03-price-oracle/
│  ├─ 04-delegatecall/
│  └─ 05-arithmetic/
├─ foundry.toml
└─ .github/
   └─ workflows/
      └─ ci.yml                    # CI: forge test
🚀 Getting Started
1) Foundry installieren
bash
Copy
Edit
curl -L https://foundry.paradigm.xyz | bash
foundryup
2) Repo klonen
bash
Copy
Edit
git clone https://github.com/YOUR_GITHUB_USERNAME/blockchain-attack-playground.git
cd blockchain-attack-playground
3) Tests ausführen
bash
Copy
Edit
forge test -vv
🧪 Aktuelle Challenges
ID	Name	Severity	Status
01	Reentrancy Attack	Critical	✅ Done
02	Access Control Flaw	High	🔄 WIP
03	Price Oracle Manipulation	High	🔄 WIP
04	delegatecall Misuse	High	🔄 WIP
05	Arithmetic / Under/Overflow	Medium	🔄 WIP

Jeder Challenge-Ordner enthält: Vulnerable Code → Exploit → Tests → Fix-Empfehlungen.

🧱 Tech Stack
Solidity 0.8.x

Foundry (forge, cast)

Optional: Node.js für Helper-Scripts

Linting/Style: solhint, prettier

🛡️ Best-Practice-Themes im Projekt
Checks-Effects-Interactions

ReentrancyGuard & Pull-Payments

Sauberes RBAC (onlyOwner/Roles)

Sichere Oracles/TWAP-Design

Vorsicht bei delegatecall & Storage-Layouts

Sichere Arithmetik und Edge-Cases

➕ Neue Challenge hinzufügen (Kurzguide)
Neuen Ordner unter challenges/NN-name/ anlegen

contracts/Vulnerable.sol, exploit/…, test/… hinzufügen

README.md mit: Story → Ziel → Vulnerability → PoC Steps → Fix → References

Lokale Tests: forge test -vv

PR stellen oder Issue öffnen

🧰 CI (GitHub Actions)
Bei jedem Push/PR läuft forge test. Status-Badge siehe oben.
CI-Workflow liegt unter .github/workflows/ci.yml.

📜 License
MIT – frei nutzbar, änderbar, teilbar.

💬 Kontakt
Erstellt von Your Name – angehender Smart-Contract-Security-Engineer.
📬 your.email@example.com • 🔗 LinkedIn: https://linkedin.com/in/yourprofile
