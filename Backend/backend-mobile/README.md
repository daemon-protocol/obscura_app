# Obscura PER — Backend Mobile

Anchor smart contract for **Obscura Private Ephemeral Rollups**, combining:

- **MagicBlock Ephemeral Rollups** — sub-second transaction finality via delegation
- **MagicBlock Private ER (PER)** — TEE-based account privacy
- **Light Protocol ZK Compression** — ~1000x cheaper on-chain storage
- **Helius** — RPC provider with compression API support

## Quick Start

```bash
# Install dependencies
npm install

# Build the program
anchor build

# Get your program ID
anchor keys list

# Update the program ID in:
# 1. Anchor.toml  →  [programs.devnet]
# 2. programs/obscura-per/src/lib.rs  →  declare_id!("...")

# Rebuild with correct program ID
anchor build

# Deploy to devnet (using Helius RPC)
anchor deploy --provider.cluster devnet \
  --provider.connection "https://devnet.helius-rpc.com/?api-key=YOUR_KEY"

# Run tests
anchor test
```

## Architecture

```
programs/obscura-per/src/lib.rs
├── create_vault        — Create a privacy vault PDA
├── delegate_vault      — Delegate to ER validator (fast) or TEE validator (private)
├── private_transfer    — Transfer within ER, then commit + undelegate
├── commit_vault_state  — Checkpoint state to L1 without undelegating
├── undelegate_vault    — Return account to L1
├── deposit             — Deposit SOL into vault
├── withdraw            — Withdraw SOL from vault
└── create_permission   — PER access control (who can read private state)
```

## MagicBlock Validators (Devnet)

| Region | Pubkey                                         |
| ------ | ---------------------------------------------- |
| Asia   | `MAS1Dt9qreoRMQ14YQuhg8UTZMMzDdKhmkZMECCzk57`  |
| EU     | `MEUGGrYPxKk17hCr7wpT6s8dtNokZj5U2L57vjYMS8e`  |
| US     | `MUS3hc9TCw4cGC12vHNoYcCGzJG1txjgQLZWVoeNHNd`  |
| TEE    | `FnE6VJT5QNZdedZPnCoLsARgBwoE6DeJNjBs2H1gySXA` |

## Key Programs

- **Delegation**: `DELeGGvXpWV2fqJUhqcF5ZSYMS4JTLjteaAMARRSaeSh`
- **Access Control**: `ACLseoPoyC3cBqoUtkbjZ4aDrkurZW86v19pXz2XQnp1`
