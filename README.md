# 🧩 ALTAI Participation Contract

> **"Empowering users to participate, earn, and redeem within the ALTAI ecosystem."**

The **ALTAI Participation Contract** is a decentralized smart contract that enables users to deposit supported tokens into participation pools, accumulate rewards over time, claim them securely, and redeem their deposits at any moment.  
It serves as a **core yield participation mechanism** within the **ALTAI Protocol** ecosystem.

---

## 📘 Table of Contents

[Overview](#-overview)

[Contract Summary](#-contract-summary)

[Key Features](#-key-features)

[Security & Access Control](#-security--access-control)

[Technical Details](#-technical-details)

[Resources](#-resources)

---

## 🌍 Overview

The Participation Contract provides a robust system for user-driven participation in token pools, designed with transparency and modularity.  
Each pool operates independently, featuring its own parameters such as minimum deposit amount, reward rate, and liquidity reserves.

Users can:

Join active participation pools

Earn rewards based on their deposits and pool conditions

Claim or redeem their assets anytime

Interact directly with verified BEP-20/ERC-20 tokens

---

## ⚙️ Contract Summary

| **Attribute**    | **Description**                                                  |
| ---------------- | ---------------------------------------------------------------- |
| **Language**     | Solidity `0.8.30`                                                |
| **Standard**     | BEP-20 / ERC-20 compatible                                       |
| **Dependencies** | Custom library `LibParticipation`, OpenZeppelin-style interfaces |
| **Security**     | ReentrancyGuard, Owner-only management, EOA enforcement          |
| **Network**      | BNB Smart Chain (Mainnet & Testnet)                              |
| **License**      | MIT                                                              |

---

## 🧠 Key Features

✅ **Multi-Pool Support**  
Allows creation and management of multiple token pools with unique configurations.

💰 **Reward Accumulation System**  
Users earn rewards over time based on their participation and pool parameters.

🔒 **Non-Reentrant Operations**  
All financial functions are protected against reentrancy attacks.

👤 **EOA-Only Participation**  
Restricts contract interactions to externally owned accounts (no contracts).

⚙️ **Owner-Controlled Parameters**  
Admins can update pool settings, adjust reward rates, and add liquidity.

🔥 **Claim & Redeem Functions**  
Participants can claim earned rewards or withdraw deposits at any time.

---

## 🧱 Security & Access Control

| **Role**                  | **Privileges**                                                 |
| ------------------------- | -------------------------------------------------------------- |
| **Owner (Admin)**         | Add liquidity, configure pools, pause operations, rescue funds |
| **User (EOA)**            | Participate, claim rewards, redeem deposits                    |
| **Contract Restrictions** | Non-reentrant, validated pool status, EOA checks               |

**Protection Mechanisms:**
`ReentrancyGuard` for safe reward/claim calls

`onlyEOA` modifier preventing smart contracts from interacting

`onlyOwner` for administrative methods

Fallback protection in `rescueNative` and `rescueERC20`

---

## 🔧 Technical Details

| **Function**                                                                  | **Purpose**                                        |
| ----------------------------------------------------------------------------- | -------------------------------------------------- |
| `participation(uint256 _amountIn, address _tokenIn)`                          | Join a pool and deposit tokens                     |
| `claim(address _tokenIn)`                                                     | Claim earned rewards                               |
| `redeem(address _tokenIn)`                                                    | Withdraw participation and claim remaining rewards |
| `addLiquidity(uint256 _amountIn, address _tokenIn)`                           | Add reward liquidity to a pool (owner only)        |
| `setParticipationPool(address _tokenIn, TParticipationPool calldata _params)` | Configure pool parameters                          |
| `setParticipationVariables(TParticipationVariables calldata _params)`         | Adjust global participation settings               |
| `getRewards(address _tokenIn, address _user)`                                 | View accumulated rewards                           |
| `getUser(address _tokenIn, address _user)`                                    | Retrieve user data                                 |
| `getParticipationPool(address _tokenIn)`                                      | Retrieve pool details                              |

---

## 📄 Resources

**Whitepaper:** [Gitbook](https://altai.gitbook.io/docs/ecosystem/commodities)  
**Website:** [ALTAI](https://altai.exchange)  
**Email:** [Contact](mailto:contact@altai.exchange)

---

© 2025 ALTAI Protocol. All rights reserved.
