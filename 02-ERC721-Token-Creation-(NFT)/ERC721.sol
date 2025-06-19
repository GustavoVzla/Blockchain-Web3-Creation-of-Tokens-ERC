// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title ERC721 Base Contract
 * @author Gustavo - Caracas, Venezuela
 * @notice Educational implementation of ERC721 (NFT) standard
 * @dev This contract serves as a base for creating NFT collections
 * 
 * Educational Objectives:
 * - Understand ERC721 standard implementation
 * - Learn about NFT minting, burning, and transfers
 * - Practice access control and security patterns
 * - Explore metadata and tokenURI concepts
 */
contract GustavoCaracasNFT is ERC721, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;

    // ========== STATE VARIABLES ==========
    
    /// @dev Counter for token IDs
    Counters.Counter private _tokenIdCounter;
    
    /// @dev Base URI for token metadata
    string private _baseTokenURI;
    
    /// @dev Maximum supply of tokens
    uint256 public maxSupply;
    
    /// @dev Current total supply
    uint256 public totalSupply;
    
    /// @dev Mapping from token ID to custom metadata
    mapping(uint256 => TokenMetadata) public tokenMetadata;
    
    /// @dev Mapping to track minted tokens per address
    mapping(address => uint256) public mintedCount;

    // ========== STRUCTS ==========
    
    /**
     * @dev Structure to store custom token metadata
     */
    struct TokenMetadata {
        string name;
        uint256 dna;
        uint8 level;
        uint8 rarity;
        uint256 createdAt;
        address creator;
    }

    // ========== EVENTS ==========
    
    /**
     * @dev Emitted when a new NFT is minted
     */
    event NFTMinted(
        address indexed to,
        uint256 indexed tokenId,
        string name,
        uint256 dna,
        uint8 rarity
    );
    
    /**
     * @dev Emitted when token metadata is updated
     */
    event MetadataUpdated(uint256 indexed tokenId, uint8 newLevel);
    
    /**
     * @dev Emitted when base URI is updated
     */
    event BaseURIUpdated(string newBaseURI);

    // ========== MODIFIERS ==========
    
    /**
     * @dev Modifier to check if token exists
     */
    modifier tokenExists(uint256 tokenId) {
        require(_exists(tokenId), "ERC721: Token does not exist");
        _;
    }
    
    /**
     * @dev Modifier to check supply limits
     */
    modifier withinSupplyLimit(uint256 amount) {
        require(
            totalSupply + amount <= maxSupply,
            "ERC721: Exceeds maximum supply"
        );
        _;
    }

    // ========== CONSTRUCTOR ==========
    
    /**
     * @dev Constructor sets the NFT collection name, symbol, and max supply
     * @param name The name of the NFT collection
     * @param symbol The symbol of the NFT collection
     * @param _maxSupply Maximum number of tokens that can be minted
     * @param baseURI Base URI for token metadata
     */
    constructor(
        string memory name,
        string memory symbol,
        uint256 _maxSupply,
        string memory baseURI
    ) ERC721(name, symbol) {
        require(_maxSupply > 0, "ERC721: Max supply must be greater than 0");
        require(bytes(baseURI).length > 0, "ERC721: Base URI cannot be empty");
        
        maxSupply = _maxSupply;
        _baseTokenURI = baseURI;
        
        // Start token IDs at 1
        _tokenIdCounter.increment();
    }

    // ========== PUBLIC FUNCTIONS ==========
    
    /**
     * @dev Mints a new NFT to the specified address
     * @param to Address to mint the NFT to
     * @param name Name of the NFT
     * @return tokenId The ID of the newly minted token
     */
    function mintNFT(
        address to,
        string memory name
    ) public onlyOwner withinSupplyLimit(1) returns (uint256) {
        require(to != address(0), "ERC721: Cannot mint to zero address");
        require(bytes(name).length > 0, "ERC721: Name cannot be empty");
        
        uint256 tokenId = _tokenIdCounter.current();
        
        // Generate random properties
        uint256 dna = _generateRandomDNA(tokenId);
        uint8 rarity = _generateRarity(dna);
        
        // Create metadata
        tokenMetadata[tokenId] = TokenMetadata({
            name: name,
            dna: dna,
            level: 1,
            rarity: rarity,
            createdAt: block.timestamp,
            creator: msg.sender
        });
        
        // Mint the token
        _safeMint(to, tokenId);
        
        // Update counters
        _tokenIdCounter.increment();
        totalSupply++;
        mintedCount[to]++;
        
        emit NFTMinted(to, tokenId, name, dna, rarity);
        
        return tokenId;
    }
    
    /**
     * @dev Batch mint multiple NFTs
     * @param to Address to mint NFTs to
     * @param names Array of names for the NFTs
     * @return tokenIds Array of minted token IDs
     */
    function batchMint(
        address to,
        string[] memory names
    ) external onlyOwner withinSupplyLimit(names.length) returns (uint256[] memory) {
        require(names.length > 0, "ERC721: Names array cannot be empty");
        require(names.length <= 10, "ERC721: Cannot mint more than 10 at once");
        
        uint256[] memory tokenIds = new uint256[](names.length);
        
        for (uint256 i = 0; i < names.length; i++) {
            tokenIds[i] = mintNFT(to, names[i]);
        }
        
        return tokenIds;
    }
    
    /**
     * @dev Burns a token (only owner of token can burn)
     * @param tokenId The ID of the token to burn
     */
    function burn(uint256 tokenId) external tokenExists(tokenId) {
        require(
            ownerOf(tokenId) == msg.sender || getApproved(tokenId) == msg.sender,
            "ERC721: Not owner or approved"
        );
        
        address owner = ownerOf(tokenId);
        
        // Delete metadata
        delete tokenMetadata[tokenId];
        
        // Burn the token
        _burn(tokenId);
        
        // Update counters
        totalSupply--;
        mintedCount[owner]--;
    }
    
    /**
     * @dev Levels up a token (only token owner)
     * @param tokenId The ID of the token to level up
     */
    function levelUp(uint256 tokenId) external tokenExists(tokenId) {
        require(ownerOf(tokenId) == msg.sender, "ERC721: Not token owner");
        require(
            tokenMetadata[tokenId].level < 100,
            "ERC721: Maximum level reached"
        );
        
        tokenMetadata[tokenId].level++;
        
        emit MetadataUpdated(tokenId, tokenMetadata[tokenId].level);
    }

    // ========== VIEW FUNCTIONS ==========
    
    /**
     * @dev Returns the token URI for a given token ID
     * @param tokenId The ID of the token
     * @return The complete URI for the token metadata
     */
    function tokenURI(uint256 tokenId)
        public
        view
        override
        tokenExists(tokenId)
        returns (string memory)
    {
        return string(abi.encodePacked(_baseTokenURI, Strings.toString(tokenId), ".json"));
    }
    
    /**
     * @dev Returns all tokens owned by an address
     * @param owner The address to query
     * @return tokenIds Array of token IDs owned by the address
     */
    function tokensOfOwner(address owner)
        external
        view
        returns (uint256[] memory)
    {
        uint256 tokenCount = balanceOf(owner);
        uint256[] memory tokenIds = new uint256[](tokenCount);
        uint256 index = 0;
        
        for (uint256 i = 1; i < _tokenIdCounter.current(); i++) {
            if (_exists(i) && ownerOf(i) == owner) {
                tokenIds[index] = i;
                index++;
            }
        }
        
        return tokenIds;
    }
    
    /**
     * @dev Returns metadata for a specific token
     * @param tokenId The ID of the token
     * @return metadata The token's metadata
     */
    function getTokenMetadata(uint256 tokenId)
        external
        view
        tokenExists(tokenId)
        returns (TokenMetadata memory)
    {
        return tokenMetadata[tokenId];
    }
    
    /**
     * @dev Returns collection statistics
     * @return stats Array containing [totalSupply, maxSupply, remainingSupply]
     */
    function getCollectionStats()
        external
        view
        returns (uint256[3] memory stats)
    {
        stats[0] = totalSupply;
        stats[1] = maxSupply;
        stats[2] = maxSupply - totalSupply;
    }

    // ========== OWNER FUNCTIONS ==========
    
    /**
     * @dev Updates the base URI for token metadata
     * @param newBaseURI The new base URI
     */
    function setBaseURI(string memory newBaseURI) external onlyOwner {
        require(bytes(newBaseURI).length > 0, "ERC721: Base URI cannot be empty");
        _baseTokenURI = newBaseURI;
        emit BaseURIUpdated(newBaseURI);
    }
    
    /**
     * @dev Emergency function to update max supply (only decrease allowed)
     * @param newMaxSupply The new maximum supply
     */
    function updateMaxSupply(uint256 newMaxSupply) external onlyOwner {
        require(
            newMaxSupply >= totalSupply,
            "ERC721: New max supply cannot be less than current supply"
        );
        require(
            newMaxSupply < maxSupply,
            "ERC721: Can only decrease max supply"
        );
        
        maxSupply = newMaxSupply;
    }

    // ========== INTERNAL FUNCTIONS ==========
    
    /**
     * @dev Generates random DNA for a token
     * @param tokenId The token ID to generate DNA for
     * @return Random DNA value
     */
    function _generateRandomDNA(uint256 tokenId) internal view returns (uint256) {
        return uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.difficulty,
                    msg.sender,
                    tokenId
                )
            )
        ) % (10**16);
    }
    
    /**
     * @dev Generates rarity based on DNA
     * @param dna The DNA value
     * @return Rarity value (1-100)
     */
    function _generateRarity(uint256 dna) internal pure returns (uint8) {
        uint256 rarityRoll = dna % 1000;
        
        if (rarityRoll < 10) return 100; // Legendary (1%)
        if (rarityRoll < 50) return 90;  // Epic (4%)
        if (rarityRoll < 150) return 80; // Rare (10%)
        if (rarityRoll < 350) return 70; // Uncommon (20%)
        return 60; // Common (65%)
    }
    
    /**
     * @dev Returns the base URI for tokens
     * @return The base URI string
     */
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    // ========== EDUCATIONAL FUNCTIONS ==========
    
    /**
     * @dev Educational function to demonstrate ERC721 interface
     * @return interfaceId The ERC721 interface identifier
     */
    function getERC721InterfaceId() external pure returns (bytes4) {
        return type(IERC721).interfaceId;
    }
    
    /**
     * @dev Educational function to show supported interfaces
     * @param interfaceId The interface identifier to check
     * @return Whether the interface is supported
     */
    function checkInterface(bytes4 interfaceId) external view returns (bool) {
        return supportsInterface(interfaceId);
    }
}