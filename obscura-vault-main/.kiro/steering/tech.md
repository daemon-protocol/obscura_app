# Tech Stack & Build System

## Package Manager
- **pnpm** with workspaces (see `pnpm-workspace.yaml`)
- Node.js ≥ 18.0.0

## TypeScript Configuration
- Target: ES2022
- Module: NodeNext with NodeNext resolution
- Strict mode enabled
- ESM modules (`"type": "module"` in package.json)

## Core Dependencies
| Package | Purpose |
|---------|---------|
| `@noble/hashes` | Cryptographic primitives (SHA-256) |
| `@sip-protocol/sdk` | Privacy layer integration |
| `hono` + `@hono/node-server` | Backend HTTP server |
| `vitest` | Test runner |
| `tsx` | TypeScript execution for dev |

## Smart Contracts

### EVM (Foundry)
- Solidity 0.8.24
- Optimizer enabled (200 runs, via IR)
- Location: `contracts/evm/`
- Config: `foundry.toml`

### Solana (Anchor)
- Anchor 0.30.0
- Rust toolchain 1.75.0
- Location: `contracts/solana/`

## Common Commands

```bash
# Install dependencies
pnpm install

# Build all packages
pnpm build

# Run all tests
pnpm test

# Run crypto package tests only
pnpm test:crypto

# EVM contract commands
pnpm forge:build          # Build contracts
pnpm forge:test           # Run Foundry tests

# Solana contract commands
pnpm anchor:build         # Build Anchor programs

# Backend development
cd packages/backend
pnpm dev                  # Start dev server with hot reload
pnpm start                # Start production server

# Linting
pnpm lint
```

## Environment Variables
| Variable | Description |
|----------|-------------|
| `PORT` | Backend server port (default: 3000) |
| `SOLVER_API_URL` | Solver network endpoint |
| `ETH_RPC_URL` | Ethereum RPC endpoint |
| `ETH_SETTLEMENT_CONTRACT` | Settlement contract address |
| `ETH_VAULT_CONTRACT` | Vault contract address |
| `SOLANA_RPC_URL` | Solana RPC endpoint |
| `HELIUS_API_KEY` | Helius API key for enhanced Solana RPC |
| `PHOTON_URL` | Light Protocol Photon indexer endpoint |
| `ARCIUM_CLUSTER_OFFSET` | Arcium cluster offset (123, 456, or 789 for devnet v0.5.1) |
| `ARCIUM_RPC_URL` | RPC URL for Arcium (use Helius for reliability) |

## Solana Integrations
| Integration | Purpose |
|-------------|---------|
| Helius | Priority fees, webhooks, smart transactions |
| Light Protocol | ZK Compression (~1000x cheaper storage) |
| Arcium | Confidential computing (cSPL + MPC) |

### Arcium Configuration
Arcium Public Testnet runs on Solana Devnet with cluster offsets 123, 456, 789 (all v0.5.1).

```bash
# Required environment variables
ARCIUM_CLUSTER_OFFSET=123
ARCIUM_RPC_URL=https://devnet.helius-rpc.com/?api-key=YOUR_KEY
ARCIUM_PROGRAM_ID=arcaborPMqYhZbLqPKPRXpBKyCMgH8kApNoxp4cLKg

# For production, install @arcium-hq/client SDK
pnpm add @arcium-hq/client
```

### Arcium Deployment
Deploy MXE to devnet:
```bash
arcium deploy --cluster-offset 123 \
  --keypair-path ~/.config/solana/id.json \
  --rpc-url https://devnet.helius-rpc.com/?api-key=YOUR_KEY \
  --mempool-size Tiny
```

## Code Style
- ESLint with TypeScript parser
- Foundry fmt for Solidity (100 char line length, 4 space tabs)
- JSDoc comments for public APIs
- Domain-separated hashing for crypto operations
