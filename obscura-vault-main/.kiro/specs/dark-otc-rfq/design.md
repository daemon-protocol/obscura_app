# Design Document: Dark OTC RFQ / Dark DEX

## Overview

The Dark OTC RFQ / Dark DEX system provides production-ready, privacy-preserving over-the-counter trading capabilities for the Obscura blockchain platform. The system enables institutional-grade private token trading through two primary mechanisms:

1. **Request-For-Quote (RFQ) System**: Traders request quotes from market makers, quotes are submitted encrypted, and the best quote is selected via confidential computation without revealing losing quotes.

2. **Dark Pool**: Traders submit encrypted orders that are matched privately without public order book visibility, with price discovery happening through confidential computation.

Both mechanisms leverage Arcium MPC for confidential operations, SIP for privacy-preserving settlement, WOTS+ for post-quantum security, and support multi-chain settlement on EVM and Solana. The system includes a private peer-to-peer chat system for maker-taker negotiation, routed through TOR/SOCKS5 for network anonymity.

### Key Design Goals

- **Maximum Privacy**: All sensitive data (token pairs, amounts, prices, identities) encrypted until settlement
- **Post-Quantum Security**: WOTS+ signatures throughout, with off-chain verification
- **Production-Grade**: 99.9% uptime, 2s quote response, 500ms matching, comprehensive error handling
- **Gas Efficiency**: Heavy computation off-chain via MPC, minimal on-chain state
- **Regulatory Flexibility**: Support for TRANSPARENT, SHIELDED, and COMPLIANT privacy levels

## Architecture

### High-Level System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Client Layer                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Trader     │  │ Market Maker │  │   Operator   │          │
│  │   Client     │  │    Client    │  │   Dashboard  │          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
└─────────┼──────────────────┼──────────────────┼─────────────────┘
          │                  │                  │
          │                  │                  │
┌─────────┼──────────────────┼──────────────────┼─────────────────┐
│         │      Backend API Layer (Hono)       │                 │
│  ┌──────▼──────────────────▼──────────────────▼───────┐         │
│  │           RFQ Service / Dark Pool Service          │         │
│  │  ┌──────────────┐  ┌──────────────┐               │         │
│  │  │ Quote Manager│  │ Order Manager│               │         │
│  │  └──────┬───────┘  └──────┬───────┘               │         │
│  └─────────┼──────────────────┼────────────────────────┘         │
│            │                  │                                  │
│  ┌─────────▼──────────────────▼────────────────────┐            │
│  │         Confidential Compute Layer               │            │
│  │  ┌──────────────────────────────────────────┐   │            │
│  │  │      Arcium MPC Engine                   │   │            │
│  │  │  - Quote comparison & selection          │   │            │
│  │  │  - Order matching                        │   │            │
│  │  │  - Price discovery                       │   │            │
│  │  │  - Key exchange for chat                 │   │            │
│  │  └──────────────────────────────────────────┘   │            │
│  └──────────────────┬───────────────────────────────┘            │
│                     │                                            │
│  ┌──────────────────▼───────────────────────────────┐            │
│  │         Privacy & Settlement Layer               │            │
│  │  ┌──────────────────────────────────────────┐   │            │
│  │  │      SIP Client                          │   │            │
│  │  │  - Stealth address generation            │   │            │
│  │  │  - Pedersen commitments                  │   │            │
│  │  │  - Shielded transactions                 │   │            │
│  │  └──────────────────────────────────────────┘   │            │
│  └──────────────────┬───────────────────────────────┘            │
└────────────────────┼──────────────────────────────────────────────┘
                     │
          ┌──────────┴──────────┐
          │                     │
┌─────────▼─────────┐  ┌────────▼────────┐
│   EVM Chains      │  │  Solana Chain   │
│ ┌───────────────┐ │  │ ┌─────────────┐ │
│ │ SIPSettlement │ │  │ │ SIP Program │ │
│ │   Contract    │ │  │ │  (Anchor)   │ │
│ └───────────────┘ │  │ └─────────────┘ │
│ ┌───────────────┐ │  │ ┌─────────────┐ │
│ │   SIPVault    │ │  │ │Light Protocol│ │
│ │   Contract    │ │  │ │(ZK Compress)│ │
│ └───────────────┘ │  │ └─────────────┘ │
└───────────────────┘  └─────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    P2P Chat Layer (Optional)                     │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  TOR/SOCKS5 Network                                      │   │
│  │  ┌────────────┐  ◄──encrypted──►  ┌────────────┐        │   │
│  │  │  Trader A  │                    │  Trader B  │        │   │
│  │  │ Chat Node  │  ◄──Signal Proto──►│ Chat Node  │        │   │
│  │  └────────────┘                    └────────────┘        │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Component Interaction Flow

**RFQ Flow:**
```
1. Trader → RFQ Service: Create encrypted Quote_Request
2. RFQ Service → MPC Engine: Encrypt token pair + amount
3. RFQ Service → Market Makers: Broadcast encrypted request
4. Market Makers → RFQ Service: Submit encrypted Quote_Responses
5. RFQ Service → MPC Engine: Compare quotes confidentially
6. MPC Engine → RFQ Service: Return winning quote (encrypted)
7. RFQ Service → Trader: Reveal winning quote
8. RFQ Service → SIP Client: Initiate settlement
9. SIP Client → Blockchain: Execute shielded transaction
```

**Dark Pool Flow:**
```
1. Trader → Dark Pool Service: Submit encrypted Order
2. Dark Pool → MPC Engine: Encrypt order details
3. MPC Engine → Matching Engine: Store encrypted order
4. Matching Engine: Continuously match orders in MPC
5. Matching Engine → Dark Pool: Notify matched parties
6. Dark Pool → SIP Client: Initiate settlement
7. SIP Client → Blockchain: Execute shielded transaction
```

## Components and Interfaces

### 1. RFQ Service

**Responsibility**: Manages the request-for-quote workflow from creation to settlement.

**Key Classes:**

```typescript
class RFQService {
  constructor(
    private mpcClient: ArciumClient,
    private sipClient: SIPClient,
    private authService: AuthService,
    private quoteStore: QuoteStore
  ) {}

  // Create encrypted quote request
  async createQuoteRequest(
    request: QuoteRequestInput
  ): Promise<QuoteRequest>

  // Submit encrypted quote response
  async submitQuote(
    requestId: string,
    quote: QuoteInput
  ): Promise<QuoteResponse>

  // Select best quote via MPC
  async selectBestQuote(
    requestId: string
  ): Promise<SelectedQuote>

  // Cancel quote request
  async cancelQuoteRequest(
    requestId: string
  ): Promise<void>

  // Get quote request status
  async getQuoteRequestStatus(
    requestId: string
  ): Promise<QuoteRequestStatus>
}
```

**Interfaces:**

```typescript
interface QuoteRequestInput {
  tokenIn: string;          // Token to sell
  tokenOut: string;         // Token to buy
  amountIn: bigint;         // Amount to sell
  chain: 'evm' | 'solana';  // Target chain
  timeout: number;          // Timeout in seconds
  privacyLevel: 'SHIELDED' | 'COMPLIANT' | 'TRANSPARENT';
}

interface QuoteRequest {
  id: string;
  encryptedTokenPair: Uint8Array;  // MPC-encrypted
  encryptedAmount: Uint8Array;     // MPC-encrypted
  stealthAddress: string;          // Requester stealth address
  timestamp: number;
  timeout: number;
  nonce: string;                   // Replay protection
  signature: WOTSSignature;        // WOTS+ signature
}

interface QuoteInput {
  price: bigint;           // Quote price
  liquidity: bigint;       // Available liquidity
  fee: bigint;             // Market maker fee
  validUntil: number;      // Quote expiry
}

interface QuoteResponse {
  id: string;
  requestId: string;
  encryptedPrice: Uint8Array;      // MPC-encrypted
  encryptedLiquidity: Uint8Array;  // MPC-encrypted
  encryptedFee: Uint8Array;        // MPC-encrypted
  stealthAddress: string;          // Market maker stealth address
  timestamp: number;
  nonce: string;
  signature: WOTSSignature;
}

interface SelectedQuote {
  requestId: string;
  quoteId: string;
  price: bigint;           // Decrypted for requester
  liquidity: bigint;
  fee: bigint;
  makerAddress: string;    // Stealth address
}
```

### 2. Dark Pool Service

**Responsibility**: Manages dark pool order submission, matching, and lifecycle.

**Key Classes:**

```typescript
class DarkPoolService {
  constructor(
    private mpcClient: ArciumClient,
    private matchingEngine: MatchingEngine,
    private sipClient: SIPClient,
    private authService: AuthService,
    private orderStore: OrderStore
  ) {}

  // Submit encrypted order
  async submitOrder(
    order: OrderInput
  ): Promise<Order>

  // Cancel order
  async cancelOrder(
    orderId: string
  ): Promise<void>

  // Modify order (cancel + resubmit)
  async modifyOrder(
    orderId: string,
    updates: Partial<OrderInput>
  ): Promise<Order>

  // Get order status
  async getOrderStatus(
    orderId: string
  ): Promise<OrderStatus>

  // Get user's active orders
  async getUserOrders(
    userId: string
  ): Promise<Order[]>
}
```

**Interfaces:**

```typescript
interface OrderInput {
  tokenIn: string;
  tokenOut: string;
  amount: bigint;
  limitPrice: bigint;      // Max price willing to pay (buy) or min price to accept (sell)
  side: 'BUY' | 'SELL';
  chain: 'evm' | 'solana';
  privacyLevel: 'SHIELDED' | 'COMPLIANT' | 'TRANSPARENT';
}

interface Order {
  id: string;
  encryptedTokenPair: Uint8Array;
  encryptedAmount: Uint8Array;
  encryptedLimitPrice: Uint8Array;
  encryptedSide: Uint8Array;       // Even side is encrypted
  stealthAddress: string;
  timestamp: number;
  nonce: string;
  signature: WOTSSignature;
  status: 'ACTIVE' | 'PARTIALLY_FILLED' | 'FILLED' | 'CANCELLED';
  filledAmount: bigint;            // Encrypted in MPC
}

interface OrderStatus {
  orderId: string;
  status: 'ACTIVE' | 'PARTIALLY_FILLED' | 'FILLED' | 'CANCELLED';
  filledAmount: bigint;
  remainingAmount: bigint;
  averagePrice: bigint;
  matches: Match[];
}

interface Match {
  matchId: string;
  orderId: string;
  counterpartyOrderId: string;
  amount: bigint;
  price: bigint;
  timestamp: number;
  settlementTxHash?: string;
}
```

### 3. Matching Engine

**Responsibility**: Confidentially matches orders in the dark pool using MPC.

**Key Classes:**

```typescript
class MatchingEngine {
  constructor(
    private mpcClient: ArciumClient,
    private orderBook: EncryptedOrderBook
  ) {}

  // Add order to encrypted order book
  async addOrder(
    order: Order
  ): Promise<void>

  // Remove order from order book
  async removeOrder(
    orderId: string
  ): Promise<void>

  // Continuously match orders (runs in background)
  async matchOrders(): Promise<Match[]>

  // Get aggregated liquidity (encrypted)
  async getAggregatedLiquidity(
    tokenPair: string
  ): Promise<EncryptedLiquidity>
}
```

**Interfaces:**

```typescript
interface EncryptedOrderBook {
  // Orders stored encrypted in MPC
  orders: Map<string, Order>;
  
  // Price-time priority index (encrypted)
  buyIndex: EncryptedPriorityQueue;
  sellIndex: EncryptedPriorityQueue;
}

interface EncryptedPriorityQueue {
  // MPC-based priority queue
  // Maintains price-time priority without decryption
  insert(order: Order): Promise<void>;
  remove(orderId: string): Promise<void>;
  peek(): Promise<Order | null>;
  pop(): Promise<Order | null>;
}

interface EncryptedLiquidity {
  tokenPair: string;
  encryptedBuyVolume: Uint8Array;
  encryptedSellVolume: Uint8Array;
  encryptedBestBid: Uint8Array;
  encryptedBestAsk: Uint8Array;
}
```

### 4. Arcium MPC Client

**Responsibility**: Interface to Arcium MPC for confidential computation.

**Key Classes:**

```typescript
class ArciumMPCClient {
  constructor(
    private clusterOffset: number,
    private rpcUrl: string,
    private programId: string
  ) {}

  // Encrypt data using MPC
  async encrypt(
    data: Uint8Array,
    context: string
  ): Promise<Uint8Array>

  // Decrypt data using MPC (requires authorization)
  async decrypt(
    encryptedData: Uint8Array,
    context: string
  ): Promise<Uint8Array>

  // Compare encrypted values without decryption
  async compare(
    a: Uint8Array,
    b: Uint8Array,
    operation: 'LT' | 'GT' | 'EQ' | 'LTE' | 'GTE'
  ): Promise<boolean>

  // Select minimum/maximum from encrypted values
  async selectBest(
    values: Uint8Array[],
    criterion: 'MIN' | 'MAX'
  ): Promise<number> // Returns index

  // Perform arithmetic on encrypted values
  async add(a: Uint8Array, b: Uint8Array): Promise<Uint8Array>
  async subtract(a: Uint8Array, b: Uint8Array): Promise<Uint8Array>
  async multiply(a: Uint8Array, b: Uint8Array): Promise<Uint8Array>

  // Batch operations for performance
  async batchEncrypt(
    data: Uint8Array[],
    context: string
  ): Promise<Uint8Array[]>

  // Performance benchmarking
  async benchmark(): Promise<MPCBenchmarkResults>
}

interface MPCBenchmarkResults {
  encryptionLatency: number;    // ms
  decryptionLatency: number;    // ms
  comparisonLatency: number;    // ms
  selectionLatency: number;     // ms
  throughput: number;           // operations/sec
}
```

### 5. Settlement Layer (SIP Integration)

**Responsibility**: Execute privacy-preserving settlement using SIP protocol.

**Key Classes:**

```typescript
class SettlementService {
  constructor(
    private sipClient: SIPClient,
    private evmExecutor: EVMSettlementExecutor,
    private solanaExecutor: SolanaSettlementExecutor,
    private authService: AuthService
  ) {}

  // Settle matched trade
  async settleTrade(
    match: Match,
    chain: 'evm' | 'solana'
  ): Promise<SettlementResult>

  // Settle cross-chain trade atomically
  async settleCrossChainTrade(
    match: Match,
    sourceChain: 'evm' | 'solana',
    destChain: 'evm' | 'solana'
  ): Promise<CrossChainSettlementResult>

  // Batch settle multiple trades
  async batchSettle(
    matches: Match[],
    chain: 'evm' | 'solana'
  ): Promise<BatchSettlementResult>

  // Estimate gas costs
  async estimateGas(
    match: Match,
    chain: 'evm' | 'solana'
  ): Promise<GasEstimate>
}
```

**Interfaces:**

```typescript
interface SettlementResult {
  matchId: string;
  txHash: string;
  chain: 'evm' | 'solana';
  status: 'PENDING' | 'CONFIRMED' | 'FAILED';
  gasUsed: bigint;
  timestamp: number;
  proof: SettlementProof;
}

interface CrossChainSettlementResult {
  matchId: string;
  sourceTxHash: string;
  destTxHash: string;
  htlcSecret?: string;         // For atomic swaps
  status: 'PENDING' | 'CONFIRMED' | 'ROLLED_BACK';
  timestamp: number;
}

interface BatchSettlementResult {
  batchId: string;
  txHash: string;
  matches: string[];           // Match IDs
  totalGasUsed: bigint;
  gasPerTrade: bigint;
  timestamp: number;
}

interface SettlementProof {
  commitment: string;          // Pedersen commitment
  merkleProof: string[];       // Merkle proof
  signature: WOTSSignature;    // WOTS+ signature
}

interface GasEstimate {
  estimatedGas: bigint;
  gasPrice: bigint;
  totalCost: bigint;
  chain: 'evm' | 'solana';
}
```

### 6. Private Chat System

**Responsibility**: Enable encrypted P2P communication between traders.

**Key Classes:**

```typescript
class ChatService {
  constructor(
    private torClient: TORClient,
    private mpcClient: ArciumClient,
    private authService: AuthService,
    private messageStore: MessageStore
  ) {}

  // Establish chat channel
  async establishChannel(
    participantA: string,
    participantB: string
  ): Promise<ChatChannel>

  // Send encrypted message
  async sendMessage(
    channelId: string,
    message: string
  ): Promise<Message>

  // Receive messages
  async receiveMessages(
    channelId: string,
    since?: number
  ): Promise<Message[]>

  // Get channel status
  async getChannelStatus(
    channelId: string
  ): Promise<ChannelStatus>

  // Close channel
  async closeChannel(
    channelId: string
  ): Promise<void>
}
```

**Interfaces:**

```typescript
interface ChatChannel {
  id: string;
  participantA: string;        // Stealth address
  participantB: string;        // Stealth address
  sessionKey: Uint8Array;      // Ephemeral DH key
  createdAt: number;
  status: 'ACTIVE' | 'CLOSED';
}

interface Message {
  id: string;
  channelId: string;
  sender: string;              // Stealth address
  encryptedContent: Uint8Array; // Signal Protocol encrypted
  timestamp: number;
  delivered: boolean;
  read: boolean;
}

interface ChannelStatus {
  channelId: string;
  participantAOnline: boolean;
  participantBOnline: boolean;
  lastActivity: number;
  messageCount: number;
}
```

### 7. Authorization & Authentication

**Responsibility**: Manage WOTS+ signatures and key pools.

**Key Classes:**

```typescript
class AuthService {
  constructor(
    private wotsScheme: WOTSScheme,
    private keyRegistry: KeyPoolRegistry,
    private nonceRegistry: NonceRegistry
  ) {}

  // Generate WOTS+ signature
  async sign(
    message: Uint8Array,
    userId: string
  ): Promise<WOTSSignature>

  // Verify WOTS+ signature (off-chain)
  async verify(
    message: Uint8Array,
    signature: WOTSSignature,
    publicKey: Uint8Array
  ): Promise<boolean>

  // Get fresh key from pool
  async getKey(
    userId: string
  ): Promise<WOTSKeyPair>

  // Mark key as used (prevent reuse)
  async markKeyUsed(
    keyId: string
  ): Promise<void>

  // Verify nonce (replay protection)
  async verifyNonce(
    nonce: string
  ): Promise<boolean>

  // Register nonce
  async registerNonce(
    nonce: string
  ): Promise<void>
}
```

### 8. Market Maker Registry

**Responsibility**: Manage market maker authorization and whitelisting.

**Key Classes:**

```typescript
class MarketMakerRegistry {
  constructor(
    private authService: AuthService,
    private reputationService: ReputationService
  ) {}

  // Register new market maker
  async registerMarketMaker(
    credentials: MarketMakerCredentials
  ): Promise<MarketMaker>

  // Verify market maker authorization
  async isAuthorized(
    marketMakerId: string
  ): Promise<boolean>

  // Add to whitelist
  async addToWhitelist(
    marketMakerId: string
  ): Promise<void>

  // Remove from whitelist
  async removeFromWhitelist(
    marketMakerId: string
  ): Promise<void>

  // Get market maker reputation
  async getReputation(
    marketMakerId: string
  ): Promise<ReputationScore>
}

interface MarketMaker {
  id: string;
  credentials: MarketMakerCredentials;
  whitelisted: boolean;
  reputation: ReputationScore;
  registeredAt: number;
}

interface MarketMakerCredentials {
  publicKey: Uint8Array;
  proofOfLiquidity: string;
  kycVerification?: string;
}

interface ReputationScore {
  totalQuotes: number;
  acceptedQuotes: number;
  averageSpread: bigint;
  uptime: number;
  score: number;              // 0-100
}
```

### 9. Oracle Integration

**Responsibility**: Provide secure price feeds for quote validation.

**Key Classes:**

```typescript
class OracleService {
  constructor(
    private chainlinkClient: ChainlinkClient,
    private pythClient: PythClient
  ) {}

  // Get aggregated price from multiple sources
  async getPrice(
    tokenPair: string
  ): Promise<AggregatedPrice>

  // Verify oracle signature
  async verifyOracleSignature(
    price: OraclePrice
  ): Promise<boolean>

  // Check price deviation
  async checkDeviation(
    quote: bigint,
    tokenPair: string
  ): Promise<DeviationCheck>
}

interface AggregatedPrice {
  tokenPair: string;
  price: bigint;
  sources: OraclePrice[];
  timestamp: number;
  confidence: number;
}

interface OraclePrice {
  source: 'chainlink' | 'pyth' | 'other';
  price: bigint;
  timestamp: number;
  signature: Uint8Array;
}

interface DeviationCheck {
  quote: bigint;
  referencePrice: bigint;
  deviation: number;          // Percentage
  acceptable: boolean;        // Within 5% threshold
}
```

## Data Models

### Core Data Structures

```typescript
// Quote Request State Machine
enum QuoteRequestState {
  CREATED = 'CREATED',
  BROADCASTED = 'BROADCASTED',
  QUOTES_RECEIVED = 'QUOTES_RECEIVED',
  QUOTE_SELECTED = 'QUOTE_SELECTED',
  SETTLING = 'SETTLING',
  SETTLED = 'SETTLED',
  CANCELLED = 'CANCELLED',
  EXPIRED = 'EXPIRED'
}

// Order State Machine
enum OrderState {
  SUBMITTED = 'SUBMITTED',
  ACTIVE = 'ACTIVE',
  PARTIALLY_FILLED = 'PARTIALLY_FILLED',
  FILLED = 'FILLED',
  CANCELLED = 'CANCELLED',
  EXPIRED = 'EXPIRED'
}

// Settlement State Machine
enum SettlementState {
  INITIATED = 'INITIATED',
  PENDING = 'PENDING',
  CONFIRMED = 'CONFIRMED',
  FAILED = 'FAILED',
  ROLLED_BACK = 'ROLLED_BACK'
}
```

### Database Schema (Conceptual)

```typescript
// Quote Requests Table
interface QuoteRequestRecord {
  id: string;                  // Primary key
  userId: string;              // Foreign key to users
  encryptedTokenPair: Buffer;
  encryptedAmount: Buffer;
  stealthAddress: string;
  chain: string;
  privacyLevel: string;
  state: QuoteRequestState;
  timeout: number;
  nonce: string;               // Indexed for replay protection
  signature: Buffer;
  createdAt: Date;
  updatedAt: Date;
  expiresAt: Date;
}

// Quote Responses Table
interface QuoteResponseRecord {
  id: string;                  // Primary key
  requestId: string;           // Foreign key to quote_requests
  marketMakerId: string;       // Foreign key to market_makers
  encryptedPrice: Buffer;
  encryptedLiquidity: Buffer;
  encryptedFee: Buffer;
  stealthAddress: string;
  nonce: string;
  signature: Buffer;
  selected: boolean;
  createdAt: Date;
}

// Orders Table
interface OrderRecord {
  id: string;                  // Primary key
  userId: string;              // Foreign key to users
  encryptedTokenPair: Buffer;
  encryptedAmount: Buffer;
  encryptedLimitPrice: Buffer;
  encryptedSide: Buffer;
  stealthAddress: string;
  chain: string;
  privacyLevel: string;
  state: OrderState;
  filledAmount: bigint;
  nonce: string;
  signature: Buffer;
  createdAt: Date;
  updatedAt: Date;
}

// Matches Table
interface MatchRecord {
  id: string;                  // Primary key
  orderIdA: string;            // Foreign key to orders
  orderIdB: string;            // Foreign key to orders
  amount: bigint;
  price: bigint;
  settlementState: SettlementState;
  settlementTxHash?: string;
  createdAt: Date;
  settledAt?: Date;
}

// Market Makers Table
interface MarketMakerRecord {
  id: string;                  // Primary key
  publicKey: Buffer;
  whitelisted: boolean;
  reputationScore: number;
  totalQuotes: number;
  acceptedQuotes: number;
  createdAt: Date;
  updatedAt: Date;
}

// Nonce Registry Table (for replay protection)
interface NonceRecord {
  nonce: string;               // Primary key
  userId: string;
  usedAt: Date;
  expiresAt: Date;             // Auto-delete after 5 minutes
}

// Chat Channels Table
interface ChatChannelRecord {
  id: string;                  // Primary key
  participantA: string;
  participantB: string;
  sessionKeyA: Buffer;         // Encrypted with participant A's key
  sessionKeyB: Buffer;         // Encrypted with participant B's key
  status: string;
  createdAt: Date;
  closedAt?: Date;
}

// Messages Table (local storage only, not centralized)
interface MessageRecord {
  id: string;                  // Primary key
  channelId: string;           // Foreign key to chat_channels
  sender: string;
  encryptedContent: Buffer;
  timestamp: Date;
  delivered: boolean;
  read: boolean;
}
```

### Encryption Context

All encrypted data uses domain-separated contexts for security:

```typescript
const ENCRYPTION_CONTEXTS = {
  QUOTE_TOKEN_PAIR: 'obscura.rfq.quote.token_pair',
  QUOTE_AMOUNT: 'obscura.rfq.quote.amount',
  QUOTE_PRICE: 'obscura.rfq.quote.price',
  QUOTE_LIQUIDITY: 'obscura.rfq.quote.liquidity',
  QUOTE_FEE: 'obscura.rfq.quote.fee',
  ORDER_TOKEN_PAIR: 'obscura.darkpool.order.token_pair',
  ORDER_AMOUNT: 'obscura.darkpool.order.amount',
  ORDER_PRICE: 'obscura.darkpool.order.price',
  ORDER_SIDE: 'obscura.darkpool.order.side',
  CHAT_MESSAGE: 'obscura.chat.message',
  CHAT_SESSION_KEY: 'obscura.chat.session_key'
};
```


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### RFQ System Properties

**Property 1: RFQ Data Encryption**
*For any* quote request, all sensitive data (token pair, amount) SHALL be encrypted via MPC before broadcast, and only authorized market makers SHALL be able to decrypt the request details.
**Validates: Requirements 1.1, 1.2, 1.4**

**Property 2: Quote Response Encryption**
*For any* quote response, all sensitive data (price, liquidity, fee) SHALL be encrypted via MPC, and only the requester and system SHALL be able to decrypt after selection.
**Validates: Requirements 2.1, 2.2**

**Property 3: Confidential Quote Selection**
*For any* quote request with multiple responses, the MPC engine SHALL select the best quote without decrypting individual values, and only the winning quote SHALL be revealed to the requester.
**Validates: Requirements 3.1, 3.2, 3.4**

**Property 4: Quote Selection Determinism**
*For any* set of quote responses, running the selection process multiple times with the same inputs SHALL always produce the same winning quote.
**Validates: Requirements 3.5**

**Property 5: Quote Request Uniqueness**
*For any* two quote requests, they SHALL have different unique identifiers, ensuring no ID collisions occur.
**Validates: Requirements 1.5**

**Property 6: Quote Response Association**
*For any* quote response, it SHALL be correctly associated with its corresponding quote request, maintaining referential integrity.
**Validates: Requirements 2.3**

**Property 7: Quote Timeout Enforcement**
*For any* quote request, quote responses submitted after the timeout period SHALL be rejected by the system.
**Validates: Requirements 2.5, 10.2**

**Property 8: Quote Cancellation Finality**
*For any* cancelled quote request, the quote selection process SHALL be prevented from proceeding, and all market makers who submitted quotes SHALL be notified.
**Validates: Requirements 10.3, 10.4**

### Dark Pool Properties

**Property 9: Order Data Encryption**
*For any* order submission, all sensitive data (token pair, amount, limit price, side) SHALL be encrypted via MPC and stored without exposure to other participants.
**Validates: Requirements 4.1, 4.2, 4.3, 4.5**

**Property 10: Confidential Order Matching**
*For any* pair of orders, the matching engine SHALL compare encrypted bids and asks using MPC without decrypting individual order prices.
**Validates: Requirements 5.1, 5.2**

**Property 11: Price-Time Priority**
*For any* set of orders at the same price level, orders submitted earlier SHALL be matched before orders submitted later.
**Validates: Requirements 5.5**

**Property 12: Partial Fill State Consistency**
*For any* partially filled order, the remaining quantity SHALL be correctly updated within the MPC engine and available for further matching.
**Validates: Requirements 5.4**

**Property 13: Order Cancellation Finality**
*For any* cancelled order, it SHALL be removed from the matching engine and SHALL NOT be matched after cancellation.
**Validates: Requirements 11.1, 11.5**

**Property 14: Order Modification Semantics**
*For any* order modification, the system SHALL treat it as an atomic cancellation of the original order followed by submission of a new order.
**Validates: Requirements 11.2**

### Privacy & Security Properties

**Property 15: Universal Stealth Addressing**
*For any* participant (requester, market maker, trader), a unique stealth address SHALL be generated for each transaction or interaction.
**Validates: Requirements 1.3, 2.4, 4.4**

**Property 16: SIP Settlement Privacy**
*For any* matched trade, settlement SHALL use SIP with stealth addresses and Pedersen commitments, providing cryptographic proof without revealing trade details.
**Validates: Requirements 6.1, 6.2, 6.3, 6.4**

**Property 17: WOTS+ Authentication**
*For any* quote request, quote response, or order, it SHALL be signed with a WOTS+ signature, and the signature SHALL be verified off-chain before processing.
**Validates: Requirements 8.1, 8.2**

**Property 18: WOTS+ Key Uniqueness**
*For any* two transactions, they SHALL use different WOTS+ signature keys, ensuring no key reuse occurs.
**Validates: Requirements 8.5**

**Property 19: Quantum-Resistant Key Derivation**
*For any* stealth address generation, the system SHALL use quantum-resistant key derivation methods.
**Validates: Requirements 8.3**

**Property 20: Replay Protection via Nonces**
*For any* quote request or order, it SHALL include a unique nonce that has not been used before, and the nonce registry SHALL prevent reuse.
**Validates: Requirements 34.1, 34.2, 34.3, 34.5**

**Property 21: Timestamp Freshness**
*For any* quote request or order, if its timestamp is older than 5 minutes, the system SHALL reject it.
**Validates: Requirements 34.4**

**Property 22: Front-Running Prevention**
*For any* order or quote request, all details SHALL be encrypted before any broadcast, preventing unauthorized parties from extracting information.
**Validates: Requirements 7.1**

**Property 23: MEV Protection via Randomization**
*For any* batch of trades being settled, the transaction ordering SHALL be randomized within the MPC engine to prevent MEV extraction.
**Validates: Requirements 14.3**

### Cross-Chain Properties

**Property 24: Atomic Cross-Chain Settlement**
*For any* cross-chain trade, settlement SHALL use HTLCs to ensure atomicity, and if settlement fails on one chain, it SHALL automatically rollback on the other chain.
**Validates: Requirements 35.1, 35.2**

**Property 25: Cross-Chain Timeout Handling**
*For any* cross-chain settlement, if the timeout expires without completion, both parties SHALL be refunded.
**Validates: Requirements 35.3, 35.4**

**Property 26: Cross-Chain Settlement Proof**
*For any* completed cross-chain settlement, the system SHALL provide cryptographic proof of atomic settlement across both chains.
**Validates: Requirements 35.5**

**Property 27: Token Pair Chain Validation**
*For any* quote request or order, the system SHALL validate that the specified token pair is available on the target chain before processing.
**Validates: Requirements 9.5**

### Oracle & Liquidity Properties

**Property 28: Oracle Signature Verification**
*For any* external price feed used by market makers, the system SHALL verify the oracle signature before accepting the price.
**Validates: Requirements 37.1**

**Property 29: Multi-Source Price Aggregation**
*For any* price reference, the system SHALL aggregate prices from multiple oracle sources to prevent single-point manipulation.
**Validates: Requirements 37.2**

**Property 30: Price Deviation Detection**
*For any* quote, if it deviates more than 5% from the oracle reference price, the system SHALL flag or reject it.
**Validates: Requirements 37.3, 37.5**

**Property 31: Liquidity Aggregation**
*For any* quote request with multiple market maker responses, the system SHALL aggregate available liquidity across all responses.
**Validates: Requirements 38.1**

**Property 32: Order Splitting for Large Requests**
*For any* quote request that exceeds a single market maker's capacity, the system SHALL split the order across multiple market makers to fulfill it.
**Validates: Requirements 38.2**

**Property 33: Routing Cost Optimization**
*For any* order routing decision, the system SHALL minimize total execution cost (price + fees) across available market makers.
**Validates: Requirements 38.3**

**Property 34: Partial Fill Support**
*For any* order with insufficient liquidity, the system SHALL support partial fills with the best-available liquidity.
**Validates: Requirements 38.5**

### Fee & Incentive Properties

**Property 35: Fee Calculation Consistency**
*For any* selected quote, the system SHALL calculate the market maker fee based on trade volume using a consistent formula.
**Validates: Requirements 12.1**

**Property 36: Fee Transfer to Stealth Address**
*For any* settled trade, the market maker fee SHALL be transferred to the market maker's stealth address.
**Validates: Requirements 12.2**

**Property 37: Reputation Score Tracking**
*For any* market maker providing liquidity, the system SHALL track and update their reputation score based on quote acceptance and performance.
**Validates: Requirements 12.3**

### Chat System Properties

**Property 38: Chat Channel Establishment**
*For any* quote response or matched trade, a chat channel SHALL be established between the two parties using peer-to-peer connections.
**Validates: Requirements 26.1, 26.3, 26.4**

**Property 39: End-to-End Chat Encryption**
*For any* message sent through a chat channel, it SHALL be encrypted end-to-end with forward secrecy using ephemeral session keys.
**Validates: Requirements 26.2, 27.1, 27.2**

**Property 40: Ephemeral Key Deletion**
*For any* chat session that ends, the ephemeral encryption keys SHALL be deleted to prevent retroactive decryption.
**Validates: Requirements 27.3**

**Property 41: Decentralized Chat Storage**
*For any* chat message, it SHALL be stored locally on participants' devices and SHALL NOT be stored on any centralized server.
**Validates: Requirements 27.4, 30.1**

**Property 42: Anonymous Chat Routing**
*For any* chat channel, all traffic SHALL be routed through TOR/SOCKS5 by default, and DNS resolution SHALL go through TOR to prevent leaks.
**Validates: Requirements 28.1, 28.2, 28.5**

**Property 43: Chat Message Ordering**
*For any* chat channel, messages SHALL be delivered and displayed in the order they were sent.
**Validates: Requirements 29.5**

**Property 44: Chat Key Exchange via MPC**
*For any* chat channel establishment, public keys SHALL be exchanged through the MPC engine and verified using WOTS+ signatures.
**Validates: Requirements 39.2, 39.3**

**Property 45: Diffie-Hellman Session Keys**
*For any* chat channel, session keys SHALL be established using Diffie-Hellman key exchange.
**Validates: Requirements 39.1**

### Compliance Properties

**Property 46: Selective Disclosure with Viewing Keys**
*For any* trade in COMPLIANT mode, authorized auditors with viewing keys SHALL be able to decrypt only the trades associated with that key, while other trades remain private.
**Validates: Requirements 13.3, 13.4**

## Error Handling

### Error Categories

**1. MPC Engine Errors**
- **Encryption Failure**: Retry with exponential backoff, alert user after 3 attempts
- **Decryption Failure**: Return descriptive error, log for debugging
- **Comparison Timeout**: Queue operation, retry when MPC engine recovers
- **Circuit Breaker**: Reject new operations when MPC is unavailable

**2. Settlement Errors**
- **On-Chain Failure**: Retry with exponential backoff (max 5 attempts)
- **Insufficient Gas**: Warn user, suggest gas price adjustment
- **Cross-Chain Rollback**: Automatically rollback on both chains
- **HTLC Timeout**: Refund both parties, log incident

**3. Network Errors**
- **TOR Unavailable**: Warn user, offer direct connection fallback
- **Peer Disconnection**: Queue messages, retry when peer reconnects
- **RPC Timeout**: Retry with different RPC endpoint
- **Network Partition**: Queue operations, process when connectivity restored

**4. Validation Errors**
- **Invalid Nonce**: Reject with "replay attack detected" error
- **Expired Timestamp**: Reject with "request expired" error
- **Invalid Signature**: Reject with "authentication failed" error
- **Token Not Available**: Reject with "token not supported on chain" error

**5. Business Logic Errors**
- **Insufficient Liquidity**: Notify user with available liquidity
- **Quote Timeout**: Reject late quotes, notify market maker
- **Order Already Cancelled**: Return "order not found" error
- **Price Deviation**: Reject quote with "price manipulation detected" error

### Error Recovery Strategies

**Circuit Breaker Pattern:**
```typescript
interface CircuitBreaker {
  state: 'CLOSED' | 'OPEN' | 'HALF_OPEN';
  failureCount: number;
  failureThreshold: number;
  timeout: number;
  lastFailureTime: number;
}

// Open circuit after 5 failures
// Half-open after 30 seconds
// Close after successful operation
```

**Exponential Backoff:**
```typescript
function calculateBackoff(attempt: number): number {
  const baseDelay = 1000; // 1 second
  const maxDelay = 32000; // 32 seconds
  return Math.min(baseDelay * Math.pow(2, attempt), maxDelay);
}
```

**Graceful Degradation:**
- MPC unavailable → Queue operations, process when available
- TOR unavailable → Warn user, offer direct connection
- Oracle unavailable → Use cached prices with staleness warning
- Settlement failure → Retry with different gas price

## Testing Strategy

### Dual Testing Approach

The system requires both unit testing and property-based testing for comprehensive coverage:

**Unit Tests:**
- Specific examples demonstrating correct behavior
- Edge cases (empty orders, zero amounts, boundary values)
- Error conditions (invalid signatures, expired timestamps)
- Integration points between components
- Mock MPC engine for isolated testing

**Property-Based Tests:**
- Universal properties across all inputs (see Correctness Properties section)
- Randomized input generation for comprehensive coverage
- Minimum 100 iterations per property test
- Each property test references its design document property

### Property Test Configuration

**Test Framework:** Vitest with fast-check for property-based testing

**Configuration:**
```typescript
import { test } from 'vitest';
import * as fc from 'fast-check';

// Property test template
test('Property N: [Property Title]', () => {
  fc.assert(
    fc.property(
      // Generators for random inputs
      fc.record({
        tokenIn: fc.string(),
        tokenOut: fc.string(),
        amount: fc.bigInt({ min: 1n, max: 1000000n })
      }),
      // Property assertion
      (input) => {
        // Test property holds for all inputs
        const result = systemUnderTest(input);
        return assertProperty(result);
      }
    ),
    { numRuns: 100 } // Minimum 100 iterations
  );
}, {
  // Tag format for traceability
  meta: {
    feature: 'dark-otc-rfq',
    property: 1,
    description: 'RFQ Data Encryption'
  }
});
```

### Test Coverage Requirements

**Unit Test Coverage:**
- RFQ Service: Quote creation, submission, selection, cancellation
- Dark Pool Service: Order submission, matching, cancellation
- Settlement Service: EVM settlement, Solana settlement, cross-chain
- Chat Service: Channel establishment, message encryption, key exchange
- Auth Service: WOTS+ signing, verification, nonce validation

**Property Test Coverage:**
- All 46 correctness properties MUST have corresponding property tests
- Each property test MUST run minimum 100 iterations
- Each property test MUST be tagged with feature name and property number

**Integration Test Coverage:**
- End-to-end RFQ flow (create → quote → select → settle)
- End-to-end dark pool flow (submit → match → settle)
- Cross-chain settlement with rollback
- Chat establishment and message exchange
- MPC engine integration

**Performance Test Coverage:**
- Quote response time < 2 seconds (Requirement 18.1)
- Order matching time < 500ms (Requirement 18.2)
- 1000 concurrent quote requests (Requirement 18.3)
- 10,000 active orders (Requirement 18.4)
- 100 settlements per minute (Requirement 18.5)

### Test Data Generation

**Generators for Property Tests:**
```typescript
// Quote request generator
const quoteRequestGen = fc.record({
  tokenIn: fc.constantFrom('ETH', 'USDC', 'USDT', 'DAI'),
  tokenOut: fc.constantFrom('ETH', 'USDC', 'USDT', 'DAI'),
  amountIn: fc.bigInt({ min: 1n, max: 1000000n * 10n**18n }),
  chain: fc.constantFrom('evm', 'solana'),
  timeout: fc.integer({ min: 30, max: 300 }),
  privacyLevel: fc.constantFrom('SHIELDED', 'COMPLIANT', 'TRANSPARENT')
});

// Order generator
const orderGen = fc.record({
  tokenIn: fc.constantFrom('ETH', 'USDC', 'USDT', 'DAI'),
  tokenOut: fc.constantFrom('ETH', 'USDC', 'USDT', 'DAI'),
  amount: fc.bigInt({ min: 1n, max: 1000000n * 10n**18n }),
  limitPrice: fc.bigInt({ min: 1n, max: 10000n * 10n**18n }),
  side: fc.constantFrom('BUY', 'SELL'),
  chain: fc.constantFrom('evm', 'solana'),
  privacyLevel: fc.constantFrom('SHIELDED', 'COMPLIANT', 'TRANSPARENT')
});

// Market maker quote generator
const quoteGen = fc.record({
  price: fc.bigInt({ min: 1n, max: 10000n * 10n**18n }),
  liquidity: fc.bigInt({ min: 1n, max: 1000000n * 10n**18n }),
  fee: fc.bigInt({ min: 0n, max: 1000n * 10n**15n }), // Max 0.1%
  validUntil: fc.integer({ min: Date.now(), max: Date.now() + 300000 })
});
```

### Mock MPC Engine

For unit testing without actual MPC infrastructure:

```typescript
class MockMPCEngine implements ArciumMPCClient {
  private encryptedData: Map<string, Uint8Array> = new Map();
  
  async encrypt(data: Uint8Array, context: string): Promise<Uint8Array> {
    // Simple XOR encryption for testing
    const key = new TextEncoder().encode(context);
    const encrypted = new Uint8Array(data.length);
    for (let i = 0; i < data.length; i++) {
      encrypted[i] = data[i] ^ key[i % key.length];
    }
    return encrypted;
  }
  
  async decrypt(encrypted: Uint8Array, context: string): Promise<Uint8Array> {
    // XOR decryption (symmetric)
    return this.encrypt(encrypted, context);
  }
  
  async compare(a: Uint8Array, b: Uint8Array, op: string): Promise<boolean> {
    // Decrypt and compare for testing
    const aVal = new DataView(a.buffer).getBigUint64(0);
    const bVal = new DataView(b.buffer).getBigUint64(0);
    switch (op) {
      case 'LT': return aVal < bVal;
      case 'GT': return aVal > bVal;
      case 'EQ': return aVal === bVal;
      case 'LTE': return aVal <= bVal;
      case 'GTE': return aVal >= bVal;
      default: throw new Error(`Unknown operation: ${op}`);
    }
  }
  
  async selectBest(values: Uint8Array[], criterion: 'MIN' | 'MAX'): Promise<number> {
    // Find min/max index
    let bestIndex = 0;
    let bestValue = new DataView(values[0].buffer).getBigUint64(0);
    
    for (let i = 1; i < values.length; i++) {
      const value = new DataView(values[i].buffer).getBigUint64(0);
      if (criterion === 'MIN' && value < bestValue) {
        bestValue = value;
        bestIndex = i;
      } else if (criterion === 'MAX' && value > bestValue) {
        bestValue = value;
        bestIndex = i;
      }
    }
    
    return bestIndex;
  }
  
  // ... other methods
}
```

### Continuous Integration

**CI Pipeline:**
1. Lint code (ESLint)
2. Type check (TypeScript)
3. Run unit tests
4. Run property tests (100 iterations each)
5. Run integration tests
6. Check test coverage (>80% required)
7. Build contracts (Foundry + Anchor)
8. Run contract tests
9. Generate test report

**Performance Benchmarks:**
- Run performance tests on every PR
- Compare against baseline metrics
- Fail CI if performance degrades >10%

## Deployment Architecture

### Production Deployment

```
┌─────────────────────────────────────────────────────────────┐
│                     Load Balancer (Global)                   │
│                    (AWS ALB / Cloudflare)                    │
└────────────┬────────────────────────────┬───────────────────┘
             │                            │
    ┌────────▼────────┐          ┌───────▼────────┐
    │   Region: US    │          │  Region: EU    │
    │                 │          │                │
    │  ┌───────────┐  │          │  ┌───────────┐ │
    │  │ Backend   │  │          │  │ Backend   │ │
    │  │ Cluster   │  │          │  │ Cluster   │ │
    │  │ (3 nodes) │  │          │  │ (3 nodes) │ │
    │  └─────┬─────┘  │          │  └─────┬─────┘ │
    │        │        │          │        │       │
    │  ┌─────▼─────┐  │          │  ┌─────▼─────┐ │
    │  │ PostgreSQL│  │          │  │ PostgreSQL│ │
    │  │ (Primary) │  │          │  │ (Replica) │ │
    │  └───────────┘  │          │  └───────────┘ │
    └─────────────────┘          └────────────────┘
             │                            │
             └────────────┬───────────────┘
                          │
                 ┌────────▼────────┐
                 │  Arcium MPC     │
                 │  (Devnet)       │
                 │  Cluster 123    │
                 └─────────────────┘
```

### High Availability Configuration

**Backend Nodes:**
- 3 nodes per region (active-active)
- Health checks every 10 seconds
- Auto-scaling based on load
- Session affinity for chat connections

**Database:**
- PostgreSQL with streaming replication
- Primary in US, replica in EU
- Automatic failover with Patroni
- Point-in-time recovery enabled

**MPC Engine:**
- Arcium cluster with 3 nodes
- Redundant RPC endpoints
- Circuit breaker for failures
- Fallback to queued operations

**Monitoring:**
- Prometheus for metrics
- Grafana for dashboards
- AlertManager for alerts
- Distributed tracing with Jaeger

### Security Hardening

**Network Security:**
- TLS 1.3 for all connections
- mTLS for backend-to-MPC communication
- DDoS protection via Cloudflare
- Rate limiting per IP and user

**Application Security:**
- Input validation on all endpoints
- SQL injection prevention (parameterized queries)
- XSS prevention (content security policy)
- CSRF protection (tokens)

**Secrets Management:**
- AWS Secrets Manager / HashiCorp Vault
- Rotate secrets every 90 days
- Encrypt secrets at rest
- Audit all secret access

**Audit Logging:**
- Log all critical operations
- Immutable audit log (append-only)
- Centralized logging with ELK stack
- Retain logs for 7 years (compliance)

