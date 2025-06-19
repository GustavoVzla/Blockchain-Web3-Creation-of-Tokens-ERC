# 🎮 ERC1155 Multi-Token Creation Project

> An educational multi-token gaming ecosystem inspired by Venezuelan culture, developed by Gustavo from Caracas

## 📋 Project Description

This project implements a comprehensive ERC1155 multi-token system that combines gaming functionality with Venezuelan cultural identity. The system consists of two smart contracts working together to create a functional and educational gaming token ecosystem supporting fungible, semi-fungible, and non-fungible tokens in a single contract.

### 🏗️ Ecosystem Architecture

```
┌─────────────────────────────────┐    ┌─────────────────────────────────┐
│     GustavoCaracasMultiToken    │    │    GustavoCaracasGameTokens     │
│         (Base ERC1155)          │    │      (Gaming ERC1155)           │
│                                 │    │                                 │
│ • Multi-Token Standard          │    │ • Gaming Token Economy          │
│ • Fungible/Non-Fungible         │    │ • Role-Based Access Control     │
│ • Batch Operations              │    │ • Marketplace Integration       │
│ • Metadata Management           │    │ • Staking & Rewards System      │
│ • Supply Control                │    │ • Season Management             │
└─────────────────────────────────┘    └─────────────────────────────────┘
                    │                                    ▲
                    │                                    │
                    └────────────────────────────────────┘
                              Inheritance & Extension
```

## 🚀 Main Features

### 🎯 **GustavoCaracasMultiToken** - Base ERC1155 Contract

- **Standard**: Complete ERC1155 Multi-Token
- **Token Types**: Fungible, Semi-Fungible, Non-Fungible
- **Function**: Base multi-token functionality
- **Features**:
  - Multiple token types in one contract
  - Batch operations for gas optimization
  - Flexible supply management
  - Comprehensive metadata system
  - Token creation and management
  - Educational conversion functions

### 🎮 **GustavoCaracasGameTokens** - Gaming ERC1155 Contract

- **Standard**: Extended ERC1155 with gaming features
- **Game Tokens**: 10 predefined gaming token types
- **Function**: Complete gaming token ecosystem
- **Features**:
  - Role-based access control (Minter, Game Master, Marketplace)
  - Built-in marketplace functionality
  - Token staking and rewards system
  - Daily mint limits and restrictions
  - Season management system
  - Trading and pricing mechanisms

## 🔧 Technical Functionalities

### 🔒 Security

- ✅ Zero address validation
- ✅ Sufficient balance verification
- ✅ Multi-token approval control
- ✅ Role-based access modifiers
- ✅ Reentrancy protection
- ✅ Supply limits enforcement
- ✅ Pausable functionality
- ✅ Daily mint limits

### 📊 Multi-Token Management

- ✅ Multiple token types in one contract
- ✅ Fungible, semi-fungible, and non-fungible support
- ✅ Batch operations for gas optimization
- ✅ Individual token supply tracking
- ✅ Token metadata management
- ✅ Creator attribution system

### 🎓 Educational Functions

- ✅ Multi-token standard understanding
- ✅ Token type differentiation (fungible/non-fungible)
- ✅ Batch operations optimization
- ✅ Gaming token economics
- ✅ Role-based access control
- ✅ Marketplace integration patterns

## 📖 Usage Guide

### 1. 🚀 Contract Deployment

```solidity
// 1. Deploy Base ERC1155 Contract
GustavoCaracasMultiToken baseContract = new GustavoCaracasMultiToken(
    "https://api.example.com/metadata/",
    "Gustavo Caracas Multi-Token",
    "GCMT"
);

// 2. Deploy Gaming ERC1155 Contract
GustavoCaracasGameTokens gameContract = new GustavoCaracasGameTokens(
    "https://api.gameexample.com/metadata/",
    "Gustavo Caracas Game Tokens",
    "GCGT"
);
```

### 2. 🎮 Basic Multi-Token Operations

```solidity
// 1. Create a new token type
baseContract.createToken(
    "Gold Coin",
    GustavoCaracasMultiToken.TokenType.FUNGIBLE,
    1000000, // max supply
    "https://api.example.com/metadata/0"
);

// 2. Mint tokens to user
baseContract.mint(userAddress, tokenId, amount, "");

// 3. Batch mint multiple tokens
uint256[] memory ids = [0, 1, 2];
uint256[] memory amounts = [100, 50, 25];
baseContract.mintBatch(userAddress, ids, amounts, "");

// 4. Transfer tokens
baseContract.safeTransferFrom(from, to, tokenId, amount, "");
```

### 3. 🎯 Advanced Gaming Operations

```solidity
// 1. Setup game roles
gameContract.grantRole(gameContract.MINTER_ROLE(), minterAddress);
gameContract.grantRole(gameContract.GAME_MASTER_ROLE(), gameMasterAddress);

// 2. Set token prices and limits
gameContract.setTokenPrice(gameContract.HEALTH_POTION(), 10); // 10 GOLD_COIN
gameContract.setDailyMintLimit(gameContract.HEALTH_POTION(), 5);

// 3. Player purchases items
gameContract.purchaseToken(gameContract.HEALTH_POTION(), 2);

// 4. Stake tokens for rewards
gameContract.stakeTokens(gameContract.RARE_GEM(), 100);
```

### 4. 📊 Information Queries

```solidity
// Token information
GustavoCaracasMultiToken.TokenInfo memory info = baseContract.getTokenInfo(tokenId);

// User balances
uint256 balance = baseContract.balanceOf(userAddress, tokenId);
uint256[] memory balances = baseContract.balanceOfBatch(addresses, tokenIds);

// Gaming statistics
uint256 stakedAmount = gameContract.stakedBalances(tokenId, userAddress);
uint256 dailyMinted = gameContract.dailyMintedAmount(tokenId, userAddress);
bool canMint = gameContract.canMintToday(tokenId, userAddress);
```

## 🎯 Use Cases

### 📚 **Educational**

- Learning ERC1155 multi-token standard
- Understanding gaming token economics
- Studying role-based access control
- Practice with batch operations and gas optimization
- Exploring marketplace integration patterns

### 🔬 **Testing and Development**

- Multi-token contract testing
- Gaming ecosystem simulation
- Marketplace functionality development
- Smart contract security auditing
- Gas optimization analysis

### 🌟 **Demonstration**

- Blockchain gaming skills showcase
- Web3 development portfolio
- Cultural identity example in gaming
- Reference for gaming token projects
- Multi-token standard implementation

## 🛠️ Technical Specifications

### 📋 Requirements

- **Solidity**: ^0.8.28
- **License**: MIT
- **Network**: Compatible with any EVM
- **Gas**: Optimized with batch operations
- **Dependencies**: OpenZeppelin Contracts

### 📊 Multi-Token Parameters

**GustavoCaracasMultiToken:**
- **Token Types**: Fungible, Semi-Fungible, Non-Fungible
- **Supply Management**: Individual max supply per token
- **Metadata**: IPFS-compatible URI system
- **Batch Operations**: Gas-optimized transfers

**GustavoCaracasGameTokens:**
- **Game Tokens**: 10 predefined token types
- **Daily Limits**: Configurable per token type
- **Marketplace Fee**: 2.5% (250 basis points)
- **Season Duration**: 30 days (configurable)
- **Staking Rewards**: Token-specific rates

### 🔍 Main Events

```solidity
// Standard ERC1155 Events
event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);
event ApprovalForAll(address indexed account, address indexed operator, bool approved);
event URI(string value, uint256 indexed id);

// Custom Multi-Token Events
event TokenTypeCreated(uint256 indexed tokenId, string name, TokenType tokenType, uint256 maxSupply, address indexed creator);
event TokensMinted(uint256 indexed tokenId, address indexed to, uint256 amount, address indexed minter);
event TokensBurned(uint256 indexed tokenId, address indexed from, uint256 amount);
event BaseURIUpdated(string newBaseURI);

// Gaming Events
event TokenPurchased(address indexed buyer, uint256 indexed tokenId, uint256 amount, uint256 totalCost);
event TokensStaked(address indexed user, uint256 indexed tokenId, uint256 amount);
event TokensUnstaked(address indexed user, uint256 indexed tokenId, uint256 amount);
event SeasonStarted(uint256 indexed seasonId, uint256 startTime);
event MarketplaceListing(uint256 indexed listingId, address indexed seller, uint256 indexed tokenId, uint256 amount, uint256 price);
```

## 🔐 Administration Functions

### 👑 Owner Role (Base Contract)

The contract owner can:

- 🎨 Create new token types
- 🔧 Update base URI for metadata
- ⏸️ Pause/unpause contract operations
- 🏷️ Update individual token URIs
- 📊 Monitor all token statistics

### 🎮 Gaming Roles (Advanced Contract)

**Game Master Role:**
- 🎯 Set token prices and daily limits
- 🏆 Start new game seasons
- 📈 Configure staking rewards
- 🛒 Manage marketplace settings

**Minter Role:**
- 🪙 Mint tokens to users
- 📦 Execute batch minting operations
- 🎁 Distribute rewards

**Marketplace Role:**
- 🏪 Create and manage listings
- 💰 Process marketplace transactions
- 📊 Update marketplace fees

### 🛡️ Security Modifiers

```solidity
modifier onlyOwner()                    // Only contract owner
modifier onlyRole(bytes32 role)         // Role-based access
modifier whenNotPaused()                // Only when not paused
modifier tokenExists(uint256 tokenId)   // Token must exist
modifier withinSupplyLimit()            // Supply constraints
```

## 📈 Metrics and Statistics

### 📊 Trackable Information

- Total tokens minted per type
- Individual token supplies vs max supplies
- User balances across all token types
- Token creation history and creators
- Gaming statistics (staked amounts, daily mints)
- Marketplace activity and trading volume
- Season progression and rewards
- Role assignments and permissions

### 🔍 Query Functions

```solidity
// Standard ERC1155 Queries
balanceOf(address, uint256)              // Single token balance
balanceOfBatch(address[], uint256[])     // Multiple token balances
isApprovedForAll(address, address)       // Approval status
uri(uint256)                             // Token metadata URI

// Custom Multi-Token Queries
getTokenInfo(uint256)                    // Complete token information
getAllTokenIds()                         // List all existing tokens
totalSupply(uint256)                     // Current supply of token
exists(uint256)                          // Check if token exists

// Gaming-Specific Queries
stakedBalances(uint256, address)         // Staked amount per token
dailyMintedAmount(uint256, address)      // Daily minted by user
canMintToday(uint256, address)           // Check daily limit eligibility
getTokenPrice(uint256)                   // Current token price
getCurrentSeason()                       // Active game season
getMarketplaceListings()                 // Active marketplace listings

// Educational Utilities
getTokensByType(TokenType)               // Filter tokens by type
getUserTokens(address)                   // All tokens owned by user
calculateStakingRewards(uint256, address) // Potential staking rewards
```

## 🌟 Venezuelan Cultural Identity

### 🇻🇪 Cultural Elements

- **Gustavo Caracas**: Personal identity representing Venezuelan heritage
- **Multi-Token Gaming**: Reflects Venezuela's rich gaming culture and creativity
- **Educational Mission**: Sharing knowledge and Venezuelan talent globally
- **Cultural Bridge**: Connecting Venezuelan identity with blockchain innovation

### 🎨 Thematic Implementation

- **Contract Names**: `GustavoCaracasMultiToken` and `GustavoCaracasGameTokens`
- **Gaming Tokens**: Inspired by traditional and modern Venezuelan gaming
- **Educational Focus**: Teaching blockchain development with cultural pride
- **Global Reach**: Venezuelan talent contributing to Web3 ecosystem

## 👨🏽‍💻 Developer Information

**Author**: Gustavo  
**Location**: Madrid, Spain 🇻🇪  
**Purpose**: Educational ERC1155 project and gaming skills demonstration  
**License**: MIT  
**Focus**: Multi-token standards and gaming token economics

## 🚀 Next Steps

### 🔮 Future Improvements

- [ ] Web interface for gaming token management
- [ ] IPFS integration for decentralized metadata
- [ ] Cross-chain bridge for multi-network gaming
- [ ] Advanced marketplace with auctions
- [ ] Venezuelan-themed gaming artwork collection
- [ ] Multi-chain deployment (Polygon, BSC, Arbitrum)
- [ ] Mobile gaming app integration
- [ ] Advanced analytics dashboard
- [ ] Governance token for community decisions
- [ ] Integration with existing gaming platforms

### 🧪 Testing

- [ ] Complete unit test suite for both contracts
- [ ] Integration tests for gaming mechanics
- [ ] Marketplace functionality testing
- [ ] Role-based access control testing
- [ ] Gas optimization analysis for batch operations
- [ ] Security audit for gaming vulnerabilities
- [ ] Frontend integration testing
- [ ] Performance benchmarking
- [ ] Cross-chain compatibility testing
- [ ] Gaming scenario simulation

---

## 📄 License

This project is under the MIT License. See the `LICENSE` file for more details.

## 🤝 Contributions

Contributions are welcome. Please:

1. Fork the project
2. Create a branch for your feature
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

---

**Made with ❤️ from Madrid, Espain! 🇻🇪**
