// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin-contracts@5.0.0/token/ERC20/ERC20.sol";

/// @title Marco's cool fee on transfer token
/// @author Alexander Weinmann
/// @notice This contract implements a token with a transfer fee
/// @dev Inherits from OpenZeppelin's ERC20 contract
contract Fot is ERC20 {
    uint256 private constant BASIS_POINTS_DENOMINATOR = 100;
    uint256 private constant DEFAULT_TRANSFER_FEE_PERCENTAGE = 1; // 1% fee
    uint256 public transferFeePercentage;
    address public feeRecipient; // Address to receive the fee

    /// @notice Creates a new Fot token
    /// @param initialSupply The initial supply of tokens
    /// @param _feeRecipient The address to receive the fee
    /// @param _transferFeePercentage The transfer fee percentage
    /// @dev The constructor sets the initial supply, fee recipient address, and transfer fee percentage
    constructor(uint256 initialSupply, address _feeRecipient, uint256 _transferFeePercentage) ERC20("Marco's cool fee on transfer token", "FOT") {
        require(_feeRecipient != address(0), "Fot: Fee recipient cannot be the zero address");
        _mint(msg.sender, initialSupply);
        feeRecipient = _feeRecipient; // Set the fee recipient address
        transferFeePercentage = _transferFeePercentage == 0 ? DEFAULT_TRANSFER_FEE_PERCENTAGE : _transferFeePercentage; // Set the transfer fee percentage
    }

    /// @notice Transfer tokens with fee
    /// @param recipient The address receiving the tokens
    /// @param amount The amount of tokens being transferred
    /// @return success True if the transfer was successful
    function transfer(address recipient, uint256 amount) public override returns (bool success) {
        require(amount > 0, "Fot: Transfer amount must be greater than zero");
        uint256 fee = (amount * transferFeePercentage) / BASIS_POINTS_DENOMINATOR;
        uint256 amountAfterFee = amount - fee;
        super.transfer(recipient, amountAfterFee);
        super.transfer(feeRecipient, fee);
        return true;
    }

    /// @notice Transfer tokens from one address to another with fee
    /// @param sender The address sending the tokens
    /// @param recipient The address receiving the tokens
    /// @param amount The amount of tokens being transferred
    /// @return success True if the transfer was successful
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool success) {
        require(amount > 0, "Fot: Transfer amount must be greater than zero");
        uint256 fee = (amount * transferFeePercentage) / BASIS_POINTS_DENOMINATOR;
        uint256 amountAfterFee = amount - fee;
        super.transferFrom(sender, recipient, amountAfterFee);
        super.transferFrom(sender, feeRecipient, fee);
        return true;
    }
}

// Optional: Funktionen zum Ändern der Transfergebühr
