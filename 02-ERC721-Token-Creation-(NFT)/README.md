# 🎨 ERC721 NFT Creation Project

> An educational NFT project inspired by Venezuelan culture, developed by Gustavo from Caracas

## 📋 Project Description

This project implements a comprehensive ERC721 (NFT) token creation system that combines non-fungible token functionality with Venezuelan cultural identity. The system consists of two smart contracts working together to create a functional and educational NFT collection platform.

### 🏗️ NFT Architecture

```
┌─────────────────────────┐    ┌─────────────────────────┐
│    GustavoCaracasNFT    │    │  GustavoCaracasArtNFT   │
│      (ERC721.sol)       │    │   (customERC721.sol)    │
│                         │    │                         │
│ • Base ERC721           │    │ • Extended ERC721       │
│ • Educational Focus     │    │ • Payment System        │
│ • Metadata Support      │    │ • Whitelist Features    │
│ • Access Control        │    │ • Revenue Sharing       │
│ • Security Features     │    │ • Batch Operations      │
└─────────────────────────┘    └─────────────────────────┘
                │                           │
                │                           │
                └───────────────────────────┘
                         Inheritance
```

## 🚀 Main Features

### 🎨 **GustavoCaracasNFT (ERC721.sol)** - Base NFT Contract

- **Standard**: Complete ERC721 implementation
- **Purpose**: Educational NFT collection foundation
- **Features**:
  - Standard ERC721 functionality
  - Custom metadata support
  - Access control with ownership
  - Security features and validations
  - Educational conversion functions
  - Complete NatSpec documentation

### 🖼️ **GustavoCaracasArtNFT (customERC721.sol)** - Advanced NFT Contract

- **Standard**: Extended ERC721 with payment system
- **Purpose**: Commercial NFT collection with advanced features
- **Features**:
  - Payment system for minting
  - Whitelist and public sale management
  - Revenue sharing mechanism
  - Batch minting operations
  - Pausable functionality
  - Free mint eligibility system

## 🔧 Technical Functionalities

### 🔒 Security Features

- ✅ Zero address validation
- ✅ Ownership verification
- ✅ Access control modifiers
- ✅ Reentrancy protection
- ✅ Input validation
- ✅ Pausable functionality
- ✅ Mint limits per address
- ✅ Supply cap enforcement

### 🎨 NFT Management

- ✅ Token minting and burning
- ✅ Metadata management
- ✅ URI handling
- ✅ Batch operations
- ✅ Whitelist management
- ✅ Payment processing
- ✅ Revenue distribution
- ✅ Collection statistics

### 🎓 Educational Functions

- ✅ Token ID generation and tracking
- ✅ Metadata queries and management
- ✅ Minting eligibility verification
- ✅ Collection information display
- ✅ Revenue and statistics tracking
- ✅ Educational helper functions

## 📖 Usage Guide

### 1. 🚀 Contract Deployment

```solidity
// 1. Deploy Base NFT Contract
GustavoCaracasNFT baseNFT = new GustavoCaracasNFT(
    "Gustavo Caracas NFT",
    "GCNFT",
    "https://api.example.com/metadata/",
    1000 // maxSupply
);

// 2. Deploy Advanced NFT Contract
GustavoCaracasArtNFT artNFT = new GustavoCaracasArtNFT(
    "Gustavo Caracas Art",
    "GCART",
    "https://api.example.com/art/",
    500, // maxSupply
    0.01 ether, // mintPrice
    5 // maxPerAddress
);
```

### 2. 🎨 Basic NFT Operations

```solidity
// Base NFT Contract Operations

// 1. Mint NFT (owner only)
baseNFT.safeMint(userAddress, "Token Name", "Description", "image_url");

// 2. Set base URI
baseNFT.setBaseURI("https://new-api.example.com/metadata/");

// 3. Get token information
string memory tokenURI = baseNFT.tokenURI(tokenId);
(string memory name, string memory description, string memory imageURI) = 
    baseNFT.getTokenMetadata(tokenId);
```

### 3. 💰 Advanced NFT Operations

```solidity
// Advanced NFT Contract Operations

// 1. Public minting (with payment)
artNFT.publicMint{value: 0.01 ether}("Art Name", "Description", "image_url");

// 2. Whitelist management
artNFT.addToWhitelist(userAddress);
artNFT.whitelistMint{value: 0.005 ether}("Art Name", "Description", "image_url");

// 3. Batch minting (owner)
address[] memory recipients = [user1, user2, user3];
string[] memory names = ["Art1", "Art2", "Art3"];
artNFT.batchMint(recipients, names, descriptions, imageURIs);

// 4. Revenue withdrawal
artNFT.withdrawRevenue();
```

### 4. 📊 Information Queries

```solidity
// Collection information
uint256 totalSupply = artNFT.totalSupply();
uint256 maxSupply = artNFT.maxSupply();
uint256 mintPrice = artNFT.mintPrice();
bool publicSaleActive = artNFT.publicSaleActive();

// User information
uint256 userMintCount = artNFT.mintedCount(userAddress);
bool isWhitelisted = artNFT.whitelist(userAddress);
bool canFreeMint = artNFT.freeMintEligible(userAddress);

// Revenue information
uint256 totalRevenue = artNFT.totalRevenue();
```

## 🎯 Use Cases

### 📚 **Educational**

- Learning ERC721 (NFT) standard implementation
- Understanding NFT minting and metadata
- Studying payment systems in smart contracts
- Practice with access control and security
- Exploring batch operations and gas optimization
- Understanding revenue sharing mechanisms

### 🔬 **Testing and Development**

- NFT collection testing and deployment
- Marketplace integration development
- User interface for NFT interactions
- Smart contract security auditing
- Gas optimization analysis
- Payment system testing

### 🌟 **Demonstration**

- Blockchain and NFT development skills showcase
- Web3 development portfolio piece
- Cultural identity example in NFT space
- Reference for NFT collection projects
- Reference for similar projects

## 🛠️ Technical Specifications

### 📋 Requirements

- **Solidity**: ^0.8.28
- **License**: MIT
- **Network**: Compatible with any EVM
- **Dependencies**: OpenZeppelin Contracts
- **Gas**: Optimized for efficiency

### 📊 NFT Parameters

**GustavoCaracasNFT (Base Contract)**
- **Standard**: ERC721
- **Max Supply**: Configurable
- **Metadata**: Custom structure support
- **Access**: Owner-controlled minting

**GustavoCaracasArtNFT (Advanced Contract)**
- **Mint Price**: Configurable (e.g., 0.01 ETH)
- **Max Per Address**: Configurable limit
- **Revenue Sharing**: 80% Creator / 20% Platform
- **Whitelist**: Supported with discounted pricing
- **Batch Operations**: Supported

### 🔍 Main Events

```solidity
// Standard ERC721 Events
event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

// Custom NFT Events
event TokenMinted(address indexed to, uint256 indexed tokenId, string name);
event RevenueWithdrawn(address indexed recipient, uint256 amount);
event WhitelistUpdated(address indexed user, bool status);
event SaleStatusChanged(bool publicSale, bool whitelist);
```

## 🔐 Administration Functions

### 👑 Owner Role

The contract owner can:

**Base NFT Contract:**
- 🎨 Mint NFTs to any address
- 🔗 Update base URI for metadata
- 📊 Monitor collection statistics
- 🔄 Transfer ownership

**Advanced NFT Contract:**
- 💰 Set mint prices and limits
- ⏸️ Pause/unpause contract operations
- 👥 Manage whitelist addresses
- 💸 Withdraw collected revenue
- 🎯 Control sale phases (public/whitelist)
- 📦 Perform batch operations

### 🛡️ Security Modifiers

```solidity
modifier onlyOwner()         // Only the contract owner
modifier whenNotPaused()     // Only when contract is active
modifier validAddress()      // Valid addresses only
modifier withinLimits()      // Respects minting limits
```

## 📈 Metrics and Statistics

### 📊 Trackable Information

- Total NFTs minted
- Current supply vs max supply
- Total revenue collected
- Number of unique holders
- Minting history per address
- Whitelist status and usage
- Sale phase status

### 🔍 Query Functions

```solidity
// Standard ERC721 Functions
name()                      // Collection name
symbol()                    // Collection symbol
totalSupply()               // Current total supply
balanceOf(address)          // NFTs owned by address
ownerOf(uint256)            // Owner of specific token
tokenURI(uint256)           // Metadata URI for token

// Custom NFT Functions
maxSupply()                 // Maximum collection size
mintPrice()                 // Current mint price
mintedCount(address)        // NFTs minted by address
whitelist(address)          // Check whitelist status
freeMintEligible(address)   // Check free mint eligibility
totalRevenue()              // Total revenue collected
publicSaleActive()          // Public sale status
whitelistActive()           // Whitelist sale status

// Educational Utilities
getTokenMetadata(uint256)   // Get custom metadata
getCollectionInfo()         // Complete collection stats
getUserMintingInfo(address) // User-specific minting data
```

## 🌟 Venezuelan Cultural Identity

### 🇻🇪 Cultural Elements

- **Gustavo Caracas**: Personal identity representing Venezuelan heritage
- **Art Collection**: Celebrating Venezuelan culture through digital art
- **Educational Mission**: Sharing blockchain knowledge with Venezuelan community
- **Cultural Bridge**: Connecting traditional Venezuelan values with modern technology

### 🎨 Thematic Implementation

- `GustavoCaracasNFT` - Base collection honoring Venezuelan identity
- `GustavoCaracasArtNFT` - Advanced art collection with cultural themes
- Contract names reflect personal Venezuelan connection
- Educational focus on empowering Venezuelan developers
- Bilingual documentation (Spanish/English) for accessibility

## 👨🏽‍💻 Developer Information

**Author**: Gustavo  
**Location**: Madrid, Spain 🇻🇪  
**Purpose**: Educational project and skills demonstration  
**License**: MIT

## 🚀 Next Steps

### 🔮 Future Improvements

- [ ] Web interface for NFT minting and management
- [ ] IPFS integration for decentralized metadata storage
- [ ] Marketplace integration (OpenSea, Rarible)
- [ ] Royalty system implementation
- [ ] Venezuelan-themed artwork and metadata
- [ ] Multi-chain deployment (Polygon, BSC)
- [ ] Mobile app for collection management
- [ ] Advanced analytics dashboard

### 🧪 Testing

- [ ] Complete unit test suite for both contracts
- [ ] Integration tests for minting workflows
- [ ] Payment system testing
- [ ] Gas optimization analysis
- [ ] Security audit and penetration testing
- [ ] Frontend integration testing
- [ ] Performance benchmarking
- [ ] Cross-chain compatibility testing

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

**Made with ❤️ from Madrid, Spain! 🇻🇪**
