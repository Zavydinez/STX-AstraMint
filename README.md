# STX-AstraMint Token (STLR)

**A robust Clarity smart contract for managing an enhanced fungible token on the Stacks blockchain.**

---

## 📜 Overview

The **STX-AstraMint** is a high-precision, feature-rich fungible token implemented in the Clarity smart contract language for the Stacks blockchain. It incorporates modern security mechanisms, access control, minting roles, transfer restrictions, and governance token tracking.

---

## ✨ Features

* ✅ **Standard Fungible Token**: Built with `define-fungible-token`.
* 🔐 **Owner Control**: Ownership can be transferred. Owner can pause/unpause the contract.
* 🧑‍⚖️ **Governance Token Tracking**: Maintains voting power per holder.
* ⛔ **Transfer Locking**: Tokens can be locked until a block height.
* 🔄 **Allowance with Expiry**: Token approvals can expire based on block height.
* 🚫 **Blacklisting**: Addresses can be restricted from receiving tokens.
* ⛓️ **Minting Cap**: Enforces a maximum token supply.
* ⚠️ **Transfer Safety**: Prevents self-transfer, overflow, and invalid recipients.
* 📡 **Events**: Custom transfer, mint, and burn event logging using `print`.

---

## 🏗 Contract Structure

### 📦 Constants

* `MAX-SUPPLY`: Max total supply (1 Trillion tokens)
* `PRECISION`: 6 decimal places

### ❗ Error Codes

Handled with custom constants like:

* `ERR-NOT-AUTHORIZED`
* `ERR-INVALID-AMOUNT`
* `ERR-PAUSED`
* ...and more.

### 🗂 Data Variables

* `contract-owner`: Admin of the contract.
* `token-name`, `token-symbol`, `token-decimals`: Token metadata.
* `paused`, `initialized`: Lifecycle states.

### 🧭 Maps

* `allowances`: Maps owner → spender with amount & expiry.
* `locked-tokens`: Prevents token transfers until unlock block height.
* `governance-tokens`: Tracks voting power per address.
* `restricted-addresses`: Blacklisted addresses.
* `minter-roles`: Minter privileges and limits (not fully implemented yet).

---

## 🔧 Public Functions

### 🧾 Metadata and Read-Only

* `get-name`, `get-symbol`, `get-decimals`, `get-total-supply`
* `get-balance (account)`
* `get-allowance (owner spender)`
* `is-locked (address)`

### 🔐 Administrative

* `initialize (name symbol decimals)`
* `set-contract-owner (new-owner)`
* `pause`, `unpause`

### 💰 Token Operations

* `mint (amount recipient)`: Only owner can mint.
* `transfer (amount recipient)`: With governance update.
* `approve (amount spender expiry)`: Allowance with expiration.

---

## 📊 Governance Token Logic

Governance tokens are maintained per account to track influence in future on-chain voting or DAO interactions. This is updated on:

* Minting: Voting power increases with received amount.
* Transfer: Updates sender and recipient power accordingly.

---

## 📍 Event Logging

Though Clarity does not support native event emissions like Ethereum, this contract uses the `print` function to emit structured logs for:

* Transfers
* Minting
* Burning

These are useful for indexers or UI integrations.

---

## 🚫 Security Features

* Prevent transfers to self or zero addresses.
* Allowance expiry mechanism to prevent abuse.
* Locked accounts can’t transfer tokens before unlock height.
* Contract pausing to halt token operations in emergencies.
* Restricted accounts can't receive tokens.

---

## 🧪 Example Deployment Flow

```clarity
;; Step 1: Initialize the token (only once)
(initialize "Stellar Token" "STLR" u6)

;; Step 2: Mint tokens (by owner)
(mint u100000000 (some-principal))

;; Step 3: Transfer
(transfer u100000 (recipient-principal))

;; Step 4: Approve with expiry
(approve u50000 (spender-principal) (+ block-height u100))
```

---

## 📚 Requirements

* **Stacks v2.1+**
* **Clarity language**
* **Clarinet for local development/testing**

---

## 🧪 Tests

You can test the contract using [Clarinet](https://docs.hiro.so/clarinet/get-started/overview):

```bash
clarinet test
```

Make sure you test all edge cases like:

* Transfers from/to restricted or locked addresses
* Paused state enforcement
* Max supply limits
* Allowance expiration

---
