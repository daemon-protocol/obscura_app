# Project Structure

```
winternitz-sip/
├── packages/                    # TypeScript monorepo packages
│   ├── crypto/                  # @winternitz-sip/crypto
│   │   └── src/
│   │       ├── wots/            # WOTS+ signature scheme
│   │       │   ├── scheme.ts    # Core WOTSScheme class
│   │       │   ├── params.ts    # Parameter computation
│   │       │   └── key-manager.ts
│   │       ├── merkle/          # Merkle tree primitives
│   │       │   ├── tree.ts      # MerkleTree class
│   │       │   └── verify.ts    # Proof verification
│   │       ├── hash.ts          # SHA-256 utilities
│   │       └── types.ts         # Shared crypto types
│   │
│   └── backend/                 # @winternitz-sip/backend
│       └── src/
│           ├── sip/             # SIP privacy layer
│           │   ├── client.ts    # SIPClient class
│           │   ├── stealth.ts   # Stealth addressing
│           │   └── encryption.ts
│           ├── auth/            # PQ authorization
│           │   ├── service.ts   # AuthService
│           │   └── registry.ts  # Key pool registry
│           ├── executor/        # Settlement execution
│           │   ├── aggregator.ts
│           │   ├── batch.ts
│           │   └── multi-chain.ts
│           ├── solana/          # Solana integrations
│           │   ├── helius.ts    # Enhanced RPC, priority fees
│           │   ├── zk-compression.ts  # Legacy compression
│           │   ├── light-protocol/    # ZK Compression (full)
│           │   │   ├── client.ts      # LightProtocolClient
│           │   │   ├── photon.ts      # Photon indexer
│           │   │   ├── compressed-pda.ts
│           │   │   └── types.ts
│           │   └── arcium/      # Confidential computing
│           │       ├── client.ts      # ArciumClient
│           │       ├── cspl.ts        # Confidential SPL tokens
│           │       ├── mxe.ts         # MPC execution
│           │       └── types.ts
│           ├── server.ts        # Hono HTTP server
│           └── types.ts         # Backend types
│
├── contracts/
│   ├── evm/                     # Foundry project
│   │   ├── src/
│   │   │   ├── SIPSettlement.sol   # Main settlement contract
│   │   │   ├── SIPVault.sol        # Asset vault
│   │   │   └── MerkleVerifier.sol  # Proof verification
│   │   ├── script/              # Deployment scripts
│   │   └── test/                # Foundry tests
│   │
│   └── solana/                  # Anchor project
│       └── programs/sip-settlement/
│           └── src/
│               ├── lib.rs
│               ├── instructions.rs
│               ├── state.rs
│               └── error.rs
│
└── examples/                    # Demo applications
    ├── integration-demo.ts
    └── test-e2e.ts
```

## Package Dependencies
- `@winternitz-sip/backend` depends on `@winternitz-sip/crypto` (workspace reference)
- Both packages export subpath modules (e.g., `@winternitz-sip/crypto/wots`)

## Key Architectural Boundaries
1. **crypto** - Pure cryptographic primitives, no network/chain dependencies
2. **backend** - Off-chain services, integrates with SIP SDK and crypto package
3. **contracts/evm** - On-chain settlement, minimal state, no WOTS verification
4. **contracts/solana** - Anchor program for Solana settlement

## Solana Integration Modules
- **helius** - Enhanced RPC with priority fees, webhooks, smart transactions
- **light-protocol** - ZK Compression for ~1000x cheaper storage
- **arcium** - Confidential computing with cSPL tokens and MPC

## Test Locations
- `packages/crypto/tests/` - Vitest tests for crypto primitives
- `packages/backend/tests/` - Vitest tests for backend services
- `contracts/evm/test/` - Foundry tests for Solidity contracts
