// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title ERC1155 Multi-Token Base Contract
 * @author Gustavo - Caracas, Venezuela
 * @notice Educational implementation of ERC1155 (Multi-Token) standard
 * @dev This contract serves as a base for creating multi-token collections
 * 
 * Educational Objectives:
 * - Understand ERC1155 multi-token standard
 * - Learn about fungible and non-fungible tokens in one contract
 * - Practice batch operations and gas optimization
 * - Explore metadata management for multiple token types
 * - Understand supply management and token economics
 */
contract GustavoCaracasMultiToken is ERC1155, Ownable, Pausable, ReentrancyGuard {
    using Strings for uint256;

    // ========== STATE VARIABLES ==========
    
    /// @dev Contract name
    string public name;
    
    /// @dev Contract symbol
    string public symbol;
    
    /// @dev Base URI for token metadata
    string private _baseURI;
    
    /// @dev Mapping from token ID to token supply
    mapping(uint256 => uint256) public tokenSupply;
    
    /// @dev Mapping from token ID to maximum supply
    mapping(uint256 => uint256) public maxSupply;
    
    /// @dev Mapping from token ID to token name
    mapping(uint256 => string) public tokenNames;
    
    /// @dev Mapping from token ID to token type (0=fungible, 1=semi-fungible, 2=non-fungible)
    mapping(uint256 => TokenType) public tokenTypes;
    
    /// @dev Mapping from token ID to creator address
    mapping(uint256 => address) public tokenCreators;
    
    /// @dev Mapping from token ID to creation timestamp
    mapping(uint256 => uint256) public tokenCreatedAt;
    
    /// @dev Mapping to track minted amounts per address per token
    mapping(uint256 => mapping(address => uint256)) public mintedPerAddress;
    
    /// @dev Array of all existing token IDs
    uint256[] public allTokenIds;
    
    /// @dev Next available token ID
    uint256 public nextTokenId;

    // ========== ENUMS ==========
    
    /**
     * @dev Enum for token types
     */
    enum TokenType {
        FUNGIBLE,      // 0 - Like ERC20 (currencies, resources)
        SEMI_FUNGIBLE, // 1 - Limited supply items
        NON_FUNGIBLE   // 2 - Unique items (like ERC721)
    }

    // ========== STRUCTS ==========
    
    /**
     * @dev Structure to store token information
     */
    struct TokenInfo {
        uint256 id;
        string name;
        TokenType tokenType;
        uint256 totalSupply;
        uint256 maxSupply;
        address creator;
        uint256 createdAt;
        string uri;
    }

    // ========== EVENTS ==========
    
    /**
     * @dev Emitted when a new token type is created
     */
    event TokenTypeCreated(
        uint256 indexed tokenId,
        string name,
        TokenType tokenType,
        uint256 maxSupply,
        address indexed creator
    );
    
    /**
     * @dev Emitted when tokens are minted
     */
    event TokensMinted(
        uint256 indexed tokenId,
        address indexed to,
        uint256 amount,
        address indexed minter
    );
    
    /**
     * @dev Emitted when tokens are burned
     */
    event TokensBurned(
        uint256 indexed tokenId,
        address indexed from,
        uint256 amount
    );
    
    /**
     * @dev Emitted when base URI is updated
     */
    event BaseURIUpdated(string newBaseURI);
    
    /**
     * @dev Emitted when token URI is updated
     */
    event TokenURIUpdated(uint256 indexed tokenId, string newURI);

    // ========== MODIFIERS ==========
    
    /**
     * @dev Modifier to check if token exists
     */
    modifier tokenExists(uint256 tokenId) {
        require(tokenId < nextTokenId, "ERC1155: Token does not exist");
        _;
    }
    
    /**
     * @dev Modifier to check supply limits
     */
    modifier withinSupplyLimit(uint256 tokenId, uint256 amount) {
        require(
            tokenSupply[tokenId] + amount <= maxSupply[tokenId],
            "ERC1155: Exceeds maximum supply"
        );
        _;
    }
    
    /**
     * @dev Modifier to check if caller is token creator or owner
     */
    modifier onlyCreatorOrOwner(uint256 tokenId) {
        require(
            tokenCreators[tokenId] == msg.sender || owner() == msg.sender,
            "ERC1155: Not creator or owner"
        );
        _;
    }

    // ========== CONSTRUCTOR ==========
    
    /**
     * @dev Constructor sets the collection name, symbol, and base URI
     * @param _name The name of the multi-token collection
     * @param _symbol The symbol of the multi-token collection
     * @param baseURI_ Base URI for token metadata
     */
    constructor(
        string memory _name,
        string memory _symbol,
        string memory baseURI_
    ) ERC1155(baseURI_) {
        require(bytes(_name).length > 0, "ERC1155: Name cannot be empty");
        require(bytes(_symbol).length > 0, "ERC1155: Symbol cannot be empty");
        require(bytes(baseURI_).length > 0, "ERC1155: Base URI cannot be empty");
        
        name = _name;
        symbol = _symbol;
        _baseURI = baseURI_;
        nextTokenId = 0;
    }

    // ========== PUBLIC FUNCTIONS ==========
    
    /**
     * @dev Creates a new token type
     * @param tokenName Name of the token
     * @param tokenType Type of the token (0=fungible, 1=semi-fungible, 2=non-fungible)
     * @param _maxSupply Maximum supply for this token (0 = unlimited for fungible)
     * @return tokenId The ID of the newly created token type
     */
    function createTokenType(
        string memory tokenName,
        TokenType tokenType,
        uint256 _maxSupply
    ) public onlyOwner returns (uint256) {
        require(bytes(tokenName).length > 0, "ERC1155: Token name cannot be empty");
        
        if (tokenType == TokenType.NON_FUNGIBLE) {
            require(_maxSupply == 1, "ERC1155: NFT max supply must be 1");
        } else if (tokenType == TokenType.FUNGIBLE) {
            require(_maxSupply == 0 || _maxSupply > 1000, "ERC1155: Fungible tokens need higher supply");
        }
        
        uint256 tokenId = nextTokenId;
        
        tokenNames[tokenId] = tokenName;
        tokenTypes[tokenId] = tokenType;
        maxSupply[tokenId] = _maxSupply;
        tokenCreators[tokenId] = msg.sender;
        tokenCreatedAt[tokenId] = block.timestamp;
        
        allTokenIds.push(tokenId);
        nextTokenId++;
        
        emit TokenTypeCreated(tokenId, tokenName, tokenType, _maxSupply, msg.sender);
        
        return tokenId;
    }
    
    /**
     * @dev Mints tokens to a specific address
     * @param to Address to mint tokens to
     * @param tokenId ID of the token to mint
     * @param amount Amount of tokens to mint
     * @param data Additional data
     */
    function mint(
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes memory data
    ) public onlyCreatorOrOwner(tokenId) whenNotPaused tokenExists(tokenId) withinSupplyLimit(tokenId, amount) {
        require(to != address(0), "ERC1155: Cannot mint to zero address");
        require(amount > 0, "ERC1155: Amount must be greater than 0");
        
        if (tokenTypes[tokenId] == TokenType.NON_FUNGIBLE) {
            require(amount == 1, "ERC1155: NFT amount must be 1");
            require(tokenSupply[tokenId] == 0, "ERC1155: NFT already minted");
        }
        
        _mint(to, tokenId, amount, data);
        
        tokenSupply[tokenId] += amount;
        mintedPerAddress[tokenId][to] += amount;
        
        emit TokensMinted(tokenId, to, amount, msg.sender);
    }
    
    /**
     * @dev Batch mints multiple tokens
     * @param to Address to mint tokens to
     * @param tokenIds Array of token IDs
     * @param amounts Array of amounts
     * @param data Additional data
     */
    function mintBatch(
        address to,
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyOwner whenNotPaused {
        require(to != address(0), "ERC1155: Cannot mint to zero address");
        require(tokenIds.length == amounts.length, "ERC1155: Arrays length mismatch");
        require(tokenIds.length > 0, "ERC1155: Empty arrays");
        require(tokenIds.length <= 10, "ERC1155: Too many tokens at once");
        
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(tokenIds[i] < nextTokenId, "ERC1155: Token does not exist");
            require(amounts[i] > 0, "ERC1155: Amount must be greater than 0");
            require(
                tokenSupply[tokenIds[i]] + amounts[i] <= maxSupply[tokenIds[i]] || maxSupply[tokenIds[i]] == 0,
                "ERC1155: Exceeds maximum supply"
            );
            
            tokenSupply[tokenIds[i]] += amounts[i];
            mintedPerAddress[tokenIds[i]][to] += amounts[i];
            
            emit TokensMinted(tokenIds[i], to, amounts[i], msg.sender);
        }
        
        _mintBatch(to, tokenIds, amounts, data);
    }
    
    /**
     * @dev Burns tokens from caller's balance
     * @param tokenId ID of the token to burn
     * @param amount Amount of tokens to burn
     */
    function burn(
        uint256 tokenId,
        uint256 amount
    ) public tokenExists(tokenId) {
        require(amount > 0, "ERC1155: Amount must be greater than 0");
        require(balanceOf(msg.sender, tokenId) >= amount, "ERC1155: Insufficient balance");
        
        _burn(msg.sender, tokenId, amount);
        
        tokenSupply[tokenId] -= amount;
        mintedPerAddress[tokenId][msg.sender] -= amount;
        
        emit TokensBurned(tokenId, msg.sender, amount);
    }
    
    /**
     * @dev Burns multiple tokens from caller's balance
     * @param tokenIds Array of token IDs
     * @param amounts Array of amounts
     */
    function burnBatch(
        uint256[] memory tokenIds,
        uint256[] memory amounts
    ) public {
        require(tokenIds.length == amounts.length, "ERC1155: Arrays length mismatch");
        require(tokenIds.length > 0, "ERC1155: Empty arrays");
        
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(tokenIds[i] < nextTokenId, "ERC1155: Token does not exist");
            require(amounts[i] > 0, "ERC1155: Amount must be greater than 0");
            require(balanceOf(msg.sender, tokenIds[i]) >= amounts[i], "ERC1155: Insufficient balance");
            
            tokenSupply[tokenIds[i]] -= amounts[i];
            mintedPerAddress[tokenIds[i]][msg.sender] -= amounts[i];
            
            emit TokensBurned(tokenIds[i], msg.sender, amounts[i]);
        }
        
        _burnBatch(msg.sender, tokenIds, amounts);
    }

    // ========== VIEW FUNCTIONS ==========
    
    /**
     * @dev Returns the URI for a specific token
     * @param tokenId The token ID
     * @return The complete URI for the token metadata
     */
    function uri(uint256 tokenId) public view override tokenExists(tokenId) returns (string memory) {
        return string(abi.encodePacked(_baseURI, tokenId.toString(), ".json"));
    }
    
    /**
     * @dev Returns information about a specific token
     * @param tokenId The token ID
     * @return info Token information struct
     */
    function getTokenInfo(uint256 tokenId) external view tokenExists(tokenId) returns (TokenInfo memory info) {
        info = TokenInfo({
            id: tokenId,
            name: tokenNames[tokenId],
            tokenType: tokenTypes[tokenId],
            totalSupply: tokenSupply[tokenId],
            maxSupply: maxSupply[tokenId],
            creator: tokenCreators[tokenId],
            createdAt: tokenCreatedAt[tokenId],
            uri: uri(tokenId)
        });
    }
    
    /**
     * @dev Returns all token IDs
     * @return Array of all token IDs
     */
    function getAllTokenIds() external view returns (uint256[] memory) {
        return allTokenIds;
    }
    
    /**
     * @dev Returns tokens owned by an address
     * @param owner The address to query
     * @return tokenIds Array of token IDs owned
     * @return balances Array of balances for each token
     */
    function tokensOfOwner(address owner) external view returns (uint256[] memory tokenIds, uint256[] memory balances) {
        uint256 tokenCount = 0;
        
        // Count tokens owned
        for (uint256 i = 0; i < allTokenIds.length; i++) {
            if (balanceOf(owner, allTokenIds[i]) > 0) {
                tokenCount++;
            }
        }
        
        tokenIds = new uint256[](tokenCount);
        balances = new uint256[](tokenCount);
        
        uint256 index = 0;
        for (uint256 i = 0; i < allTokenIds.length; i++) {
            uint256 balance = balanceOf(owner, allTokenIds[i]);
            if (balance > 0) {
                tokenIds[index] = allTokenIds[i];
                balances[index] = balance;
                index++;
            }
        }
    }
    
    /**
     * @dev Returns collection statistics
     * @return stats Array containing [totalTokenTypes, totalSupplyAllTokens]
     */
    function getCollectionStats() external view returns (uint256[2] memory stats) {
        stats[0] = nextTokenId; // Total token types
        
        uint256 totalSupplyAll = 0;
        for (uint256 i = 0; i < allTokenIds.length; i++) {
            totalSupplyAll += tokenSupply[allTokenIds[i]];
        }
        stats[1] = totalSupplyAll;
    }
    
    /**
     * @dev Check if a token type exists
     * @param tokenId The token ID to check
     * @return Whether the token type exists
     */
    function exists(uint256 tokenId) external view returns (bool) {
        return tokenId < nextTokenId;
    }

    // ========== OWNER FUNCTIONS ==========
    
    /**
     * @dev Updates the base URI for token metadata
     * @param newBaseURI The new base URI
     */
    function setBaseURI(string memory newBaseURI) external onlyOwner {
        require(bytes(newBaseURI).length > 0, "ERC1155: Base URI cannot be empty");
        _baseURI = newBaseURI;
        emit BaseURIUpdated(newBaseURI);
    }
    
    /**
     * @dev Updates the URI for the contract (for OpenSea)
     * @param newURI The new contract URI
     */
    function setURI(string memory newURI) external onlyOwner {
        _setURI(newURI);
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
     * @dev Emergency function to update max supply (only decrease allowed)
     * @param tokenId The token ID
     * @param newMaxSupply The new maximum supply
     */
    function updateMaxSupply(uint256 tokenId, uint256 newMaxSupply) external onlyOwner tokenExists(tokenId) {
        require(
            newMaxSupply >= tokenSupply[tokenId],
            "ERC1155: New max supply cannot be less than current supply"
        );
        require(
            newMaxSupply < maxSupply[tokenId] || maxSupply[tokenId] == 0,
            "ERC1155: Can only decrease max supply"
        );
        
        maxSupply[tokenId] = newMaxSupply;
    }

    // ========== INTERNAL FUNCTIONS ==========
    
    /**
     * @dev Hook that is called before any token transfer
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    // ========== EDUCATIONAL FUNCTIONS ==========
    
    /**
     * @dev Educational function to demonstrate ERC1155 interface
     * @return interfaceId The ERC1155 interface identifier
     */
    function getERC1155InterfaceId() external pure returns (bytes4) {
        return type(IERC1155).interfaceId;
    }
    
    /**
     * @dev Educational function to show supported interfaces
     * @param interfaceId The interface identifier to check
     * @return Whether the interface is supported
     */
    function checkInterface(bytes4 interfaceId) external view returns (bool) {
        return supportsInterface(interfaceId);
    }
    
    /**
     * @dev Educational function to demonstrate batch balance checking
     * @param accounts Array of account addresses
     * @param tokenIds Array of token IDs
     * @return Batch balances
     */
    function demonstrateBatchBalance(
        address[] memory accounts,
        uint256[] memory tokenIds
    ) external view returns (uint256[] memory) {
        return balanceOfBatch(accounts, tokenIds);
    }
    
    /**
     * @dev Educational function to show gas usage comparison
     * @return singleTransferGas Estimated gas for single transfer
     * @return batchTransferGas Estimated gas for batch transfer
     */
    function compareGasUsage() external pure returns (uint256 singleTransferGas, uint256 batchTransferGas) {
        // Approximate gas costs (educational purposes)
        singleTransferGas = 50000; // ~50k gas per single transfer
        batchTransferGas = 30000;  // ~30k gas per transfer in batch
    }
}