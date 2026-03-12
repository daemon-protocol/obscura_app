# Deployment Cost Analysis for OBSCURA Mobile Backend

## Summary
Mainnet deployment costs for Solana smart contracts powering the Obscura mobile application.

---

## Solana Mainnet Deployment Costs

### Programs to Deploy

| Program | Source Lines | Est. .so Size | Est. Cost |
|---------|--------------|---------------|-----------|
| obscura-per | 477 | ~150-200 KB | ~1.5-2 SOL |

### Program Details

#### obscura-per (Obscura Private Ephemeral Rollups)

**Location**: `Backend/backend-mobile/programs/obscura-per/src/lib.rs`

**Framework**: Anchor 0.30.1

**Key Features**:
- Private Ephemeral Rollups (PER) using MagicBlock and TEE validators
- Light Protocol ZK Compression integration
- Vault creation and management
- Private transfers with access control permissions

**Dependencies**:
- `anchor-lang` 0.30.1
- `anchor-spl` 0.30.1
- `ephemeral-rollups-sdk` 0.8 (MagicBlock)
- `light-sdk` 0.11
- `light-hasher` 1.1

---

## Cost Calculation (Solana Mainnet)

### Current Market Rates
- **SOL Price**: ~$140-160 (varies)
- **Deployment rate**: ~0.008 SOL per KB (varies by network congestion)

### Per Program Cost Breakdown

```
~175 KB avg × 0.008 SOL/KB = 1.4 SOL (deployment fee)
1.4 SOL × $150 = ~$210 (deployment fee only)
```

### Initial Account Funding

Each program requires:
- **Program account**: ~2-3 SOL rent exemption
- **Buffer account**: ~0.1-0.5 SOL
- **State accounts**: ~0.5-2 SOL

```
Total per program: ~3-6 SOL
```

### Solana Total: **~4-7 SOL = ~$600-1,100**

---

## Total Deployment Cost Summary

| Component | SOL | USD (est.) |
|-----------|-----|------------|
| Deployment Fee | 1.4-2 SOL | $210-320 |
| Account Rent Exemption | 2.5-5 SOL | ~$400-750 |
| **Total** | **~4-7 SOL** | **~$600-1,100** |

---

## Additional Costs to Consider

### 1. Initial Token Funding (for testing)
| Amount | Purpose | Cost (USD) |
|--------|---------|------------|
| ~1 SOL | Devnet testing & transactions | ~$150 |

### 2. RPC/Infrastructure (monthly)
| Service | Cost Range |
|---------|------------|
| Helius RPC (devnet/mainnet) | ~$50-150/month |
| QuickNode RPC (alternative) | ~$50-100/month |

### 3. External Program Dependencies

The `obscura-per` program integrates with third-party programs that are already deployed:

| Program | Address | Purpose |
|---------|---------|---------|
| MagicBlock Delegation | `DELeGGvXpWV2fqJUhqcF5ZSYMS4JTLjteaAMARRSaeSh` | Validator delegation |
| MagicBlock Access Control | `ACLseoPoyC3cBqoUtkbjZ4aDrkurZW86v19pXz2XQnp1` | Permission management |

**Note**: These programs are pre-deployed, so no deployment cost is incurred for them.

### 4. TEE Validator Regions (Optional)

For production deployment, you may need to configure validators across multiple regions:

| Region | Purpose |
|--------|---------|
| Asia | Low latency for Asia-Pacific users |
| EU | Low latency for European users |
| US | Low latency for North American users |
| TEE | Trusted Execution Environment for secure computation |

---

## Cost Optimization Tips

### Solana
- **Optimize program size**: Reduce .so file size to lower deployment costs
  - Remove unused dependencies
  - Use `#[inline]` strategically
  - Enable link-time optimization
- **Use upgradeable programs**: Allows updating without full redeployment
- **Consolidate state accounts**: Reduce number of required state accounts
- **Deploy during low congestion**: Network congestion can affect priority fees

### Build Optimization
```bash
# Build with release optimizations
anchor build --verifiable

# Check final .so size
ls -lh target/deploy/obscura_per.so
```

---

## Deployment Commands Reference

### Build and Deploy (Anchor)
```bash
# Set your program ID first
# Update Anchor.toml with your keypair

# Build the program
anchor build --provider.cluster devnet

# Deploy to devnet (for testing)
anchor deploy \
  --provider.cluster devnet \
  --provider.wallet ~/.config/solana/id.json

# Deploy to mainnet
anchor deploy \
  --provider.cluster mainnet \
  --provider.wallet ~/.config/solana/id.json \
  --program-id ~/.config/solana/my-program-keypair.json
```

### Program ID Generation
```bash
# Generate new program keypair
solana-keygen new -o ~/.config/solana/obscura_per.json

# Get the program ID
solana-keygen pubkey ~/.config/solana/obscura_per.json

# Update Anchor.toml with the generated program ID
```

### Testing Before Mainnet
```bash
# Run tests
anchor test \
  --provider.cluster devnet \
  --provider.wallet ~/.config/solana/id.json

# Or use the configured test script
npm run test
```

---

## Files Referenced

### Main Program
- `Backend/backend-mobile/programs/obscura-per/src/lib.rs` (477 lines)

### Configuration
- `Backend/backend-mobile/Anchor.toml` - Anchor framework configuration
- `Backend/backend-mobile/Cargo.toml` - Rust dependencies
- `Backend/backend-mobile/.env` - Environment variables (RPC URLs)

### Tests
- `Backend/backend-mobile/tests/` - Anchor test suite

---

## Pre-Deployment Checklist

- [ ] Generate and configure program ID keypair
- [ ] Update `Anchor.toml` with correct program ID
- [ ] Test on devnet with full test suite
- [ ] Verify TEE validator configuration
- [ ] Ensure sufficient SOL for deployment (~5-7 SOL recommended)
- [ ] Configure RPC endpoints (Helius/QuickNode)
- [ ] Set up monitoring for deployed program
- [ ] Document deployed program addresses

---

## Notes

- Solana deployment costs are primarily based on program size (buffer accounts)
- Costs are more predictable than Ethereum but can vary with network congestion
- Always test on devnet before mainnet deployment
- Consider using a separate wallet for deployment funds
- Keep backup of program keypair in secure location
- The `obscura-per` program uses advanced features (ZK compression, TEE) that may require additional configuration
