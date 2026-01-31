# Design Document: Codebase Review and Optimization

## Overview

This design document outlines the approach for reviewing, analyzing, optimizing, and testing the Obscura post-quantum private intent settlement system with ShadowWire integration. The review covers cryptographic primitives (WOTS+, Merkle trees), smart contracts (EVM settlement and vault), and the ShadowWire SDK for private Solana transfers.

## Architecture

The system consists of three main layers:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         APPLICATION LAYER                                │
│              Obscura Backend | ShadowWire SDK | API                      │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                      CRYPTOGRAPHIC LAYER                                 │
│   WOTS+ Signatures | Merkle Trees | Bulletproofs (ShadowWire)           │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       SETTLEMENT LAYER                                   │
│   EVM: SIPSettlement + SIPVault | Solana: ShadowWire Pools              │
└─────────────────────────────────────────────────────────────────────────┘
```

## Components and Interfaces

### 1. Crypto Package (`packages/crypto`)

**WOTS+ Scheme (`src/wots/scheme.ts`)**
- `generatePrivateKey()`: Generate random private key
- `derivePrivateKey(seed, index)`: Deterministic key derivation
- `computePublicKey(privateKey)`: Compute public key from private
- `sign(privateKey, messageHash)`: Sign a message hash
- `verify(signature, messageHash)`: Recover public key from signature
- `verifyWithPublicKey(signature, messageHash, publicKey)`: Full verification
- `serializePublicKey/deserializePublicKey`: Serialization
- `serializeSignature/deserializeSignature`: Serialization

**Merkle Tree (`src/merkle/tree.ts`)**
- `MerkleTree.fromLeaves(leaves)`: Build tree from leaf hashes
- `getProof(leafIndex)`: Generate inclusion proof
- `verifyProof(proof, leaf, expectedRoot?)`: Verify proof
- `computeRootFromProof(leaf, proof)`: Compute root from proof

### 2. EVM Contracts (`contracts/evm`)

**SIPSettlement.sol**
- `updateRoot(newRoot)`: Update batch Merkle root
- `settle(commitment, proof, leafIndex)`: Settle single commitment
- `settleBatch(commitments, proofs, leafIndices)`: Batch settlement
- `verifyCommitment(commitment, proof, leafIndex)`: View-only verification

**SIPVault.sol**
- `depositNative()`: Deposit ETH
- `depositToken(token, amount)`: Deposit ERC20
- `executeWithdrawal(...)`: Execute verified withdrawal
- `executeAuthorizedWithdrawal(...)`: Settlement-authorized withdrawal

**MerkleVerifier.sol**
- `verify(proof, root, leaf, index)`: Verify Merkle proof
- `verifyWithPath(proof, pathIndices, root, leaf)`: Alternative verification

### 3. ShadowWire SDK Integration

**ShadowWireClient**
- `getBalance(wallet, token?)`: Check private balance
- `deposit(params)`: Deposit to privacy pool
- `withdraw(params)`: Withdraw from privacy pool
- `transfer(params)`: High-level transfer (internal/external)
- `transferWithClientProofs(params)`: Transfer with client-generated proofs

**Proof Generation**
- `initWASM(path?)`: Initialize WASM for client-side proofs
- `generateRangeProof(amount, bits)`: Generate Bulletproof
- `isWASMSupported()`: Check WASM availability

## Data Models

### WOTS Types
```typescript
interface WOTSParams {
  w: number;      // Winternitz parameter (4, 16, or 256)
  n: number;      // Hash output size (32 bytes)
  len1: number;   // Message blocks
  len2: number;   // Checksum blocks
  len: number;    // Total chains (len1 + len2)
}

type WOTSPrivateKey = Uint8Array[];  // len × n bytes
type WOTSPublicKey = Uint8Array[];   // len × n bytes
type WOTSSignature = Uint8Array[];   // len × n bytes
```

### Merkle Types
```typescript
interface MerkleProof {
  siblings: Hash[];      // Sibling hashes
  pathIndices: boolean[]; // Path direction (true = right)
  leafIndex: number;     // Original leaf index
}
```

### ShadowWire Types
```typescript
interface TransferParams {
  sender: string;
  recipient: string;
  amount: number;
  token: string;
  type: 'internal' | 'external';
  wallet?: { signMessage: (msg: Uint8Array) => Promise<Uint8Array> };
}

interface BalanceResponse {
  available: number;
  pool_address: string;
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: WOTS+ Sign/Verify Round-Trip
*For any* valid private key and any message hash, signing the message and then verifying the signature with the corresponding public key SHALL succeed.
**Validates: Requirements 1.1, 1.2**

### Property 2: WOTS+ Signature Corruption Detection
*For any* valid signature, corrupting any byte of the signature SHALL cause verification to fail.
**Validates: Requirements 1.3**

### Property 3: WOTS+ Signature Uniqueness
*For any* private key and any two distinct message hashes, the signatures produced SHALL be different.
**Validates: Requirements 1.4**

### Property 4: WOTS+ Public Key Serialization Round-Trip
*For any* public key, serializing and then deserializing SHALL produce an equal public key.
**Validates: Requirements 1.5**

### Property 5: WOTS+ Signature Serialization Round-Trip
*For any* valid signature, serializing and deserializing SHALL preserve verification validity.
**Validates: Requirements 1.6**

### Property 6: Merkle Tree Determinism
*For any* set of leaves, building a Merkle tree SHALL always produce the same root hash.
**Validates: Requirements 2.1**

### Property 7: Merkle Proof Validity
*For any* Merkle tree and any valid leaf index, the generated proof SHALL verify against the tree's root.
**Validates: Requirements 2.2**

### Property 8: Merkle Proof Rejection for Invalid Leaves
*For any* Merkle tree and proof, verifying with a different leaf than the original SHALL fail.
**Validates: Requirements 2.3**

### Property 9: Merkle Proof Corruption Detection
*For any* valid Merkle proof, corrupting any sibling hash SHALL cause verification to fail.
**Validates: Requirements 2.4**

### Property 10: Merkle Root Computation Consistency
*For any* Merkle tree and valid proof, computing the root from the proof SHALL match the tree's root.
**Validates: Requirements 2.5**

### Property 11: Cross-Platform Merkle Hash Compatibility
*For any* two leaf hashes, the TypeScript and Solidity implementations SHALL compute identical parent hashes using the 0x01 domain separator.
**Validates: Requirements 3.1, 3.2, 3.3**

### Property 12: Settlement Replay Protection
*For any* commitment that has been settled, attempting to settle it again SHALL revert with CommitmentAlreadyUsed.
**Validates: Requirements 4.1**

### Property 13: Settlement Invalid Proof Rejection
*For any* commitment with an invalid Merkle proof, settlement SHALL revert with InvalidProof.
**Validates: Requirements 4.2**

### Property 14: Settlement Access Control
*For any* address that is not an authorized executor, calling updateRoot SHALL revert with Unauthorized.
**Validates: Requirements 4.3**

### Property 15: Settlement Batch Size Limit
*For any* batch larger than MAX_BATCH_SIZE (100), settleBatch SHALL revert with BatchTooLarge.
**Validates: Requirements 4.4**

### Property 16: Vault Balance Tracking
*For any* deposit, the vault's token balance SHALL increase by exactly the deposited amount.
**Validates: Requirements 5.1**

### Property 17: Vault Insufficient Balance Rejection
*For any* withdrawal attempt exceeding the available balance, the vault SHALL revert with InsufficientBalance.
**Validates: Requirements 5.2**

### Property 18: Vault Replay Protection
*For any* commitment that has been used for withdrawal, subsequent withdrawal attempts SHALL revert with CommitmentAlreadyUsed.
**Validates: Requirements 5.3**

### Property 19: Vault Pause Enforcement
*For any* deposit or withdrawal attempt while paused, the vault SHALL revert with ContractPaused.
**Validates: Requirements 5.4**

### Property 20: WOTS+ Key Derivation Determinism
*For any* seed and index, deriving a private key SHALL always produce the same result.
**Validates: Requirements 7.1**

### Property 21: WOTS+ Key Derivation Uniqueness
*For any* seed and any two different indices, the derived private keys SHALL be different.
**Validates: Requirements 7.2**

### Property 22: ShadowWire Internal Transfer Privacy
*For any* valid internal transfer, the transaction amount SHALL be hidden on-chain using Bulletproofs.
**Validates: Requirements 9.3, 10.1**

### Property 23: ShadowWire Wallet Signature Requirement
*For any* transfer attempt without a wallet signature, the ShadowWire client SHALL reject the request.
**Validates: Requirements 9.5**

### Property 24: ShadowWire Insufficient Balance Error
*For any* transfer attempt with insufficient balance, the ShadowWire client SHALL throw InsufficientBalanceError.
**Validates: Requirements 10.2**

### Property 25: ShadowWire Recipient Not Found Error
*For any* internal transfer to a non-ShadowWire user, the client SHALL throw RecipientNotFoundError.
**Validates: Requirements 10.3**

### Property 26: ShadowWire Token Decimal Conversion
*For any* supported token and amount, converting to smallest unit and back SHALL preserve the original value.
**Validates: Requirements 10.5**

### Property 27: ShadowWire Client Proof Acceptance
*For any* valid client-generated Bulletproof, transferWithClientProofs SHALL accept and use it.
**Validates: Requirements 11.2, 11.4**

### Property 28: ShadowWire Typed Error Objects
*For any* API error, the ShadowWire client SHALL provide a typed error object with actionable information.
**Validates: Requirements 12.4**

## Error Handling

### Crypto Package Errors
- `Invalid private key length`: Thrown when private key doesn't match expected len
- `Invalid message hash length`: Thrown when hash isn't n bytes
- `Invalid serialized public key length`: Thrown during deserialization
- `Cannot create Merkle tree with no leaves`: Thrown for empty leaf array
- `Leaf index out of range`: Thrown for invalid proof requests

### EVM Contract Errors
- `Unauthorized()`: Access control violation
- `InvalidProof()`: Merkle proof verification failed
- `CommitmentAlreadyUsed()`: Replay attack detected
- `InvalidRoot()`: Zero or invalid root provided
- `BatchTooLarge()`: Batch exceeds MAX_BATCH_SIZE
- `InsufficientBalance()`: Withdrawal exceeds balance
- `ContractPaused()`: Operation during pause
- `TransferFailed()`: Token transfer failed

### ShadowWire Errors
- `RecipientNotFoundError`: Recipient not a ShadowWire user
- `InsufficientBalanceError`: Not enough balance for transfer
- `AuthenticationError`: Invalid or missing wallet signature

## Testing Strategy

### Unit Tests
Unit tests verify specific examples and edge cases:
- WOTS+ parameter computation for w=4, 16, 256
- Merkle tree construction with various leaf counts
- Contract deployment and initial state
- Error conditions and boundary cases

### Property-Based Tests
Property tests verify universal properties across many generated inputs:
- **Framework**: fast-check for TypeScript, Foundry fuzz for Solidity
- **Minimum iterations**: 100 per property
- **Tag format**: `Feature: codebase-review-optimization, Property N: description`

### Integration Tests
- TypeScript-Solidity Merkle proof compatibility
- End-to-end settlement flow
- ShadowWire API integration

### Gas Benchmarks
- Single settlement: < 120,000 gas
- Batch settlement (10): < 200,000 gas
- Root update: < 90,000 gas

### Test File Locations
- `packages/crypto/tests/wots.property.test.ts` - WOTS+ property tests
- `packages/crypto/tests/merkle.property.test.ts` - Merkle property tests
- `contracts/evm/test/SIPSettlement.fuzz.t.sol` - Settlement fuzz tests
- `contracts/evm/test/SIPVault.fuzz.t.sol` - Vault fuzz tests
