# SimpleEscrow

A lightweight, portfolio‑ready **Escrow smart contract** written in Solidity.

This repository demonstrates how to implement a basic escrow service supporting **ETH** and **ERC‑20** payments, with role‑based permissions and dispute handling.

---

## Features

* ✅ **Supports ETH and ERC‑20 tokens**
* ✅ Roles: `depositor`, `beneficiary`, `arbiter`
* ✅ Dispute state & resolution by arbiter
* ✅ Cancel before funding
* ✅ Event‑driven architecture
* ✅ Minimal reentrancy guard

---

## Contract Architecture

| State           | Description                               |
| --------------- | ----------------------------------------- |
| `AWAITING_FUND` | Escrow created, waiting for funds         |
| `FUNDED`        | Funds deposited, pending release          |
| `RELEASED`      | Funds sent to beneficiary                 |
| `REFUNDED`      | Funds returned to depositor               |
| `CANCELLED`     | Deal cancelled before funding             |
| `DISPUTED`      | Dispute raised, awaiting arbiter decision |

### Roles

* **Depositor**: Creates and funds the escrow.
* **Beneficiary**: Receives funds upon release.
* **Arbiter**: Resolves disputes and may refund or release.

### Events

* `EscrowCreated`
* `Funded`
* `Released`
* `Refunded`
* `Cancelled`
* `Disputed`

---

## Getting Started

### 1. Clone & Install

```bash
npm init -y
npm install --save-dev hardhat @nomiclabs/hardhat-ethers ethers
```

### 2. Compile

```bash
npx hardhat compile
```

### 3. Deploy

Create a deploy script (`scripts/deploy.js`):

```javascript
const hre = require("hardhat");

async function main() {
  const Escrow = await hre.ethers.getContractFactory("SimpleEscrow");
  const escrow = await Escrow.deploy();
  await escrow.deployed();
  console.log("SimpleEscrow deployed to:", escrow.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
```

Run:

```bash
npx hardhat run scripts/deploy.js --network <your-network>
```

---

## Usage

### 1️⃣ Create an Escrow

```solidity
uint256 id = escrow.createEscrow(
    beneficiary,
    arbiter,
    address(0), // ETH
    1 ether,
    "Payment for freelance project"
);
```

### 2️⃣ Fund the Escrow

```solidity
escrow.fundEscrow{ value: 1 ether }(id);
```

### 3️⃣ Release or Refund

* `release(id)` → Beneficiary receives funds (called by depositor or arbiter)
* `refund(id)` → Depositor gets funds back (arbiter only)

### 4️⃣ Disputes & Cancel

* `raiseDispute(id)` → Move to `DISPUTED`
* `cancel(id)` → Depositor cancels before funding

---

## Testing (Hardhat + Mocha/Chai)

Example command:

```bash
npx hardhat test
```

Suggested tests:

* Happy path: create → fund → release
* Refund flow via arbiter
* Dispute resolution
* Cancel before funding
* Wrong caller attempts (should revert)
* Reentrancy simulation

---

## Security Notes

> ⚠️ This contract is **for educational and portfolio purposes only**. Do not use it in production without audits and further hardening.

* Use [OpenZeppelin](https://docs.openzeppelin.com/contracts/) libraries (`ReentrancyGuard`, `SafeERC20`) for production.
* Always validate ERC‑20 `transfer` and `transferFrom` returns.
* Consider gas‑efficient dispute resolution or time‑based auto‑refunds.
* Arbiter should ideally be a multisig or DAO for real funds.

---
