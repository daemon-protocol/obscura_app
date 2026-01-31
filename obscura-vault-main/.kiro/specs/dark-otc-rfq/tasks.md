# Implementation Plan: Dark OTC RFQ / Dark DEX

## Overview

This implementation plan breaks down the Dark OTC RFQ / Dark DEX system into discrete, incremental coding tasks. The system will be implemented in TypeScript within the existing Obscura monorepo structure, leveraging Arcium MPC for confidential computation, SIP for privacy-preserving settlement, and WOTS+ for post-quantum security.

## Tasks

- [ ] 1. Set up project structure and core types
  - Create `packages/backend/src/rfq/` directory for RFQ system
  - Create `packages/backend/src/darkpool/` directory for dark pool
  - Create `packages/backend/src/chat/` directory for chat system
  - Define core TypeScript interfaces and types in `types.ts` files
  - Set up test directories with Vitest configuration
  - _Requirements: All requirements (foundational)_

- [ ] 2. Implement Arcium MPC client wrapper
  - [ ] 2.1 Create ArciumMPCClient class
    - Implement encryption/decryption methods
    - Implement comparison operations (LT, GT, EQ, LTE, GTE)
    - Implement selectBest for quote selection
    - Implement arithmetic operations (add, subtract, multiply)
    - Add batch operation support for performance
    - _Requirements: 1.1, 1.2, 2.1, 2.2, 3.1, 4.1, 4.2, 4.3, 5.1_
  
  - [ ] 2.2 Write property test for MPC encryption
    - Property 1: RFQ Data Encryption
    - Validates: Requirements 1.1, 1.2, 1.4
  
  - [ ] 2.3 Write property test for MPC comparison
    - Property 3: Confidential Quote Selection
    - Validates: Requirements 3.1, 3.2, 3.4
  
  - [ ] 2.4 Implement MPC performance benchmarking
    - Add benchmark() method to measure latency
    - Implement performance monitoring and alerting
    - _Requirements: 36.1, 36.2, 36.5_
  
  - [ ] 2.5 Write property test for MPC determinism
    - Property 4: Quote Selection Determinism
    - Validates: Requirements 3.5

- [ ] 3. Implement authentication and WOTS+ integration
  - [ ] 3.1 Create AuthService class
    - Integrate with existing WOTSScheme from crypto package
    - Implement sign() and verify() methods
    - Implement key pool management (getKey, markKeyUsed)
    - Implement nonce registry for replay protection
    - _Requirements: 8.1, 8.2, 8.4, 8.5, 34.1, 34.2, 34.3, 34.5_
  
  - [ ] 3.2 Write property test for WOTS+ key uniqueness
    - Property 18: WOTS+ Key Uniqueness
    - Validates: Requirements 8.5
  
  - [ ] 3.3 Write property test for nonce uniqueness
    - Property 20: Replay Protection via Nonces
    - Validates: Requirements 34.1, 34.2, 34.3, 34.5
  
  - [ ] 3.4 Write property test for timestamp validation
    - Property 21: Timestamp Freshness
    - Validates: Requirements 34.4

- [ ] 4. Implement RFQ Service core functionality
  - [ ] 4.1 Create RFQService class
    - Implement createQuoteRequest() with MPC encryption
    - Implement submitQuote() with validation
    - Implement selectBestQuote() using MPC comparison
    - Implement cancelQuoteRequest() with notifications
    - Implement getQuoteRequestStatus()
    - _Requirements: 1.1, 1.2, 1.3, 1.5, 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.3, 3.4, 10.1, 10.2, 10.3, 10.4_
  
  - [ ] 4.2 Write property test for quote request encryption
    - Property 1: RFQ Data Encryption
    - Validates: Requirements 1.1, 1.2, 1.4
  
  - [ ] 4.3 Write property test for quote response encryption
    - Property 2: Quote Response Encryption
    - Validates: Requirements 2.1, 2.2
  
  - [ ] 4.4 Write property test for quote request uniqueness
    - Property 5: Quote Request Uniqueness
    - Validates: Requirements 1.5
  
  - [ ] 4.5 Write property test for quote timeout enforcement
    - Property 7: Quote Timeout Enforcement
    - Validates: Requirements 2.5, 10.2
  
  - [ ] 4.6 Write unit tests for RFQ edge cases
    - Test empty quote responses
    - Test expired quote requests
    - Test invalid signatures
    - _Requirements: 2.5, 10.2, 8.1_

- [ ] 5. Checkpoint - Ensure RFQ core tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 6. Implement Dark Pool Service core functionality
  - [ ] 6.1 Create DarkPoolService class
    - Implement submitOrder() with MPC encryption
    - Implement cancelOrder() with matching engine removal
    - Implement modifyOrder() as cancel + resubmit
    - Implement getOrderStatus()
    - Implement getUserOrders()
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 11.1, 11.2, 11.3, 11.4, 11.5_
  
  - [ ] 6.2 Write property test for order encryption
    - Property 9: Order Data Encryption
    - Validates: Requirements 4.1, 4.2, 4.3, 4.5
  
  - [ ] 6.3 Write property test for order cancellation finality
    - Property 13: Order Cancellation Finality
    - Validates: Requirements 11.1, 11.5
  
  - [ ] 6.4 Write property test for order modification semantics
    - Property 14: Order Modification Semantics
    - Validates: Requirements 11.2

- [ ] 7. Implement Matching Engine
  - [ ] 7.1 Create MatchingEngine class
    - Implement EncryptedOrderBook with MPC storage
    - Implement EncryptedPriorityQueue for price-time priority
    - Implement matchOrders() with continuous matching loop
    - Implement addOrder() and removeOrder()
    - Implement getAggregatedLiquidity()
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_
  
  - [ ] 7.2 Write property test for confidential matching
    - Property 10: Confidential Order Matching
    - Validates: Requirements 5.1, 5.2
  
  - [ ] 7.3 Write property test for price-time priority
    - Property 11: Price-Time Priority
    - Validates: Requirements 5.5
  
  - [ ] 7.4 Write property test for partial fill consistency
    - Property 12: Partial Fill State Consistency
    - Validates: Requirements 5.4

- [ ] 8. Implement Settlement Layer with SIP integration
  - [ ] 8.1 Create SettlementService class
    - Integrate with existing SIPClient from backend
    - Implement settleTrade() for single-chain settlement
    - Implement settleCrossChainTrade() with HTLCs
    - Implement batchSettle() for gas optimization
    - Implement estimateGas()
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 9.2, 9.3, 9.4, 24.1, 24.2, 24.3, 24.4, 24.5, 35.1, 35.2, 35.3, 35.4, 35.5_
  
  - [ ] 8.2 Write property test for SIP settlement privacy
    - Property 16: SIP Settlement Privacy
    - Validates: Requirements 6.1, 6.2, 6.3, 6.4
  
  - [ ] 8.3 Write property test for atomic cross-chain settlement
    - Property 24: Atomic Cross-Chain Settlement
    - Validates: Requirements 35.1, 35.2
  
  - [ ] 8.4 Write property test for cross-chain timeout handling
    - Property 25: Cross-Chain Timeout Handling
    - Validates: Requirements 35.3, 35.4
  
  - [ ] 8.5 Write unit tests for settlement edge cases
    - Test insufficient gas scenarios
    - Test cross-chain rollback
    - Test HTLC timeout expiry
    - _Requirements: 35.2, 35.4, 24.3_

- [ ] 9. Checkpoint - Ensure settlement tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 10. Implement Market Maker Registry
  - [ ] 10.1 Create MarketMakerRegistry class
    - Implement registerMarketMaker() with credential verification
    - Implement isAuthorized() for whitelist checking
    - Implement addToWhitelist() and removeFromWhitelist()
    - Implement getReputation() with reputation tracking
    - _Requirements: 25.1, 25.2, 25.3, 25.4, 33.1, 33.2, 33.3, 33.4, 33.5_
  
  - [ ] 10.2 Write property test for reputation tracking
    - Property 37: Reputation Score Tracking
    - Validates: Requirements 12.3
  
  - [ ] 10.3 Write unit tests for market maker authorization
    - Test whitelist enforcement
    - Test permissioned vs permissionless modes
    - Test reputation score updates
    - _Requirements: 33.1, 33.2, 33.3, 33.4, 33.5_

- [ ] 11. Implement Oracle Integration
  - [ ] 11.1 Create OracleService class
    - Integrate with Chainlink and Pyth clients
    - Implement getPrice() with multi-source aggregation
    - Implement verifyOracleSignature()
    - Implement checkDeviation() with 5% threshold
    - _Requirements: 25.5, 37.1, 37.2, 37.3, 37.4, 37.5_
  
  - [ ] 11.2 Write property test for oracle signature verification
    - Property 28: Oracle Signature Verification
    - Validates: Requirements 37.1
  
  - [ ] 11.3 Write property test for price deviation detection
    - Property 30: Price Deviation Detection
    - Validates: Requirements 37.3, 37.5
  
  - [ ] 11.4 Write property test for multi-source aggregation
    - Property 29: Multi-Source Price Aggregation
    - Validates: Requirements 37.2

- [ ] 12. Implement Liquidity Aggregation and Routing
  - [ ] 12.1 Add liquidity aggregation to RFQService
    - Implement aggregateLiquidity() across multiple market makers
    - Implement splitOrder() for large requests
    - Implement optimizeRouting() to minimize execution cost
    - Implement partialFill() support
    - _Requirements: 38.1, 38.2, 38.3, 38.4, 38.5_
  
  - [ ] 12.2 Write property test for liquidity aggregation
    - Property 31: Liquidity Aggregation
    - Validates: Requirements 38.1
  
  - [ ] 12.3 Write property test for order splitting
    - Property 32: Order Splitting for Large Requests
    - Validates: Requirements 38.2
  
  - [ ] 12.4 Write property test for routing optimization
    - Property 33: Routing Cost Optimization
    - Validates: Requirements 38.3

- [ ] 13. Implement Fee Calculation and Distribution
  - [ ] 13.1 Add fee logic to RFQService and SettlementService
    - Implement calculateFee() based on trade volume
    - Implement transferFee() to market maker stealth address
    - Implement configurable fee structures per token pair
    - _Requirements: 12.1, 12.2, 12.4, 12.5_
  
  - [ ] 13.2 Write property test for fee calculation
    - Property 35: Fee Calculation Consistency
    - Validates: Requirements 12.1
  
  - [ ] 13.3 Write property test for fee transfer
    - Property 36: Fee Transfer to Stealth Address
    - Validates: Requirements 12.2

- [ ] 14. Implement Private Chat System - Core
  - [ ] 14.1 Create ChatService class
    - Implement establishChannel() with P2P connections
    - Implement sendMessage() with end-to-end encryption
    - Implement receiveMessages() with local storage
    - Implement getChannelStatus() with presence tracking
    - Implement closeChannel() with key deletion
    - _Requirements: 26.1, 26.2, 26.3, 26.4, 26.5, 27.1, 27.2, 27.3, 27.4, 29.1, 29.2, 29.5, 30.1, 30.2_
  
  - [ ] 14.2 Write property test for chat channel establishment
    - Property 38: Chat Channel Establishment
    - Validates: Requirements 26.1, 26.3, 26.4
  
  - [ ] 14.3 Write property test for end-to-end encryption
    - Property 39: End-to-End Chat Encryption
    - Validates: Requirements 26.2, 27.1, 27.2
  
  - [ ] 14.4 Write property test for ephemeral key deletion
    - Property 40: Ephemeral Key Deletion
    - Validates: Requirements 27.3

- [ ] 15. Implement Private Chat System - TOR Integration
  - [ ] 15.1 Create TORClient class
    - Implement SOCKS5 proxy connection
    - Implement TOR circuit establishment
    - Implement DNS leak prevention
    - Implement fallback handling when TOR unavailable
    - _Requirements: 28.1, 28.2, 28.3, 28.4, 28.5_
  
  - [ ] 15.2 Write property test for anonymous routing
    - Property 42: Anonymous Chat Routing
    - Validates: Requirements 28.1, 28.2, 28.5
  
  - [ ] 15.3 Write unit tests for TOR fallback
    - Test TOR unavailable scenario
    - Test DNS leak prevention
    - Test custom SOCKS5 endpoints
    - _Requirements: 28.3, 28.4, 28.5_

- [ ] 16. Implement Chat Key Exchange
  - [ ] 16.1 Add key exchange to ChatService
    - Implement Diffie-Hellman key exchange
    - Implement public key exchange through MPC
    - Implement WOTS+ signature verification for keys
    - Implement key rotation for long-lived channels
    - Implement retry with exponential backoff
    - _Requirements: 39.1, 39.2, 39.3, 39.4, 39.5_
  
  - [ ] 16.2 Write property test for DH key exchange
    - Property 45: Diffie-Hellman Session Keys
    - Validates: Requirements 39.1
  
  - [ ] 16.3 Write property test for MPC key exchange
    - Property 44: Chat Key Exchange via MPC
    - Validates: Requirements 39.2, 39.3

- [ ] 17. Implement Chat Message Storage and History
  - [ ] 17.1 Add message persistence to ChatService
    - Implement local encrypted storage
    - Implement chat history retrieval
    - Implement export functionality for compliance
    - Implement configurable retention periods
    - Implement deletion functionality
    - _Requirements: 30.1, 30.2, 30.3, 30.4, 30.5_
  
  - [ ] 17.2 Write property test for decentralized storage
    - Property 41: Decentralized Chat Storage
    - Validates: Requirements 27.4, 30.1
  
  - [ ] 17.3 Write property test for message ordering
    - Property 43: Chat Message Ordering
    - Validates: Requirements 29.5

- [ ] 18. Implement Chat Presence and Notifications
  - [ ] 18.1 Add presence tracking to ChatService
    - Implement online/offline status tracking
    - Implement presence notifications
    - Implement typing indicators
    - Implement availability status (online, away, busy)
    - _Requirements: 31.1, 31.2, 31.3, 31.4, 31.5_
  
  - [ ] 18.2 Write unit tests for presence tracking
    - Test online/offline transitions
    - Test typing indicators
    - Test availability status changes
    - _Requirements: 31.1, 31.2, 31.3, 31.4, 31.5_

- [ ] 19. Implement Chat Abuse Prevention
  - [ ] 19.1 Add abuse prevention to ChatService
    - Implement block functionality
    - Implement rate limiting for messages
    - Implement abuse reporting
    - Implement reputation system for flagging
    - _Requirements: 32.1, 32.2, 32.3, 32.4, 32.5_
  
  - [ ] 19.2 Write unit tests for abuse prevention
    - Test blocking functionality
    - Test rate limiting
    - Test reputation flagging
    - _Requirements: 32.1, 32.2, 32.3, 32.4, 32.5_

- [ ] 20. Checkpoint - Ensure chat system tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 21. Implement Compliance and Audit Support
  - [ ] 21.1 Add compliance features to RFQService and DarkPoolService
    - Implement viewing key generation for COMPLIANT mode
    - Implement selective disclosure with viewing keys
    - Implement compliance report generation
    - Implement KYC integration hooks
    - Implement 7-year record retention
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5, 23.1, 23.2, 23.3, 23.4, 23.5_
  
  - [ ] 21.2 Write property test for selective disclosure
    - Property 46: Selective Disclosure with Viewing Keys
    - Validates: Requirements 13.3, 13.4
  
  - [ ] 21.3 Write unit tests for compliance features
    - Test viewing key generation
    - Test compliance report export
    - Test record retention
    - _Requirements: 13.1, 13.2, 23.1, 23.4, 23.5_

- [ ] 22. Implement Error Handling and Recovery
  - [ ] 22.1 Add comprehensive error handling
    - Implement circuit breaker pattern for MPC
    - Implement exponential backoff for retries
    - Implement graceful degradation strategies
    - Implement detailed error logging
    - Implement error categorization (MPC, Settlement, Network, Validation, Business Logic)
    - _Requirements: 15.2, 15.3, 16.1, 16.2, 16.3, 16.4, 16.5_
  
  - [ ] 22.2 Write unit tests for error handling
    - Test MPC timeout handling
    - Test settlement failure retry
    - Test network partition recovery
    - Test validation error messages
    - _Requirements: 16.1, 16.2, 16.3, 16.4_

- [ ] 23. Implement Monitoring and Health Checks
  - [ ] 23.1 Add monitoring infrastructure
    - Implement health check endpoints
    - Implement metrics emission (Prometheus format)
    - Implement performance tracking (quote response time, match rate, settlement success)
    - Implement alerting for MPC unavailability
    - Implement logging for critical operations
    - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5_
  
  - [ ] 23.2 Write unit tests for health checks
    - Test health check endpoint responses
    - Test metrics emission
    - Test MPC unavailability detection
    - _Requirements: 15.1, 15.2, 15.5_

- [ ] 24. Implement High Availability Features
  - [ ] 24.1 Add HA infrastructure
    - Implement state replication across nodes
    - Implement automatic failover logic
    - Implement request queuing for MPC overload
    - Implement load balancing support
    - _Requirements: 17.1, 17.2, 17.3, 17.4, 17.5_
  
  - [ ] 24.2 Write integration tests for HA
    - Test node failover
    - Test state replication
    - Test request queuing
    - _Requirements: 17.1, 17.2, 17.3, 17.5_

- [ ] 25. Implement Disaster Recovery
  - [ ] 25.1 Add backup and recovery
    - Implement automated backup every 5 minutes
    - Implement restore from backup functionality
    - Implement geo-distributed backup storage
    - Implement recovery testing automation
    - _Requirements: 21.1, 21.2, 21.3, 21.4, 21.5_
  
  - [ ] 25.2 Write unit tests for backup/restore
    - Test backup creation
    - Test restore functionality
    - Test backup integrity
    - _Requirements: 21.1, 21.2, 21.5_

- [ ] 26. Implement API Layer with Hono
  - [ ] 26.1 Create HTTP API endpoints
    - POST /rfq/quote-requests - Create quote request
    - POST /rfq/quotes - Submit quote response
    - GET /rfq/quote-requests/:id - Get quote request status
    - DELETE /rfq/quote-requests/:id - Cancel quote request
    - POST /darkpool/orders - Submit order
    - DELETE /darkpool/orders/:id - Cancel order
    - PATCH /darkpool/orders/:id - Modify order
    - GET /darkpool/orders/:id - Get order status
    - GET /darkpool/orders - Get user orders
    - POST /chat/channels - Establish chat channel
    - POST /chat/messages - Send message
    - GET /chat/messages/:channelId - Get messages
    - GET /health - Health check endpoint
    - _Requirements: All API-related requirements_
  
  - [ ] 26.2 Add API versioning and middleware
    - Implement semantic versioning (v1, v2, etc.)
    - Implement rate limiting middleware
    - Implement authentication middleware (WOTS+ verification)
    - Implement request validation middleware
    - Implement CORS configuration
    - _Requirements: 19.2, 22.1, 22.2, 22.3, 22.4, 22.5_
  
  - [ ] 26.3 Write integration tests for API endpoints
    - Test all RFQ endpoints
    - Test all dark pool endpoints
    - Test all chat endpoints
    - Test rate limiting
    - Test authentication
    - _Requirements: All API-related requirements_

- [ ] 27. Implement Security Hardening
  - [ ] 27.1 Add security features
    - Implement multi-factor authentication for privileged operations
    - Implement constant-time cryptographic operations
    - Implement input sanitization
    - Implement SQL injection prevention (parameterized queries)
    - Implement XSS prevention (CSP headers)
    - _Requirements: 19.1, 19.2, 19.3, 19.4, 19.5_
  
  - [ ] 27.2 Write security tests
    - Test MFA enforcement
    - Test timing attack resistance
    - Test injection prevention
    - _Requirements: 19.1, 19.3, 19.5_

- [ ] 28. Implement Data Integrity and Consistency
  - [ ] 28.1 Add data integrity features
    - Implement cryptographic checksums for all data
    - Implement settlement verification against original orders
    - Implement consensus protocols for replication
    - Implement corruption detection and alerting
    - Implement immutable audit log
    - _Requirements: 20.1, 20.2, 20.3, 20.4, 20.5_
  
  - [ ] 28.2 Write property test for data integrity
    - Test checksum verification
    - Test settlement verification
    - Test audit log immutability
    - _Requirements: 20.1, 20.2, 20.5_

- [ ] 29. Implement Performance Optimizations
  - [ ] 29.1 Optimize critical paths
    - Implement MPC operation batching
    - Implement database query optimization
    - Implement caching for frequently accessed data
    - Implement connection pooling
    - Implement async processing for non-critical operations
    - _Requirements: 18.1, 18.2, 18.3, 18.4, 18.5, 36.4_
  
  - [ ] 29.2 Write performance tests
    - Test quote response time < 2s
    - Test order matching time < 500ms
    - Test 1000 concurrent requests
    - Test 10,000 active orders
    - Test 100 settlements/min
    - _Requirements: 18.1, 18.2, 18.3, 18.4, 18.5_

- [ ] 30. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 31. Integration and End-to-End Testing
  - [ ] 31.1 Write end-to-end RFQ flow test
    - Test complete flow: create request → submit quotes → select → settle
    - Test with multiple market makers
    - Test with different privacy levels
    - _Requirements: 1.1-1.5, 2.1-2.5, 3.1-3.5, 6.1-6.5_
  
  - [ ] 31.2 Write end-to-end dark pool flow test
    - Test complete flow: submit orders → match → settle
    - Test with multiple traders
    - Test partial fills
    - _Requirements: 4.1-4.5, 5.1-5.5, 6.1-6.5_
  
  - [ ] 31.3 Write end-to-end cross-chain test
    - Test cross-chain settlement with HTLCs
    - Test rollback on failure
    - Test timeout handling
    - _Requirements: 35.1-35.5_
  
  - [ ] 31.4 Write end-to-end chat test
    - Test chat establishment
    - Test message exchange
    - Test TOR routing
    - Test key rotation
    - _Requirements: 26.1-26.5, 27.1-27.5, 28.1-28.5, 39.1-39.5_

- [ ] 32. Documentation and Deployment Preparation
  - [ ] 32.1 Write API documentation
    - Document all endpoints with OpenAPI/Swagger
    - Write integration guide for market makers
    - Write integration guide for traders
    - Document error codes and handling
    - _Requirements: 22.5_
  
  - [ ] 32.2 Create deployment scripts
    - Write Docker configuration
    - Write Kubernetes manifests
    - Write database migration scripts
    - Write environment configuration templates
    - _Requirements: 17.1, 17.4_
  
  - [ ] 32.3 Create monitoring dashboards
    - Create Grafana dashboards for metrics
    - Create alert rules for critical issues
    - Document runbook for common issues
    - _Requirements: 15.1, 15.5_

- [ ] 33. Final checkpoint - Production readiness
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties (minimum 100 iterations each)
- Unit tests validate specific examples and edge cases
- Integration tests validate end-to-end flows
- The implementation leverages existing Obscura infrastructure (Arcium, SIP, WOTS+, Light Protocol)
- TypeScript is used throughout for type safety and consistency with existing codebase
- All MPC operations use domain-separated encryption contexts for security
- Settlement uses existing SIPClient and contracts (SIPSettlement.sol, Anchor program)
- Chat system is optional and can be implemented in a later phase if needed

