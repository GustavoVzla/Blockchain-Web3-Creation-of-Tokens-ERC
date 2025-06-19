// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title Custom ERC721 Implementation
 * @author Gustavo - Caracas, Venezuela
 * @notice Advanced NFT contract with payment system and enhanced features
 * @dev Extends the base ERC721 contract with additional functionality
 * 
 * Educational Objectives:
 * - Implement payment systems for NFT minting
 * - Learn about contract economics and fee management
 * - Practice advanced access control patterns
 * - Understand pausable functionality
 * - Explore batch operations and gas optimization
 */
contract GustavoCaracasArtNFT is GustavoCaracasNFT, Pausable {
    using Strings for uint256;

    // ========== STATE VARIABLES ==========
    
    /// @dev Price to mint an NFT
    uint256 public mintPrice;
    
    /// @dev Maximum NFTs per address
    uint256 public maxPerAddress;
    
    /// @dev Public sale active flag
    bool public publicSaleActive;
    
    /// @dev Whitelist active flag
    bool public whitelistActive;
    
    /// @dev Mapping for whitelist addresses
    mapping(address => bool) public whitelist;
    
    /// @dev Mapping for free mint eligibility
    mapping(address => bool) public freeMintEligible;
    
    /// @dev Total revenue collected
    uint256 public totalRevenue;
    
    /// @dev Revenue sharing percentages (basis points)
    uint256 public constant CREATOR_SHARE = 8000; // 80%
    uint256 public constant PLATFORM_SHARE = 2000; // 20%
    
    /// @dev Platform fee recipient
    address public platformFeeRecipient;

    // ========== EVENTS ==========
    
    /**
     * @dev Emitted when mint price is updated
     */
    event MintPriceUpdated(uint256 oldPrice, uint256 newPrice);
    
    /**
     * @dev Emitted when public sale status changes
     */
    event PublicSaleStatusChanged(bool active);
    
    /**
     * @dev Emitted when whitelist status changes
     */
    event WhitelistStatusChanged(bool active);
    
    /**
     * @dev Emitted when address is added to whitelist
     */
    event AddedToWhitelist(address indexed account);
    
    /**
     * @dev Emitted when revenue is withdrawn
     */
    event RevenueWithdrawn(address indexed recipient, uint256 amount);
    
    /**
     * @dev Emitted when NFT is purchased
     */
    event NFTPurchased(
        address indexed buyer,
        uint256 indexed tokenId,
        uint256 price,
        string name
    );

    // ========== MODIFIERS ==========
    
    /**
     * @dev Modifier to check if public sale is active
     */
    modifier publicSaleIsActive() {
        require(publicSaleActive, "CustomERC721: Public sale not active");
        _;
    }
    
    /**
     * @dev Modifier to check whitelist eligibility
     */
    modifier onlyWhitelisted() {
        if (whitelistActive) {
            require(
                whitelist[msg.sender],
                "CustomERC721: Not whitelisted"
            );
        }
        _;
    }
    
    /**
     * @dev Modifier to check minting limits
     */
    modifier withinMintLimit(uint256 amount) {
        require(
            mintedCount[msg.sender] + amount <= maxPerAddress,
            "CustomERC721: Exceeds max per address"
        );
        _;
    }

    // ========== CONSTRUCTOR ==========
    
    /**
     * @dev Constructor for the custom NFT contract
     * @param name Name of the NFT collection
     * @param symbol Symbol of the NFT collection
     * @param _maxSupply Maximum supply of NFTs
     * @param baseURI Base URI for metadata
     * @param _mintPrice Price to mint an NFT
     * @param _maxPerAddress Maximum NFTs per address
     * @param _platformFeeRecipient Address to receive platform fees
     */
    constructor(
        string memory name,
        string memory symbol,
        uint256 _maxSupply,
        string memory baseURI,
        uint256 _mintPrice,
        uint256 _maxPerAddress,
        address _platformFeeRecipient
    ) GustavoCaracasNFT(name, symbol, _maxSupply, baseURI) {
        require(_mintPrice > 0, "CustomERC721: Mint price must be greater than 0");
        require(_maxPerAddress > 0, "CustomERC721: Max per address must be greater than 0");
        require(
            _platformFeeRecipient != address(0),
            "CustomERC721: Platform fee recipient cannot be zero address"
        );
        
        mintPrice = _mintPrice;
        maxPerAddress = _maxPerAddress;
        platformFeeRecipient = _platformFeeRecipient;
        
        // Initially, sales are not active
        publicSaleActive = false;
        whitelistActive = true;
    }

    // ========== PUBLIC FUNCTIONS ==========
    
    /**
     * @dev Public mint function with payment
     * @param name Name for the NFT
     * @return tokenId The ID of the minted token
     */
    function publicMint(string memory name)
        external
        payable
        whenNotPaused
        publicSaleIsActive
        onlyWhitelisted
        withinMintLimit(1)
        returns (uint256)
    {
        require(msg.value >= mintPrice, "CustomERC721: Insufficient payment");
        
        uint256 tokenId = mintNFT(msg.sender, name);
        totalRevenue += msg.value;
        
        emit NFTPurchased(msg.sender, tokenId, msg.value, name);
        
        // Refund excess payment
        if (msg.value > mintPrice) {
            payable(msg.sender).transfer(msg.value - mintPrice);
        }
        
        return tokenId;
    }
    
    /**
     * @dev Free mint for eligible addresses
     * @param name Name for the NFT
     * @return tokenId The ID of the minted token
     */
    function freeMint(string memory name)
        external
        whenNotPaused
        withinMintLimit(1)
        returns (uint256)
    {
        require(
            freeMintEligible[msg.sender],
            "CustomERC721: Not eligible for free mint"
        );
        
        // Remove free mint eligibility after use
        freeMintEligible[msg.sender] = false;
        
        uint256 tokenId = mintNFT(msg.sender, name);
        
        emit NFTPurchased(msg.sender, tokenId, 0, name);
        
        return tokenId;
    }
    
    /**
     * @dev Batch mint with payment
     * @param names Array of names for NFTs
     * @return tokenIds Array of minted token IDs
     */
    function batchPublicMint(string[] memory names)
        external
        payable
        whenNotPaused
        publicSaleIsActive
        onlyWhitelisted
        withinMintLimit(names.length)
        returns (uint256[] memory)
    {
        uint256 totalCost = mintPrice * names.length;
        require(msg.value >= totalCost, "CustomERC721: Insufficient payment");
        
        uint256[] memory tokenIds = batchMint(msg.sender, names);
        totalRevenue += totalCost;
        
        // Emit events for each purchase
        for (uint256 i = 0; i < tokenIds.length; i++) {
            emit NFTPurchased(msg.sender, tokenIds[i], mintPrice, names[i]);
        }
        
        // Refund excess payment
        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost);
        }
        
        return tokenIds;
    }

    // ========== VIEW FUNCTIONS ==========
    
    /**
     * @dev Check if an address can mint
     * @param account Address to check
     * @return canMint Whether the address can mint
     * @return reason Reason if they cannot mint
     */
    function canAddressMint(address account)
        external
        view
        returns (bool canMint, string memory reason)
    {
        if (paused()) {
            return (false, "Contract is paused");
        }
        
        if (!publicSaleActive && !freeMintEligible[account]) {
            return (false, "Public sale not active and not eligible for free mint");
        }
        
        if (whitelistActive && !whitelist[account]) {
            return (false, "Address not whitelisted");
        }
        
        if (mintedCount[account] >= maxPerAddress) {
            return (false, "Address has reached minting limit");
        }
        
        if (totalSupply >= maxSupply) {
            return (false, "Maximum supply reached");
        }
        
        return (true, "Address can mint");
    }
    
    /**
     * @dev Get contract information
     * @return info Array containing contract stats
     */
    function getContractInfo()
        external
        view
        returns (
            uint256[5] memory info,
            bool[3] memory flags
        )
    {
        info[0] = totalSupply;
        info[1] = maxSupply;
        info[2] = mintPrice;
        info[3] = maxPerAddress;
        info[4] = totalRevenue;
        
        flags[0] = publicSaleActive;
        flags[1] = whitelistActive;
        flags[2] = paused();
    }

    // ========== OWNER FUNCTIONS ==========
    
    /**
     * @dev Update mint price
     * @param newPrice New mint price
     */
    function setMintPrice(uint256 newPrice) external onlyOwner {
        require(newPrice > 0, "CustomERC721: Price must be greater than 0");
        
        uint256 oldPrice = mintPrice;
        mintPrice = newPrice;
        
        emit MintPriceUpdated(oldPrice, newPrice);
    }
    
    /**
     * @dev Toggle public sale status
     */
    function togglePublicSale() external onlyOwner {
        publicSaleActive = !publicSaleActive;
        emit PublicSaleStatusChanged(publicSaleActive);
    }
    
    /**
     * @dev Toggle whitelist status
     */
    function toggleWhitelist() external onlyOwner {
        whitelistActive = !whitelistActive;
        emit WhitelistStatusChanged(whitelistActive);
    }
    
    /**
     * @dev Add addresses to whitelist
     * @param addresses Array of addresses to whitelist
     */
    function addToWhitelist(address[] memory addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            require(
                addresses[i] != address(0),
                "CustomERC721: Cannot whitelist zero address"
            );
            whitelist[addresses[i]] = true;
            emit AddedToWhitelist(addresses[i]);
        }
    }
    
    /**
     * @dev Set free mint eligibility
     * @param addresses Array of addresses
     * @param eligible Whether they are eligible
     */
    function setFreeMintEligibility(
        address[] memory addresses,
        bool eligible
    ) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            freeMintEligible[addresses[i]] = eligible;
        }
    }
    
    /**
     * @dev Pause the contract
     */
    function pause() external onlyOwner {
        _pause();
    }
    
    /**
     * @dev Unpause the contract
     */
    function unpause() external onlyOwner {
        _unpause();
    }
    
    /**
     * @dev Withdraw contract revenue
     */
    function withdrawRevenue() external onlyOwner nonReentrant {
        require(totalRevenue > 0, "CustomERC721: No revenue to withdraw");
        
        uint256 balance = address(this).balance;
        require(balance > 0, "CustomERC721: No balance to withdraw");
        
        // Calculate shares
        uint256 platformFee = (balance * PLATFORM_SHARE) / 10000;
        uint256 creatorShare = balance - platformFee;
        
        // Transfer platform fee
        if (platformFee > 0) {
            payable(platformFeeRecipient).transfer(platformFee);
            emit RevenueWithdrawn(platformFeeRecipient, platformFee);
        }
        
        // Transfer creator share
        if (creatorShare > 0) {
            payable(owner()).transfer(creatorShare);
            emit RevenueWithdrawn(owner(), creatorShare);
        }
    }
    
    /**
     * @dev Emergency withdraw (only owner)
     */
    function emergencyWithdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "CustomERC721: No balance to withdraw");
        
        payable(owner()).transfer(balance);
        emit RevenueWithdrawn(owner(), balance);
    }

    // ========== EDUCATIONAL FUNCTIONS ==========
    
    /**
     * @dev Educational function to show gas costs
     * @return gasUsed Gas used for this call
     */
    function getGasUsage() external view returns (uint256 gasUsed) {
        uint256 gasStart = gasleft();
        
        // Simulate some operations
        uint256 dummy = 0;
        for (uint256 i = 0; i < 10; i++) {
            dummy += i;
        }
        
        gasUsed = gasStart - gasleft();
    }
    
    /**
     * @dev Educational function to demonstrate events
     */
    function demonstrateEvents() external {
        emit NFTPurchased(msg.sender, 0, 0, "Demo NFT");
    }
    
    /**
     * @dev Get contract balance in ETH
     * @return balance Contract balance in wei
     * @return balanceInEth Contract balance in ETH
     */
    function getContractBalance()
        external
        view
        returns (uint256 balance, uint256 balanceInEth)
    {
        balance = address(this).balance;
        balanceInEth = balance / 1 ether;
    }

    // ========== RECEIVE FUNCTION ==========
    
    /**
     * @dev Receive function to accept ETH payments
     */
    receive() external payable {
        totalRevenue += msg.value;
    }
}