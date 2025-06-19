// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title Custom ERC1155 Gaming Implementation
 * @author Gustavo - Caracas, Venezuela
 * @notice Advanced multi-token contract for gaming ecosystems
 * @dev Extends the base ERC1155 contract with gaming-specific functionality
 * 
 * Educational Objectives:
 * - Implement complex gaming token economics
 * - Learn about role-based access control
 * - Practice advanced multi-token management
 * - Understand token utility and game mechanics
 * - Explore marketplace and trading functionality
 */
contract GustavoCaracasGameTokens is GustavoCaracasMultiToken, AccessControl {
    using Counters for Counters.Counter;
    using Strings for uint256;

    // ========== ROLES ==========
    
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant GAME_MASTER_ROLE = keccak256("GAME_MASTER_ROLE");
    bytes32 public constant MARKETPLACE_ROLE = keccak256("MARKETPLACE_ROLE");

    // ========== GAME TOKEN IDS ==========
    
    uint256 public constant GOLD_COIN = 0;
    uint256 public constant SILVER_COIN = 1;
    uint256 public constant EXPERIENCE_POINTS = 2;
    uint256 public constant LEGENDARY_SWORD = 3;
    uint256 public constant MAGIC_SHIELD = 4;
    uint256 public constant HEALTH_POTION = 5;
    uint256 public constant MANA_POTION = 6;
    uint256 public constant RARE_GEM = 7;
    uint256 public constant EPIC_ARMOR = 8;
    uint256 public constant MYTHIC_ARTIFACT = 9;

    // ========== STATE VARIABLES ==========
    
    /// @dev Mapping from token ID to price in GOLD_COIN
    mapping(uint256 => uint256) public tokenPrices;
    
    /// @dev Mapping from token ID to daily mint limit per address
    mapping(uint256 => uint256) public dailyMintLimits;
    
    /// @dev Mapping from token ID to address to last mint timestamp
    mapping(uint256 => mapping(address => uint256)) public lastMintTime;
    
    /// @dev Mapping from token ID to address to daily minted amount
    mapping(uint256 => mapping(address => uint256)) public dailyMintedAmount;
    
    /// @dev Mapping for token trading status
    mapping(uint256 => bool) public tradingEnabled;
    
    /// @dev Mapping for token staking
    mapping(uint256 => mapping(address => uint256)) public stakedBalances;
    mapping(uint256 => mapping(address => uint256)) public stakingStartTime;
    
    /// @dev Total staked per token
    mapping(uint256 => uint256) public totalStaked;
    
    /// @dev Marketplace fee percentage (basis points)
    uint256 public marketplaceFee = 250; // 2.5%
    
    /// @dev Marketplace fee recipient
    address public feeRecipient;
    
    /// @dev Game season counter
    Counters.Counter private _seasonCounter;
    
    /// @dev Current game season
    uint256 public currentSeason;
    
    /// @dev Season start time
    uint256 public seasonStartTime;
    
    /// @dev Season duration (default 30 days)
    uint256 public seasonDuration = 30 days;

    // ========== STRUCTS ==========
    
    /**
     * @dev Structure for marketplace listings
     */
    struct MarketplaceListing {
        uint256 tokenId;
        uint256 amount;
        uint256 pricePerToken;
        address seller;
        bool active;
        uint256 listedAt;
    }
    
    /**
     * @dev Structure for player statistics
     */
    struct PlayerStats {
        uint256 totalTokensOwned;
        uint256 totalValueInGold;
        uint256 stakingRewards;
        uint256 tradingVolume;
        uint256 seasonScore;
    }

    // ========== MAPPINGS ==========
    
    /// @dev Marketplace listings
    mapping(uint256 => MarketplaceListing) public marketplaceListings;
    uint256 public nextListingId;
    
    /// @dev Player statistics
    mapping(address => PlayerStats) public playerStats;
    
    /// @dev Season leaderboard
    mapping(uint256 => mapping(address => uint256)) public seasonScores;

    // ========== EVENTS ==========
    
    /**
     * @dev Emitted when tokens are purchased from marketplace
     */
    event TokensPurchased(
        uint256 indexed tokenId,
        address indexed buyer,
        uint256 amount,
        uint256 totalCost
    );
    
    /**
     * @dev Emitted when tokens are staked
     */
    event TokensStaked(
        uint256 indexed tokenId,
        address indexed staker,
        uint256 amount
    );
    
    /**
     * @dev Emitted when tokens are unstaked
     */
    event TokensUnstaked(
        uint256 indexed tokenId,
        address indexed staker,
        uint256 amount,
        uint256 rewards
    );
    
    /**
     * @dev Emitted when marketplace listing is created
     */
    event MarketplaceListingCreated(
        uint256 indexed listingId,
        uint256 indexed tokenId,
        address indexed seller,
        uint256 amount,
        uint256 pricePerToken
    );
    
    /**
     * @dev Emitted when marketplace purchase occurs
     */
    event MarketplacePurchase(
        uint256 indexed listingId,
        uint256 indexed tokenId,
        address indexed buyer,
        address seller,
        uint256 amount,
        uint256 totalPrice
    );
    
    /**
     * @dev Emitted when new season starts
     */
    event NewSeasonStarted(uint256 indexed seasonNumber, uint256 startTime);

    // ========== MODIFIERS ==========
    
    /**
     * @dev Modifier to check daily mint limits
     */
    modifier withinDailyLimit(uint256 tokenId, uint256 amount) {
        if (dailyMintLimits[tokenId] > 0) {
            if (block.timestamp >= lastMintTime[tokenId][msg.sender] + 1 days) {
                dailyMintedAmount[tokenId][msg.sender] = 0;
            }
            require(
                dailyMintedAmount[tokenId][msg.sender] + amount <= dailyMintLimits[tokenId],
                "CustomERC1155: Daily mint limit exceeded"
            );
        }
        _;
    }
    
    /**
     * @dev Modifier to check if trading is enabled for token
     */
    modifier tradingIsEnabled(uint256 tokenId) {
        require(tradingEnabled[tokenId], "CustomERC1155: Trading disabled for this token");
        _;
    }

    // ========== CONSTRUCTOR ==========
    
    /**
     * @dev Constructor for the gaming multi-token contract
     * @param name_ Name of the token collection
     * @param symbol_ Symbol of the token collection
     * @param baseURI_ Base URI for metadata
     * @param _feeRecipient Address to receive marketplace fees
     */
    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        address _feeRecipient
    ) GustavoCaracasMultiToken(name_, symbol_, baseURI_) {
        require(_feeRecipient != address(0), "CustomERC1155: Fee recipient cannot be zero address");
        
        feeRecipient = _feeRecipient;
        
        // Setup roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(GAME_MASTER_ROLE, msg.sender);
        _grantRole(MARKETPLACE_ROLE, msg.sender);
        
        // Initialize game tokens
        _initializeGameTokens();
        
        // Start first season
        _startNewSeason();
    }

    // ========== PUBLIC FUNCTIONS ==========
    
    /**
     * @dev Purchase tokens using GOLD_COIN
     * @param tokenId ID of token to purchase
     * @param amount Amount to purchase
     */
    function purchaseTokens(
        uint256 tokenId,
        uint256 amount
    ) external whenNotPaused tokenExists(tokenId) withinDailyLimit(tokenId, amount) {
        require(tokenPrices[tokenId] > 0, "CustomERC1155: Token not for sale");
        require(amount > 0, "CustomERC1155: Amount must be greater than 0");
        
        uint256 totalCost = tokenPrices[tokenId] * amount;
        require(
            balanceOf(msg.sender, GOLD_COIN) >= totalCost,
            "CustomERC1155: Insufficient GOLD_COIN balance"
        );
        
        // Burn GOLD_COIN
        _burn(msg.sender, GOLD_COIN, totalCost);
        
        // Mint purchased tokens
        _mint(msg.sender, tokenId, amount, "");
        
        // Update statistics
        _updateDailyMintTracking(tokenId, amount);
        _updatePlayerStats(msg.sender, tokenId, amount, totalCost);
        
        emit TokensPurchased(tokenId, msg.sender, amount, totalCost);
    }
    
    /**
     * @dev Stake tokens to earn rewards
     * @param tokenId ID of token to stake
     * @param amount Amount to stake
     */
    function stakeTokens(
        uint256 tokenId,
        uint256 amount
    ) external whenNotPaused tokenExists(tokenId) {
        require(amount > 0, "CustomERC1155: Amount must be greater than 0");
        require(
            balanceOf(msg.sender, tokenId) >= amount,
            "CustomERC1155: Insufficient balance"
        );
        require(
            tokenTypes[tokenId] != TokenType.NON_FUNGIBLE || amount == 1,
            "CustomERC1155: NFTs can only stake 1 at a time"
        );
        
        // Transfer tokens to contract for staking
        _safeTransferFrom(msg.sender, address(this), tokenId, amount, "");
        
        // Update staking records
        stakedBalances[tokenId][msg.sender] += amount;
        stakingStartTime[tokenId][msg.sender] = block.timestamp;
        totalStaked[tokenId] += amount;
        
        emit TokensStaked(tokenId, msg.sender, amount);
    }
    
    /**
     * @dev Unstake tokens and claim rewards
     * @param tokenId ID of token to unstake
     * @param amount Amount to unstake
     */
    function unstakeTokens(
        uint256 tokenId,
        uint256 amount
    ) external whenNotPaused {
        require(amount > 0, "CustomERC1155: Amount must be greater than 0");
        require(
            stakedBalances[tokenId][msg.sender] >= amount,
            "CustomERC1155: Insufficient staked balance"
        );
        
        // Calculate rewards
        uint256 rewards = _calculateStakingRewards(tokenId, msg.sender, amount);
        
        // Update staking records
        stakedBalances[tokenId][msg.sender] -= amount;
        totalStaked[tokenId] -= amount;
        
        // Return staked tokens
        _safeTransferFrom(address(this), msg.sender, tokenId, amount, "");
        
        // Mint rewards in GOLD_COIN
        if (rewards > 0) {
            _mint(msg.sender, GOLD_COIN, rewards, "");
            playerStats[msg.sender].stakingRewards += rewards;
        }
        
        emit TokensUnstaked(tokenId, msg.sender, amount, rewards);
    }
    
    /**
     * @dev Create marketplace listing
     * @param tokenId ID of token to sell
     * @param amount Amount to sell
     * @param pricePerToken Price per token in GOLD_COIN
     */
    function createMarketplaceListing(
        uint256 tokenId,
        uint256 amount,
        uint256 pricePerToken
    ) external whenNotPaused tokenExists(tokenId) tradingIsEnabled(tokenId) {
        require(amount > 0, "CustomERC1155: Amount must be greater than 0");
        require(pricePerToken > 0, "CustomERC1155: Price must be greater than 0");
        require(
            balanceOf(msg.sender, tokenId) >= amount,
            "CustomERC1155: Insufficient balance"
        );
        
        uint256 listingId = nextListingId++;
        
        // Transfer tokens to contract
        _safeTransferFrom(msg.sender, address(this), tokenId, amount, "");
        
        // Create listing
        marketplaceListings[listingId] = MarketplaceListing({
            tokenId: tokenId,
            amount: amount,
            pricePerToken: pricePerToken,
            seller: msg.sender,
            active: true,
            listedAt: block.timestamp
        });
        
        emit MarketplaceListingCreated(listingId, tokenId, msg.sender, amount, pricePerToken);
    }
    
    /**
     * @dev Purchase from marketplace
     * @param listingId ID of the listing
     * @param amount Amount to purchase
     */
    function purchaseFromMarketplace(
        uint256 listingId,
        uint256 amount
    ) external whenNotPaused nonReentrant {
        MarketplaceListing storage listing = marketplaceListings[listingId];
        
        require(listing.active, "CustomERC1155: Listing not active");
        require(amount > 0, "CustomERC1155: Amount must be greater than 0");
        require(amount <= listing.amount, "CustomERC1155: Amount exceeds listing");
        require(listing.seller != msg.sender, "CustomERC1155: Cannot buy own listing");
        
        uint256 totalPrice = listing.pricePerToken * amount;
        uint256 fee = (totalPrice * marketplaceFee) / 10000;
        uint256 sellerAmount = totalPrice - fee;
        
        require(
            balanceOf(msg.sender, GOLD_COIN) >= totalPrice,
            "CustomERC1155: Insufficient GOLD_COIN balance"
        );
        
        // Transfer payment
        _safeTransferFrom(msg.sender, listing.seller, GOLD_COIN, sellerAmount, "");
        if (fee > 0) {
            _safeTransferFrom(msg.sender, feeRecipient, GOLD_COIN, fee, "");
        }
        
        // Transfer tokens
        _safeTransferFrom(address(this), msg.sender, listing.tokenId, amount, "");
        
        // Update listing
        listing.amount -= amount;
        if (listing.amount == 0) {
            listing.active = false;
        }
        
        // Update statistics
        playerStats[msg.sender].tradingVolume += totalPrice;
        playerStats[listing.seller].tradingVolume += totalPrice;
        
        emit MarketplacePurchase(listingId, listing.tokenId, msg.sender, listing.seller, amount, totalPrice);
    }

    // ========== VIEW FUNCTIONS ==========
    
    /**
     * @dev Get player statistics
     * @param player Address of the player
     * @return stats Player statistics
     */
    function getPlayerStats(address player) external view returns (PlayerStats memory stats) {
        stats = playerStats[player];
        
        // Calculate total tokens owned
        uint256 totalTokens = 0;
        uint256 totalValue = 0;
        
        for (uint256 i = 0; i < nextTokenId; i++) {
            uint256 balance = balanceOf(player, i);
            totalTokens += balance;
            if (tokenPrices[i] > 0) {
                totalValue += balance * tokenPrices[i];
            }
        }
        
        stats.totalTokensOwned = totalTokens;
        stats.totalValueInGold = totalValue;
        stats.seasonScore = seasonScores[currentSeason][player];
    }
    
    /**
     * @dev Get staking information for a player
     * @param player Address of the player
     * @param tokenId ID of the token
     * @return stakedAmount Amount staked
     * @return pendingRewards Pending staking rewards
     */
    function getStakingInfo(
        address player,
        uint256 tokenId
    ) external view returns (uint256 stakedAmount, uint256 pendingRewards) {
        stakedAmount = stakedBalances[tokenId][player];
        pendingRewards = _calculateStakingRewards(tokenId, player, stakedAmount);
    }
    
    /**
     * @dev Get marketplace listing information
     * @param listingId ID of the listing
     * @return listing Marketplace listing details
     */
    function getMarketplaceListing(uint256 listingId) external view returns (MarketplaceListing memory listing) {
        listing = marketplaceListings[listingId];
    }
    
    /**
     * @dev Get current season information
     * @return seasonNumber Current season number
     * @return startTime Season start time
     * @return endTime Season end time
     * @return timeRemaining Time remaining in current season
     */
    function getCurrentSeasonInfo() external view returns (
        uint256 seasonNumber,
        uint256 startTime,
        uint256 endTime,
        uint256 timeRemaining
    ) {
        seasonNumber = currentSeason;
        startTime = seasonStartTime;
        endTime = seasonStartTime + seasonDuration;
        timeRemaining = endTime > block.timestamp ? endTime - block.timestamp : 0;
    }

    // ========== ADMIN FUNCTIONS ==========
    
    /**
     * @dev Set token price
     * @param tokenId ID of the token
     * @param price Price in GOLD_COIN
     */
    function setTokenPrice(uint256 tokenId, uint256 price) external onlyRole(GAME_MASTER_ROLE) tokenExists(tokenId) {
        tokenPrices[tokenId] = price;
    }
    
    /**
     * @dev Set daily mint limit
     * @param tokenId ID of the token
     * @param limit Daily mint limit
     */
    function setDailyMintLimit(uint256 tokenId, uint256 limit) external onlyRole(GAME_MASTER_ROLE) tokenExists(tokenId) {
        dailyMintLimits[tokenId] = limit;
    }
    
    /**
     * @dev Toggle trading for a token
     * @param tokenId ID of the token
     * @param enabled Whether trading is enabled
     */
    function setTradingEnabled(uint256 tokenId, bool enabled) external onlyRole(GAME_MASTER_ROLE) tokenExists(tokenId) {
        tradingEnabled[tokenId] = enabled;
    }
    
    /**
     * @dev Start new season
     */
    function startNewSeason() external onlyRole(GAME_MASTER_ROLE) {
        _startNewSeason();
    }
    
    /**
     * @dev Emergency mint for game events
     * @param to Address to mint to
     * @param tokenId ID of token to mint
     * @param amount Amount to mint
     */
    function emergencyMint(
        address to,
        uint256 tokenId,
        uint256 amount
    ) external onlyRole(MINTER_ROLE) {
        _mint(to, tokenId, amount, "");
        tokenSupply[tokenId] += amount;
    }

    // ========== INTERNAL FUNCTIONS ==========
    
    /**
     * @dev Initialize game tokens
     */
    function _initializeGameTokens() internal {
        // Create currency tokens
        _createAndSetupToken(GOLD_COIN, "Gold Coin", TokenType.FUNGIBLE, 0, 0, true);
        _createAndSetupToken(SILVER_COIN, "Silver Coin", TokenType.FUNGIBLE, 0, 100, true);
        _createAndSetupToken(EXPERIENCE_POINTS, "Experience Points", TokenType.FUNGIBLE, 0, 0, false);
        
        // Create equipment tokens
        _createAndSetupToken(LEGENDARY_SWORD, "Legendary Sword", TokenType.NON_FUNGIBLE, 1, 1000, true);
        _createAndSetupToken(MAGIC_SHIELD, "Magic Shield", TokenType.SEMI_FUNGIBLE, 100, 500, true);
        _createAndSetupToken(EPIC_ARMOR, "Epic Armor", TokenType.SEMI_FUNGIBLE, 50, 2000, true);
        _createAndSetupToken(MYTHIC_ARTIFACT, "Mythic Artifact", TokenType.NON_FUNGIBLE, 1, 5000, true);
        
        // Create consumable tokens
        _createAndSetupToken(HEALTH_POTION, "Health Potion", TokenType.FUNGIBLE, 0, 10, true);
        _createAndSetupToken(MANA_POTION, "Mana Potion", TokenType.FUNGIBLE, 0, 15, true);
        _createAndSetupToken(RARE_GEM, "Rare Gem", TokenType.SEMI_FUNGIBLE, 1000, 50, true);
        
        // Initial mint of basic currencies
        _mint(msg.sender, GOLD_COIN, 1000000 * 10**18, ""); // 1M Gold
        _mint(msg.sender, SILVER_COIN, 10000000 * 10**18, ""); // 10M Silver
    }
    
    /**
     * @dev Create and setup a token with all parameters
     */
    function _createAndSetupToken(
        uint256 expectedId,
        string memory name,
        TokenType tokenType,
        uint256 maxSupply_,
        uint256 price,
        bool tradingEnabled_
    ) internal {
        // Ensure we're creating the expected token ID
        require(nextTokenId == expectedId, "CustomERC1155: Token ID mismatch");
        
        createTokenType(name, tokenType, maxSupply_);
        tokenPrices[expectedId] = price;
        tradingEnabled[expectedId] = tradingEnabled_;
        
        // Set daily limits for consumables
        if (expectedId == HEALTH_POTION || expectedId == MANA_POTION) {
            dailyMintLimits[expectedId] = 10; // 10 potions per day
        }
    }
    
    /**
     * @dev Calculate staking rewards
     */
    function _calculateStakingRewards(
        uint256 tokenId,
        address staker,
        uint256 amount
    ) internal view returns (uint256) {
        if (stakedBalances[tokenId][staker] == 0 || amount == 0) {
            return 0;
        }
        
        uint256 stakingTime = block.timestamp - stakingStartTime[tokenId][staker];
        uint256 rewardRate = _getRewardRate(tokenId);
        
        return (amount * rewardRate * stakingTime) / (365 days * 10000); // Annual percentage
    }
    
    /**
     * @dev Get reward rate for token type
     */
    function _getRewardRate(uint256 tokenId) internal pure returns (uint256) {
        // Return annual percentage in basis points
        if (tokenId == LEGENDARY_SWORD || tokenId == MYTHIC_ARTIFACT) {
            return 2000; // 20% APY for legendary items
        } else if (tokenId == EPIC_ARMOR || tokenId == MAGIC_SHIELD) {
            return 1500; // 15% APY for epic items
        } else if (tokenId == RARE_GEM) {
            return 1000; // 10% APY for rare gems
        }
        return 500; // 5% APY for other tokens
    }
    
    /**
     * @dev Update daily mint tracking
     */
    function _updateDailyMintTracking(uint256 tokenId, uint256 amount) internal {
        if (block.timestamp >= lastMintTime[tokenId][msg.sender] + 1 days) {
            dailyMintedAmount[tokenId][msg.sender] = 0;
        }
        dailyMintedAmount[tokenId][msg.sender] += amount;
        lastMintTime[tokenId][msg.sender] = block.timestamp;
    }
    
    /**
     * @dev Update player statistics
     */
    function _updatePlayerStats(
        address player,
        uint256 tokenId,
        uint256 amount,
        uint256 cost
    ) internal {
        // Add to season score based on token rarity
        uint256 scoreIncrease = amount;
        if (tokenTypes[tokenId] == TokenType.NON_FUNGIBLE) {
            scoreIncrease *= 100; // NFTs worth more points
        } else if (tokenTypes[tokenId] == TokenType.SEMI_FUNGIBLE) {
            scoreIncrease *= 10;
        }
        
        seasonScores[currentSeason][player] += scoreIncrease;
        playerStats[player].seasonScore = seasonScores[currentSeason][player];
    }
    
    /**
     * @dev Start new season
     */
    function _startNewSeason() internal {
        _seasonCounter.increment();
        currentSeason = _seasonCounter.current();
        seasonStartTime = block.timestamp;
        
        emit NewSeasonStarted(currentSeason, seasonStartTime);
    }

    // ========== EDUCATIONAL FUNCTIONS ==========
    
    /**
     * @dev Educational function to demonstrate multi-token economics
     * @return tokenEconomics Array showing token distribution
     */
    function demonstrateTokenEconomics() external view returns (uint256[10] memory tokenEconomics) {
        for (uint256 i = 0; i < 10; i++) {
            tokenEconomics[i] = tokenSupply[i];
        }
    }
    
    /**
     * @dev Educational function to show gas optimization benefits
     * @return batchSavings Estimated gas savings using batch operations
     */
    function calculateBatchSavings(uint256 numTransfers) external pure returns (uint256 batchSavings) {
        uint256 individualCost = numTransfers * 50000; // ~50k gas per transfer
        uint256 batchCost = 30000 + (numTransfers * 25000); // Base + per transfer
        batchSavings = individualCost > batchCost ? individualCost - batchCost : 0;
    }
    
    /**
     * @dev Educational function to demonstrate role-based access
     * @param role The role to check
     * @param account The account to check
     * @return hasRole Whether the account has the role
     */
    function demonstrateRoleAccess(bytes32 role, address account) external view returns (bool hasRole) {
        hasRole = hasRole(role, account);
    }

    // ========== OVERRIDE FUNCTIONS ==========
    
    /**
     * @dev Override supportsInterface to include AccessControl
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(GustavoCaracasMultiToken, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}