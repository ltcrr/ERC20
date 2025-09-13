# SWU Token (SwearU) - ERC20 Smart Contract

This project is an ERC-20 token implementation with additional features including **capped supply, staking rewards, token claim, burn, and transaction tax**. It is built using OpenZeppelin contracts for security and best practices.

---

## 📌 Token Overview

- **Name:** SwearU
- **Symbol:** SWU
- **Decimals:** 18
- **Total Supply Cap:** 1,000,000 SWU
- **Initial Supply:** Defined at deployment
- **Network:** Ethereum / EVM-compatible chains

---

## 🛠️ Features

### 1. **ERC-20 Core**
- Standard ERC-20 functionality: transfer, approve, transferFrom.
- Implements a **capped supply** via `ERC20Capped` to limit the maximum number of tokens.

### 2. **Ownership**
- Contract is `Ownable`.
- Owner can mint additional tokens through a dedicated `devMint` function.

### 3. **Token Claim**
- Users can claim **100 SWU tokens once** via the `claimToken()` function.
- Prevents multiple claims by the same address.

### 4. **Burning Tokens**
- Users can burn their tokens to reduce total supply using `burnTokens()`.

### 5. **Transaction Tax**
- `taxRate` is set to **4% (400 / 10000)**.
- Tax is automatically deducted from transfers and sent to the **taxRecipient** (default is contract owner).
- Supports adjustable tax logic if needed.

### 6. **Staking & Rewards**
- Users can stake their tokens via `stake(amount)` and unstake via `unstake(amount)`.
- Rewards accrue over time at a fixed **reward rate** (`1e16`) per token per second.
- Claim rewards anytime with `claimRewards()`.

---

## ⚡ How It Works

1. **Transfer with Tax:**  
   Every token transfer calculates a fee and sends it to the tax recipient. Remaining tokens go to the recipient.

2. **Staking:**  
   - Users transfer tokens to the contract to stake.  
   - Rewards are automatically calculated based on staking duration and amount.  
   - Users can unstake partially or fully; rewards are claimed automatically on stake/unstake actions.

3. **Token Claiming:**  
   - Each address can claim a fixed amount of tokens once.  
   - Uses a mapping to track whether an address has claimed.

---

## 🚀 Deployment

### Constructor Parameters
- `initialSupply`: Initial supply of tokens minted to deployer in **SWU**.

### Example (Hardhat)
```javascript
const Token = await ethers.getContractFactory("token");
const token = await Token.deploy(100_000); // 100,000 SWU initial supply
await token.deployed();
console.log("SWU deployed to:", token.address);
