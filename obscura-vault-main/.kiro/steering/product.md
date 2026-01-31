# Winternitz-SIP Product Overview

## What It Is
Post-quantum secure intent settlement system combining WOTS+ (Winternitz One-Time Signatures), SIP (Shielded Intent Protocol), and minimal on-chain settlement contracts.

## Core Value Proposition
- **Post-Quantum Security**: WOTS+ signatures resist quantum computer attacks
- **Privacy-Preserving**: Stealth addresses + Pedersen commitments hide transaction details
- **Gas Efficient**: Heavy crypto happens off-chain; contracts only verify commitments
- **Multi-Chain**: EVM (Ethereum, L2s) and Solana settlement support

## Primary Use Cases
- Private token swaps without revealing amounts or parties
- Cross-chain transfers with privacy
- Stealth payments without linking addresses
- Quantum-resistant custody for future-proof asset security
- Batch settlements for gas efficiency

## Design Principles
1. **Never verify WOTS on-chain** - Signature verification is too expensive (~50M gas)
2. **SIP owns privacy** - Intent data never touches contracts unencrypted
3. **Contracts own finality only** - Minimal state: commitment verification + replay protection
4. **Everything heavy is off-chain** - PQ auth, validation, batching, routing

## Privacy Levels
| Level | Description |
|-------|-------------|
| `TRANSPARENT` | All visible - for debugging/auditing |
| `SHIELDED` | Sender, recipient, amount hidden - maximum privacy |
| `COMPLIANT` | Encrypted with viewing keys - regulatory friendly |
