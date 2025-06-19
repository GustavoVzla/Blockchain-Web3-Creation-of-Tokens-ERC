// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./ERC20.sol";

/**
 * @title Gustavo Caracas Token (GCT)
 * @dev Educational ERC20 token implementation with minting capabilities
 * @notice A custom token representing Gustavo from Caracas, Venezuela
 *
 * Features:
 * - Public minting function for educational purposes
 * - Owner-controlled minting with access control
 * - Batch minting capabilities
 * - Educational helper functions
 * - Event logging for transparency
 *
 * @author Gustavo - Caracas, Venezuela
 */
contract GustavoCaracasToken is ERC20 {
    // ========== STATE VARIABLES ==========

    /// @dev Address of the contract owner (deployer)
    address public owner;

    /// @dev Mapping to track if an address has minted tokens
    mapping(address => bool) public hasMinted;

    /// @dev Total number of unique addresses that have minted tokens
    uint256 public totalMinters;

    // ========== CONSTANTS ==========

    /// @dev Standard minting amount per user (1000 tokens)
    uint256 public constant STANDARD_MINT_AMOUNT = 1000 * 10 ** 18; // 1000 tokens with 18 decimals

    /// @dev Maximum tokens that can be minted per address
    uint256 public constant MAX_MINT_PER_ADDRESS = 10000 * 10 ** 18; // 10,000 tokens

    /// @dev Owner's special minting amount
    uint256 public constant OWNER_MINT_AMOUNT = 100000 * 10 ** 18; // 100,000 tokens

    // ========== EVENTS ==========

    /**
     * @dev Emitted when tokens are minted to an address
     * @param to The address that received the minted tokens
     * @param amount The amount of tokens minted
     * @param isFirstTime Whether this is the first time this address has minted
     */
    event TokensMinted(address indexed to, uint256 amount, bool isFirstTime);

    /**
     * @dev Emitted when ownership is transferred
     * @param previousOwner The address of the previous owner
     * @param newOwner The address of the new owner
     */
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    // ========== MODIFIERS ==========

    /**
     * @dev Throws if called by any account other than the owner
     */
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "GustavoCaracasToken: caller is not the owner"
        );
        _;
    }

    /**
     * @dev Throws if the address has already minted tokens
     * @param account The address to check
     */
    modifier hasNotMinted(address account) {
        require(
            !hasMinted[account],
            "GustavoCaracasToken: address has already minted tokens"
        );
        _;
    }

    // ========== CONSTRUCTOR ==========

    /**
     * @dev Initializes the Gustavo Caracas Token
     * @notice Creates the GCT token and mints initial supply to deployer
     */
    constructor() ERC20("Gustavo Caracas Token", "GCT") {
        owner = msg.sender;

        // Mint initial supply to the owner (1 million tokens)
        _mint(owner, 1000000 * 10 ** 18);

        emit OwnershipTransferred(address(0), owner);
        emit TokensMinted(owner, 1000000 * 10 ** 18, true);
    }

    // ========== PUBLIC FUNCTIONS ==========

    /**
     * @dev Allows any address to mint standard amount of tokens (once per address)
     * @notice Mints 1000 GCT tokens to the caller (can only be called once per address)
     */
    function mintTokens() public hasNotMinted(msg.sender) {
        require(
            msg.sender != address(0),
            "GustavoCaracasToken: cannot mint to zero address"
        );

        // Mark address as having minted
        hasMinted[msg.sender] = true;
        totalMinters++;

        // Mint standard amount to caller
        _mint(msg.sender, STANDARD_MINT_AMOUNT);

        emit TokensMinted(msg.sender, STANDARD_MINT_AMOUNT, true);
    }

    /**
     * @dev Allows owner to mint tokens to any address
     * @param to The address to mint tokens to
     * @param amount The amount of tokens to mint
     * @notice Owner can mint any amount to any address
     */
    function ownerMint(address to, uint256 amount) public onlyOwner {
        require(
            to != address(0),
            "GustavoCaracasToken: cannot mint to zero address"
        );
        require(
            amount > 0,
            "GustavoCaracasToken: mint amount must be greater than zero"
        );
        require(
            amount <= OWNER_MINT_AMOUNT,
            "GustavoCaracasToken: amount exceeds owner mint limit"
        );

        bool isFirstTime = !hasMinted[to];
        if (isFirstTime) {
            hasMinted[to] = true;
            totalMinters++;
        }

        _mint(to, amount);

        emit TokensMinted(to, amount, isFirstTime);
    }

    /**
     * @dev Batch mint tokens to multiple addresses
     * @param recipients Array of addresses to mint tokens to
     * @param amounts Array of amounts to mint to each address
     * @notice Owner can mint different amounts to multiple addresses in one transaction
     */
    function batchMint(
        address[] calldata recipients,
        uint256[] calldata amounts
    ) public onlyOwner {
        require(
            recipients.length == amounts.length,
            "GustavoCaracasToken: arrays length mismatch"
        );
        require(recipients.length > 0, "GustavoCaracasToken: empty arrays");
        require(
            recipients.length <= 100,
            "GustavoCaracasToken: too many recipients"
        );

        for (uint256 i = 0; i < recipients.length; i++) {
            require(
                recipients[i] != address(0),
                "GustavoCaracasToken: cannot mint to zero address"
            );
            require(
                amounts[i] > 0,
                "GustavoCaracasToken: mint amount must be greater than zero"
            );
            require(
                amounts[i] <= MAX_MINT_PER_ADDRESS,
                "GustavoCaracasToken: amount exceeds max per address"
            );

            bool isFirstTime = !hasMinted[recipients[i]];
            if (isFirstTime) {
                hasMinted[recipients[i]] = true;
                totalMinters++;
            }

            _mint(recipients[i], amounts[i]);

            emit TokensMinted(recipients[i], amounts[i], isFirstTime);
        }
    }

    /**
     * @dev Transfers ownership of the contract to a new account
     * @param newOwner The address of the new owner
     * @notice Only current owner can transfer ownership
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "GustavoCaracasToken: new owner is the zero address"
        );
        require(
            newOwner != owner,
            "GustavoCaracasToken: new owner is the same as current owner"
        );

        address previousOwner = owner;
        owner = newOwner;

        emit OwnershipTransferred(previousOwner, newOwner);
    }

    // ========== VIEW FUNCTIONS ==========

    /**
     * @dev Returns detailed token information
     * @return tokenName The name of the token
     * @return tokenSymbol The symbol of the token
     * @return tokenDecimals The number of decimals
     * @return tokenTotalSupply The total supply of tokens
     * @return contractOwner The address of the contract owner
     * @notice Gets comprehensive information about the token
     */
    function getTokenInfo()
        public
        view
        returns (
            string memory tokenName,
            string memory tokenSymbol,
            uint8 tokenDecimals,
            uint256 tokenTotalSupply,
            address contractOwner
        )
    {
        return (name(), symbol(), decimals(), totalSupply(), owner);
    }

    /**
     * @dev Returns minting statistics
     * @return totalMinters_ The total number of unique addresses that have minted
     * @return standardMintAmount The standard amount minted per address
     * @return maxMintPerAddress The maximum amount that can be minted per address
     * @notice Gets statistics about token minting
     */
    function getMintingStats()
        public
        view
        returns (
            uint256 totalMinters_,
            uint256 standardMintAmount,
            uint256 maxMintPerAddress
        )
    {
        return (totalMinters, STANDARD_MINT_AMOUNT, MAX_MINT_PER_ADDRESS);
    }

    /**
     * @dev Checks if an address can mint tokens
     * @param account The address to check
     * @return eligible Whether the address can mint tokens
     * @return reason The reason if they cannot mint
     * @notice Utility function to check minting eligibility
     */
    function canMint(
        address account
    ) public view returns (bool eligible, string memory reason) {
        if (account == address(0)) {
            return (false, "Cannot mint to zero address");
        }
        if (hasMinted[account]) {
            return (false, "Address has already minted tokens");
        }
        return (true, "Address can mint tokens");
    }

    // ========== EDUCATIONAL FUNCTIONS ==========

    /**
     * @dev Demonstrates different ways to calculate token amounts
     * @param humanAmount The amount in human-readable format (e.g., 100 for 100 tokens)
     * @return weiAmount The amount in wei (smallest unit)
     * @return formattedAmount The formatted string representation
     * @notice Educational function showing token amount calculations
     */
    function calculateTokenAmount(
        uint256 humanAmount
    ) public pure returns (uint256 weiAmount, string memory formattedAmount) {
        weiAmount = humanAmount * 10 ** 18;
        formattedAmount = string(
            abi.encodePacked(
                "Human: ",
                _toString(humanAmount),
                " tokens = Wei: ",
                _toString(weiAmount),
                " units"
            )
        );
    }

    /**
     * @dev Demonstrates gas-efficient balance checking
     * @param accounts Array of addresses to check
     * @return balances Array of balances corresponding to the addresses
     * @notice Educational function showing batch operations
     */
    function batchBalanceOf(
        address[] calldata accounts
    ) public view returns (uint256[] memory balances) {
        require(
            accounts.length > 0,
            "GustavoCaracasToken: empty accounts array"
        );
        require(
            accounts.length <= 50,
            "GustavoCaracasToken: too many accounts"
        );

        balances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; i++) {
            balances[i] = balanceOf(accounts[i]);
        }
    }

    // ========== INTERNAL HELPER FUNCTIONS ==========

    /**
     * @dev Converts a uint256 to its ASCII string decimal representation
     * @param value The number to convert
     * @return The string representation of the number
     */
    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    // ========== OVERRIDE HOOKS ==========

    /**
     * @dev Hook that is called before any transfer of tokens
     * @param from The address tokens are transferred from
     * @param to The address tokens are transferred to
     * @param amount The amount of tokens being transferred
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        // Educational: Log large transfers
        if (amount >= 10000 * 10 ** 18) {
            // 10,000 tokens or more
            // This could trigger additional logic for large transfers
            // For example: additional validation, fees, or notifications
        }
    }
}
