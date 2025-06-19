// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title ERC20 Token Standard Implementation
 * @dev Implementation of the ERC20 Token Standard as defined in EIP-20
 * @notice This contract provides a complete implementation of the ERC20 standard
 * Educational contract for learning token development fundamentals
 * 
 * Features:
 * - Complete ERC20 standard compliance
 * - Safe arithmetic operations (Solidity ^0.8.28 built-in overflow protection)
 * - Comprehensive input validation
 * - Educational helper functions
 * - Gas-efficient patterns
 * 
 * @author Gustavo - Caracas, Venezuela
 */

// ========== INTERFACES ==========

/**
 * @title IERC20 Interface
 * @dev Interface of the ERC20 standard as defined in the EIP
 * @notice Standard interface for ERC20 tokens
 */
interface IERC20 {
    /**
     * @dev Returns the total amount of tokens in existence
     * @return The total supply of tokens
     * @notice Gets the total number of tokens that exist
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by account
     * @param account The address to query the balance of
     * @return The number of tokens owned by the account
     * @notice Gets the token balance of a specific address
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves amount tokens from the caller's account to to
     * @param to The address to transfer tokens to
     * @param amount The amount of tokens to transfer
     * @return A boolean value indicating whether the operation succeeded
     * @notice Transfers tokens to another address
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that spender will be allowed to spend
     * @param owner The address that owns the tokens
     * @param spender The address that will spend the tokens
     * @return The number of tokens that spender is allowed to spend
     * @notice Gets the amount of tokens that an address is allowed to spend on behalf of another
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets amount as the allowance of spender over the caller's tokens
     * @param spender The address that will be allowed to spend tokens
     * @param amount The amount of tokens to allow
     * @return A boolean value indicating whether the operation succeeded
     * @notice Approves another address to spend tokens on your behalf
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves amount tokens from from to to using the allowance mechanism
     * @param from The address to transfer tokens from
     * @param to The address to transfer tokens to
     * @param amount The amount of tokens to transfer
     * @return A boolean value indicating whether the operation succeeded
     * @notice Transfers tokens from one address to another using allowance
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when value tokens are moved from one account to another
     * @param from The address tokens are transferred from
     * @param to The address tokens are transferred to
     * @param value The amount of tokens transferred
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a spender for an owner is set
     * @param owner The address that owns the tokens
     * @param spender The address that is approved to spend tokens
     * @param value The amount of tokens approved
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// ========== MAIN CONTRACT ==========

/**
 * @title ERC20 Token Implementation
 * @dev Implementation of the {IERC20} interface with additional educational features
 * @notice A complete ERC20 token implementation for educational purposes
 */
contract ERC20 is IERC20 {
    
    // ========== STATE VARIABLES ==========
    
    /// @dev Mapping from account addresses to their token balances
    mapping(address => uint256) private _balances;
    
    /// @dev Mapping from owner to spender addresses with their allowances
    mapping(address => mapping(address => uint256)) private _allowances;
    
    /// @dev Total supply of tokens in circulation
    uint256 private _totalSupply;
    
    /// @dev Name of the token
    string private _name;
    
    /// @dev Symbol of the token
    string private _symbol;
    
    // ========== CONSTANTS ==========
    
    /// @dev Number of decimals for token precision (standard is 18)
    uint8 public constant DECIMALS = 18;
    
    /// @dev Maximum possible token supply to prevent overflow
    uint256 public constant MAX_SUPPLY = type(uint256).max / 10**DECIMALS;
    
    // ========== CONSTRUCTOR ==========
    
    /**
     * @dev Sets the values for {name} and {symbol}
     * @param name_ The name of the token
     * @param symbol_ The symbol of the token
     * @notice Creates a new ERC20 token with specified name and symbol
     */
    constructor(string memory name_, string memory symbol_) {
        require(bytes(name_).length > 0, "ERC20: name cannot be empty");
        require(bytes(symbol_).length > 0, "ERC20: symbol cannot be empty");
        
        _name = name_;
        _symbol = symbol_;
    }
    
    // ========== VIEW FUNCTIONS ==========
    
    /**
     * @dev Returns the name of the token
     * @return The token name
     * @notice Gets the full name of the token
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }
    
    /**
     * @dev Returns the symbol of the token
     * @return The token symbol
     * @notice Gets the symbol (ticker) of the token
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
    
    /**
     * @dev Returns the number of decimals used for token amounts
     * @return The number of decimals (always 18)
     * @notice Gets the decimal precision of the token
     */
    function decimals() public pure virtual returns (uint8) {
        return DECIMALS;
    }
    
    /**
     * @dev See {IERC20-totalSupply}
     * @return The total supply of tokens
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    
    /**
     * @dev See {IERC20-balanceOf}
     * @param account The address to query
     * @return The token balance of the account
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    
    /**
     * @dev See {IERC20-allowance}
     * @param owner The address that owns the tokens
     * @param spender The address that can spend the tokens
     * @return The remaining allowance
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    // ========== EDUCATIONAL HELPER FUNCTIONS ==========
    
    /**
     * @dev Converts token amount to wei (smallest unit)
     * @param tokenAmount The amount in token units
     * @return The amount in wei units
     * @notice Helper function to convert human-readable amounts to wei
     */
    function toWei(uint256 tokenAmount) public pure returns (uint256) {
        require(tokenAmount <= MAX_SUPPLY, "ERC20: amount exceeds maximum supply");
        return tokenAmount * 10**DECIMALS;
    }
    
    /**
     * @dev Converts wei amount to token units
     * @param weiAmount The amount in wei units
     * @return The amount in token units
     * @notice Helper function to convert wei amounts to human-readable format
     */
    function fromWei(uint256 weiAmount) public pure returns (uint256) {
        return weiAmount / 10**DECIMALS;
    }
    
    /**
     * @dev Checks if an address has sufficient balance
     * @param account The address to check
     * @param amount The amount to verify
     * @return True if the account has sufficient balance
     * @notice Utility function to check if an address can afford a transaction
     */
    function hasSufficientBalance(address account, uint256 amount) public view returns (bool) {
        return _balances[account] >= amount;
    }
    
    // ========== PUBLIC FUNCTIONS ==========
    
    /**
     * @dev See {IERC20-transfer}
     * @param to The address to transfer to
     * @param amount The amount to transfer
     * @return True if the transfer succeeded
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }
    
    /**
     * @dev See {IERC20-approve}
     * @param spender The address to approve
     * @param amount The amount to approve
     * @return True if the approval succeeded
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }
    
    /**
     * @dev See {IERC20-transferFrom}
     * @param from The address to transfer from
     * @param to The address to transfer to
     * @param amount The amount to transfer
     * @return True if the transfer succeeded
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    
    /**
     * @dev Atomically increases the allowance granted to spender
     * @param spender The address to increase allowance for
     * @param addedValue The amount to increase allowance by
     * @return True if the operation succeeded
     * @notice Safely increases allowance to prevent race conditions
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = _allowances[owner][spender];
        
        // Check for overflow
        require(currentAllowance + addedValue >= currentAllowance, "ERC20: allowance overflow");
        
        _approve(owner, spender, currentAllowance + addedValue);
        return true;
    }
    
    /**
     * @dev Atomically decreases the allowance granted to spender
     * @param spender The address to decrease allowance for
     * @param subtractedValue The amount to decrease allowance by
     * @return True if the operation succeeded
     * @notice Safely decreases allowance with underflow protection
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = _allowances[owner][spender];
        
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }
    
    // ========== INTERNAL FUNCTIONS ==========
    
    /**
     * @dev Moves amount of tokens from from to to
     * @param from The address to transfer from
     * @param to The address to transfer to
     * @param amount The amount to transfer
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: transfer amount must be greater than zero");
        
        _beforeTokenTransfer(from, to, amount);
        
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;
        
        emit Transfer(from, to, amount);
        
        _afterTokenTransfer(from, to, amount);
    }
    
    /**
     * @dev Creates amount tokens and assigns them to account
     * @param account The address to mint tokens to
     * @param amount The amount of tokens to mint
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        require(amount > 0, "ERC20: mint amount must be greater than zero");
        require(_totalSupply + amount <= MAX_SUPPLY, "ERC20: mint amount exceeds maximum supply");
        
        _beforeTokenTransfer(address(0), account, amount);
        
        _totalSupply += amount;
        _balances[account] += amount;
        
        emit Transfer(address(0), account, amount);
        
        _afterTokenTransfer(address(0), account, amount);
    }
    
    /**
     * @dev Destroys amount tokens from account
     * @param account The address to burn tokens from
     * @param amount The amount of tokens to burn
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        require(amount > 0, "ERC20: burn amount must be greater than zero");
        
        _beforeTokenTransfer(account, address(0), amount);
        
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        
        emit Transfer(account, address(0), amount);
        
        _afterTokenTransfer(account, address(0), amount);
    }
    
    /**
     * @dev Sets amount as the allowance of spender over the owner's tokens
     * @param owner The address that owns the tokens
     * @param spender The address that will spend the tokens
     * @param amount The amount of allowance to set
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    /**
     * @dev Updates owner's allowance for spender based on spent amount
     * @param owner The address that owns the tokens
     * @param spender The address that is spending the tokens
     * @param amount The amount being spent
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    
    // ========== HOOKS ==========
    
    /**
     * @dev Hook that is called before any transfer of tokens
     * @param from The address tokens are transferred from
     * @param to The address tokens are transferred to
     * @param amount The amount of tokens being transferred
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {
        // This is a hook for derived contracts to implement custom logic
        // Examples: pause functionality, fee calculation, etc.
    }
    
    /**
     * @dev Hook that is called after any transfer of tokens
     * @param from The address tokens were transferred from
     * @param to The address tokens were transferred to
     * @param amount The amount of tokens that were transferred
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {
        // This is a hook for derived contracts to implement custom logic
        // Examples: updating rewards, triggering events, etc.
    }
}